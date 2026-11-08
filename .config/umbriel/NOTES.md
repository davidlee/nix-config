# umbriel config notes

Upstream bugs and proposals (scratchpad relaunch, tab focus, 1Password tray
crash) are in UPSTREAM.md.

## 2026-10-31: scratchpads and `umbriel msg` after the upgrade

### Done

The upgrade changed `umbriel msg`: the action and each argument are separate
argv words. A joined string (`"window-focus <id>"`, `scratchpad-toggle:<name>`)
is rejected as `unknown action`.

| file | change |
|---|---|
| `scripts/raise-cycle-or-spawn` | `["msg", "window-focus", target]` |
| `scripts/named-workspace` | `umbriel msg workspace-switch "$name"` |
| `scripts/scratchpad-spawn` | deleted: replaced by native `spawn_when_empty` |
| `rules.toml` | `spawn_when_empty` on signal, spotify, onepassword, edit (and commented slack) |
| `apps.toml` | scratchpad binds are plain `scratchpad-toggle <name>` |
| `MAPPING.md` | rows updated to the new syntax and mechanism |

These changes are uncommitted in `~`.

### Loose threads

- **Spotify desktop GPU crash.** 09:08:08: `FATAL ... GPU process isn't usable.
  Goodbye.` (SIGTRAP in libcef). Once so far. If it recurs, try
  `spotify --disable-gpu`.
- **spotify_player / spotifyd alarm.** Two playback devices compete:
  `spotifyd` and spotify_player's own (`enable_streaming = "Always"` in
  `~/.config/spotify-player/app.toml`, plus a daemon and TUI both streaming). The
  08:30 alarm loaded a track on spotifyd, then lost the session two seconds
  later and still reported success. Pick one player; make the alarm verify
  playback. See `features/audio/alarm.nix` (not yet read).
- **Muted streams.** WirePlumber had remembered spotify_player as muted; fixed by
  unmuting (state in `~/.local/state/wireplumber/stream-properties`).

## 2026-10-31: review follow-up (items 1, 4, 6)

A config review listed proposals; these were applied. All uncommitted.

| file | change |
|---|---|
| `rules.toml` | `block_capture = true` on every 1Password window (scratchpad and popups) and on Signal. The `^1Password` popup rule is scoped to 1Password's app_id; unverified that popups carry it, so if a credential popup stops floating, that is why. App-id dots escaped |
| `rules.toml` | dropped the ghostty rule and an `opacity = 1.0` (both no-ops); moved the unfocused-blur rule up from below the layer rules |
| `config.toml`, `layout.toml` | dropped keys equal to the schema default: hot corners, struts, `center_underfull_strip`, `xwayland`, `show_cheatsheet` |
| `binds.toml` | `Mod+Ctrl+P` (duplicate pin) removed. `Mod+Comma/Period` and their Shift variants swapped: plain is consume-or-expel, Shift is consume |
| `scripts/test_raise_cycle_or_spawn.py` | `Main` tests: argv sent to `umbriel msg`, and launch when nothing matches. Red against `e7bfec60` (`window-focus:<id>`), green now. Closes the test gap |
| `scripts/screenshot` | window mode reads `umbriel focused-window --json`; `scripts/umbriel-windows` deleted (its only caller) |
| `ruff.toml`, `.gitignore` | line length 120; `__pycache__/` ignored and the two tracked `.pyc` files removed from the index (`git rm --cached`, staged) |

`Alt+Shift+Tab` stays: noctalia's switcher reverses itself.

## 2026-10-31: reorganised along Umbriel's doc seams (review items 3, 5)

The file → owns table is in AGENTS.md. Uncommitted.

- `MAPPING.md`, `noctalia.toml` (unused Tokyo Night palette) and `io.toml`
  deleted; `io.toml` split into `input.toml` and `outputs.toml`.
- Every colour is in `gruvbox.toml`, including `[colors]` from `layout.toml`
  and the state-border window rules from `rules.toml`. The focused rule was
  split: its `outer_border_width = 2` is in `appearance.toml`.
- `[workspaces]`, `[[workspace]] emacs` and `[overview]` moved from
  `config.toml` to `layout.toml`.
- Scratchpads (`[[scratchpad]]`, their window rules, their binds) moved into
  `apps.toml`, from `rules.toml` and `binds.toml`.
- niri correspondence comments removed everywhere, including the axes diagram
  in `binds.toml` and the script headers.
- Verified: `umbriel config validate` ok; the merged config (tables deep-merged
  in include order, rule arrays compared as sets) is identical before and
  after apart from the split focused rule. No two reordered rules set the
  same field, so "later wins" resolves as before. Live reload ok; workspace
  order unchanged.

If Noctalia's theme export is ever pointed at the palette file, the
colour-only window rules must move out of it first (to `appearance.toml`), or
the export overwrites them.

## 2026-10-31: native features adopted (review item 2)

| feature | where |
|---|---|
| shared-window frame: 3px, gruvbox red (`match.is_cast_target`) | width `appearance.toml`, colour `gruvbox.toml` |
| `[animation.windows_resize]` 220 ms easeinout, matching moves (A/B tested against default and spring) | `animation.toml` |
| pull-in `window-consume-from-left/right` on `Mod+BracketLeft/Right`; consume-or-expel moved to `Mod+Shift+Brackets` (`Mod+Comma/Period` duplicate it, kept) | `binds.toml` |
| `dpms-off` on `Mod+Ctrl+P` (input wakes the monitors) | `binds.toml` |
| tab bar `style = "indicator"` replaces `title_format = ""` | `appearance.toml` |

Declined: `default_workspace = "emacs"` (new frames should open where you are).
Every review item is now closed.

## 2026-11-07: `Mod+Shift+N` toggles the focused window's own pad

`window-toggle-scratchpad main` on a member of another pad moved the workspace
window behind that pad to main: the action restores only when its argument is
the focused window's pad. `scripts/toggle-window-scratchpad` now picks the
argument: the window's current pad, else the pad its rule names, else the
fallback pad passed by the bind (`main`, or `secondary` for `Mod+Shift+D`).

- "Has a non-main scratchpad" is read as "a `default_scratchpad` rule matches
  it". A pad the window merely visited earlier isn't remembered.
- The script parses `apps.toml`, because IPC doesn't expose a window's
  `default_scratchpad`. A pad rule outside that file, or one matching on
  anything but `app_id` and `title`, needs the script changed.
- `Mod+Ctrl+N` and `Mod+Ctrl+D` are redundant with the toggle for members of
  their pads; both stay bound.
- `secondary` (`Mod+D` set) is a second general-purpose pad, like `main`.

## 2026-11-07: `Ctrl+Alt+Shift+U` (Meh-U) toggles the Emacs controller pad

`apps.toml` gains an `umbriel` pad: `spawn_when_empty` opens an `emacsclient`
frame named `umbriel-controller` running `my/umbriel`, 900x700, floating.

- The Emacs server opens the frame, so the pad's launch token never reaches it.
  Tested: a frame spawned with `secondary` open landed on the workspace. The
  window rule places it, and `default_focused` summons it.
- `my/umbriel` sometimes split the new frame (`*umbriel*` beside `*scratch*`),
  so the command ends with `delete-other-windows`.
- Tested over `umbriel msg`, not the physical key: hide, reshow, close and
  respawn (3 rounds, one window each).

### Loose threads (Emacs, not fixed; backlog ISS-018 in `~/.config/emacs`)

- **`q` breaks the pad.** `quit-window` swaps the pad frame to another buffer,
  and the next toggle shows that buffer. Proposal: in a frame that is a pad
  member, `q` toggles that pad instead.
- **Row actions leave the pad.** `dl-umbriel-buffer--focus-act-restore` restores
  the focused workspace's `focused_window`, which is the workspace window behind
  the pad, not the controller. Keyboard focus ends up there; the pad stays
  visible. Read from the code and a live `focused_window` value; no row action
  was run from the pad.

## 2026-11-09: `Mod+Ctrl+Return` swaps with the master

`scripts/swap-master` sends native `window-swap-left` when any tiled window on
the workspace lies wholly left of the focused one, else `window-swap-right`.
With one master on either side that is "swap toward the other column": master
into the stack, stack window with the master. Tests:
`scripts/test_swap_master.py` (7, red before green).

- A bare `window-swap-left` bind (first attempt) only worked from the stack
  with the master left. `umbriel msg` can't signal a failed swap (the action's
  result is discarded, `actions.cpp:1434`) and binds can't chain a fallback,
  hence the script.
- From the master, native swaps pick the stack row nearest the master's
  vertical centre (`layout.cpp` `directionalNeighbor`), not a chosen window,
  so swapping back after a swap only works when that row is the one you came
  from. Fixing that needs the upstream action (UPSTREAM.md).
- Wrong with `position = "center"` (master always swaps left) or more than
  one master.
- `Mod+Return` is `spawn ghostty` (apps.toml).
- Workspace `DP-3:2` looked like 4 masters and 1 stack window (four narrow
  windows left, one wide right; the default `position = "left"` puts masters
  left). Inferred from geometry: IPC doesn't expose the master count. Not
  reset; `Mod+Shift+X` (`layout-master-count-decrease`) would.
- Open: unbind or rebind `Mod+X` / `Mod+Shift+X` to keep one master.
