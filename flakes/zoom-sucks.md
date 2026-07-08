# Screen-share debugging — 2026-07-08

Screen sharing (Zoom + generic recording) broke after last nix + Zoom update.
Symptom: **black** (Zoom) then **static/frozen** (recording). Sway/wlroots + AMD
(Navi 48, RX 9070).

## Two distinct faults found

### 1. Zoom black share — `xwayland=true` (FIXED)

- Zoom updated **7.0.0 → 7.0.5** (`zoom-7.0.5.3034-bwrap`; 7.0.0 still in store at
  `/nix/store/ggv64g5dpbxf78n3mpcj7zmc8nyv3a1j-zoom-7.0.0.1666-bwrap`).
- The update rewrote `~/.config/zoomus.conf`, flipping `xwayland=true`.
- Under XWayland on wlroots, Zoom captures the (empty) X11 root → black.
- **Fix applied:** set `xwayland=false` in `~/.config/zoomus.conf`
  (`enableWaylandShare=true` already set). Backup at
  `~/.config/zoomus.conf.bak.preshare`. Zoom rewrites this file on exit, so it must
  be edited while Zoom is fully quit.
- Note: Zoom Wayland-vs-XWayland share is version-flaky; if native Wayland misbehaves,
  flip back to `true` and retry.

### 2. Portal "no output found" — dead chooser (FIXED)

Not Zoom-specific: Meet/Slack/Firefox screen-share all failed (permission error / black).

Portal journal:
```
xdg-desktop-portal-wlr[...]: [ERROR] - wlroots: no output found
```

**"no output found" is a misnomer.** With TRACE logging the real sequence is:
```
wlroots: capturable output: 60 DP-3          <- output IS found
wlroots: chooser called
exec chooser: wmenu ...  failed. Trying next one.
exec chooser: wofi ...   failed. Trying next one.
exec chooser: rofi ...   failed. Trying next one.
exec chooser: bemenu ... failed. Trying next one.
exec chooser: mew ...    command not found.
exec chooser: fuzzel ... command not found.
wlroots: no output found                     <- logged AFTER chooser chain exhausted
```

xdpw's built-in source-picker chain (`wmenu→wofi→rofi→bemenu→mew→fuzzel`) is run for
any client that defers source selection to the portal. **None of those menu programs
are on the xdpw service's PATH** — the systemd user unit sets a minimal
`Environment=PATH` (coreutils/findutils/grep/sed/systemd only), *not*
`/run/current-system/sw/bin`, even though `fuzzel`/`wofi`/`rofi`/`wmenu` are all
installed system-wide. Every chooser → "command not found" → no source selected →
"no output found" → client gets a failure. (`mew` in the log = one entry in xdpw's
default chain, not a mystery command.)

Verified healthy (so NOT the cause): output enumeration — `grim` captures a full
2 MB PNG via the same `zwlr_screencopy` protocol; portal config; service env
(`WAYLAND_DISPLAY=wayland-1`, `XDG_CURRENT_DESKTOP=sway`); protocol present
(`zwlr_screencopy_manager_v1` v3 + `ext_image_copy_capture_manager_v1` v1).

**Fix applied** (`modules/nixos/xdg.nix`): pin an absolute-path chooser so the
service PATH is irrelevant.
```nix
wlr = {
  enable = true;
  settings.screencast = {
    chooser_type = "dmenu";
    chooser_cmd = "${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt='Share source: '";
  };
};
```
`system-switch`, restart `xdg-desktop-portal-wlr.service`. A `fuzzel` menu now lists
sources; pick output/window → live capture. Confirmed working in Firefox/Meet.

### 3. Zoom full-screen freeze — PipeWire buffer starvation (FIXED via max_fps)

Zoom has its own in-app source picker, so it skips the portal chooser (fault #2) and
reaches streaming — then, **on full-screen (4K) capture only**, freezes on frame ~2.
TRACE:
```
pipewire: enqueueing buffer   <- frame 1
pipewire: enqueueing buffer   <- frame 2
pipewire: dequeueing buffer
[WARN] pipewire: out of buffers
[WARN] pipewire: unable to export buffer
```
Zoom's PipeWire consumer recycles the small dmabuf pool too slowly to keep up with
full-screen 3840×2160 @ ~60fps (33 MB/frame). Pool drains after ~2 frames → stream
stalls → frozen share. Sharing a **single (small) window** survives — smaller frames,
consumer keeps up — which is why it looked "fixed" at first.

**Fix applied** (`modules/nixos/xdg.nix`, same `settings.screencast`): cap capture
rate.
```nix
max_fps = 20;
```
At a capped rate the consumer recycles buffers between frames; verified full-screen
(172 frames, zero `out of buffers`, sustained `streaming`, vs dying at frame 2
before). Tested ceiling: **30 crashed Zoom, 20 holds under heavy motion, 10 is the
safe floor.** The failure is a fast race (starves within ~2 frames if the rate is too
high), so a share that survives ~30s of busy content stays stable.

Non-fixes tried: `force_mod_linear=1` corrected buffer *size* negotiation
(`size 33177600` vs bogus `size 9`) but not recycling → not adopted. A `nix flake
update` (nixpkgs bump, Zoom binary unchanged at 7.0.5.3034) did **not** fix it —
the false "fixed" was a small-window share.

## Non-issues (ruled out, don't chase)

- Portal config / flake `xdg.nix` `ScreenCast=wlr` mapping — correct.
- Store skew / relogin (original prime suspect) — **wrong theory.** Rebooted into the
  Jul 6 generation; "no output found" survived. Root cause was the dead chooser (#2),
  not a stale session. Output enumeration was always fine (grim proved it).
- Zoom bwrap sandbox — auto-binds `/run`, so pipewire socket + portal dbus reachable.
- GVariant `g_variant_*` assertion spam in portal frontend log — pre-existing since
  Jul 3, from an extra portal backend (cosmic/gnome/kde pulled in by
  `cosmic.nix`/`kde.nix`); cosmetic, not the capture fault.
