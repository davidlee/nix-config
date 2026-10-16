<!-- doctrine:section sec-1 -->
## Shape: options and files

Today Sleipnir imports thirty `modules/nixos/*.nix` files flat, so nothing
says which ones every NixOS host needs, which are optional, and which are
Sleipnir's own. After SL-007 every piece of NixOS configuration sits in
exactly one of four places, and the place says what it is:

| class | where | who gets it |
|---|---|---|
| **base** | `modules/nixos/default.nix` and the modules it lists | every NixOS host, by importing it in `config.nix` (DEC-027) |
| **feature** | a record in `features/<area>.nix` | hosts that select it, directly or through a profile |
| **machine config** | `hosts/Sleipnir/machine.nix` | Sleipnir, because of its parts (DEC-019) |
| **host config** | `hosts/Sleipnir/config.nix` and files beside it | Sleipnir, because of its site, account or tuning (DEC-028) |

Options are the main interface (organising principle, slice notes): the
`feature.*` tree is what a host author reads and toggles. So it is
designed first, and files follow it.

### The option tree

New and changed options are marked; everything else is unchanged.
`→` is a `requires` edge. "W" = selected by `features/profiles/workstation.nix`
(`mkDefault`), "S" = selected in `hosts/Sleipnir/features.nix`.

```
feature.
├── hardware.
│   ├── openrgb                        (off; coverage)
│   ├── bluetooth        new   S       bluetooth.nix
│   ├── qmk              new   S       keyboard.nix
│   ├── tablet           new   S       util.nix: opentabletdriver, uinput
│   └── logitech         new   S       util.nix: logitech.wireless
├── session.snooze                 W
├── virt.{capsule,qemu,docker,podman}  (unchanged)
├── non-nix-packages.{appimage,flatpak}  W
├── games.{steam,gamescope,mangohud}   S
├── ai.{llama-cpp,rocm}            (off; coverage)
├── audio.
│   ├── pipewire         new   W       audio.nix, rtkit, rtprio, snd-* modules, audio groups
│   ├── mpd                        S
│   ├── speech                     (off; coverage)
│   └── dictate                    W
├── services.
│   ├── printing                   S
│   ├── postgresql       new   S       postgresql.nix
│   ├── webserver        changed S     gains firewall 80/443 from network.nix
│   └── sunshine                   (off; coverage)
├── apps.cad                       S
├── desktop.
│   ├── core             new   W       the shared Wayland stack (below)
│   ├── greeter          new   S       default session from the host
│   └── fonts                      W
├── compositor.          new area (was desktop.<wm>, DEC-026)
│   ├── sway             renamed S  → desktop.core
│   ├── niri             renamed S  → desktop.core   (minus noctalia)
│   ├── cosmic           renamed S  → desktop.core
│   ├── kde              renamed S  → desktop.core
│   ├── mango            renamed S  → desktop.core
│   └── umbriel          new   S  → desktop.core     umbriel.nix
└── shell.               new area
    └── noctalia         new   S                     out of niri's record
```

`desktop.core` holds what every compositor session here shares, none of it
toggled on its own (DEC-026): `wayland.nix`, `wayland_packages.nix`,
`x11.nix`, `xdg.nix`, `qt.nix`, `keyring.nix` with greetd's keyring PAM line,
and the desktop halves of `programs` (GUI nix-ld libraries, dconf, thunar,
foot, 1Password GUI), `1password` (GUI, browser allowlist), `util` (gvfs,
devmon, gnome-disks), `env` (`SSH_ASKPASS_REQUIRE`), `kernel`
(v4l2loopback), `lib` (hunspell, GUI libs) and `user` (`input` group).

Why the edges are as drawn:

- **Compositors → `desktop.core`.** A compositor without portals, keyring
  and the Wayland stack is not a usable session here.
- **`desktop.greeter` has no edge.** It works with any compositor; the
  session it preselects is the host's `services.displayManager.defaultSession`
  (§ Desktop, compositor and shell), which NixOS checks against the
  installed sessions.
- **`shell.noctalia` has no edge.** `requires` is conjunctive; a shell needs
  *some* compositor, which it cannot say (DEC-026).
- **Selection does not change.** Every new feature is selected on Sleipnir,
  so its effective configuration stays the same (ADR-001 D7). No new
  feature is off, so the only new coverage target is the aarch64 base
  evaluation (P5).

`desktop.core` is selected by the workstation profile because any desktop
workstation of the user's wants it (DEC-024). Like `virt.docker` and
`non-nix-packages.*` already, `desktop.core` and `audio.pipewire` are
NixOS-only records, so the profile stays Linux-only: a darwin host importing
it would be refused (ADR-005 D6). No darwin host imports it today. DEC-024's
consequences still say a new host gets "fonts and dictate only" and are
refreshed at close. The greeter, compositors and
shell are taste, and the hardware features are bound to this machine's
peripherals (DEC-011, DEC-021), so Sleipnir selects them.

### The file tree

```
modules/nixos/
  default.nix          new   the base: an import list (DEC-027)
  nix.nix  user.nix  ssh.nix  cli.nix  locate.nix  maintenance.nix
  env.nix  boot.nix  kernel.nix  avahi.nix  cargo.nix  lib.nix
  security.nix  network.nix  programs.nix  util.nix   (base halves after splits)
  hyprland.nix  kmscon.nix                          parked, not in default.nix
  every other file                                  gone: moved whole, or its
                                                    only base line folded in
                                                    (1password CLI → programs.nix)

features/
  default.nix          + compositor, shell areas (after desktop)
  hardware.nix         + bluetooth, qmk, tablet, logitech
  audio.nix            + pipewire (first)
  services.nix         + postgresql; webserver gains ports
  desktop.nix          core (first), greeter, fonts; compositors leave
  desktop/core.nix     new   own file (DEC-015 size rule); imports the
  desktop/core/*.nix   new   moved modules (§ Desktop, compositor and shell)
  compositor.nix       new   sway, niri, cosmic, kde, mango, umbriel
  compositor/sway.nix  moved from desktop/sway.nix
  shell.nix            new   noctalia
  profiles/workstation.nix   + desktop.core, audio.pipewire

hosts/Sleipnir/
  config.nix           imports base + machine + host files; stateVersion,
                       gai.conf, rtcwake sudo rule, Rust kernel patch (until P6)
  machine.nix          + radeon (+ video group), kernel blacklist, i2c,
                       enp8s0 profile, nix jobs/cores/MemoryHigh, swapfile
  dns.nix              new   ControlD stubby + resolved (DEC-029)
  oom.nix              moved from modules/nixos/oom.nix, minus the swapfile
  features.nix         selects the new features; desktop.* → compositor.*
```

`modules/nixos/` ends up holding only the base (plus the two parked files),
so the directory listing shows the classification (DEC-027). Files that
split are kept under their current name for their base half. Files that move
whole go into their new home with `git mv`, so history follows them.

<!-- doctrine:section sec-2 -->
## The NixOS base

The base is what a headless NixOS machine of the user's needs: nix, the
user account, ssh, the CLI, networking without site specifics, and the
generic security settings (DEC-027). It is `modules/nixos/default.nix`, a
plain import list in the shape of `darwin/default.nix`:

```nix
# The NixOS base: what every NixOS host imports (DEC-027). Not a feature and
# not a profile: it has no switch. Optional pieces are features (../../features),
# machine- and host-bound pieces live in hosts/<host>/.
{
  imports = [
    ./avahi.nix
    ./boot.nix
    ./cargo.nix
    ./env.nix
    ./kernel.nix
    ./lib.nix
    ./locate.nix
    ./maintenance.nix
    ./network.nix
    ./nix.nix
    ./programs.nix
    ./security.nix
    ./ssh.nix
    ./user.nix
    ./util.nix
    ./cli.nix
  ];
}
```

The list keeps the base modules' relative order from `config.nix`
(alphabetical, `cli` last). In `config.nix` they are interleaved with
non-base modules (`1password`, `audio`, …, `xdg`), so grouping them under one
import reorders merged lists relative to those; P1's gate row allows exactly
that. Each host's `config.nix` imports `../../modules/nixos` first, then
whatever it still imports flat, in the current order (§ Phases and
verification draws each interim state).

### What each mixed module keeps, and where the rest goes

Lines are cited at the current revision. "core" is `desktop.core`;
"machine" is `hosts/Sleipnir/machine.nix`; "host" is Sleipnir host config.

| module | stays in the base | leaves |
|---|---|---|
| `nix.nix` | everything else, plus `nix.package = lix` (from `config.nix:6`) | `system.stateVersion` (`:6`) → host `config.nix`; `max-jobs`, `cores` (`:30-31`), `MemoryHigh` (`:75`) → machine |
| `user.nix` | the user; groups `networkmanager`, `wheel`, `dev` (until P6) | `video` → machine (with radeon); `audio`, `jackaudio` → `audio.pipewire`; `input` → core |
| `programs.nix` | nix-ld enable + default libs (`:12-25`) + `helix` (until P6); `rust-motd`; `zsh`; `_1password` (CLI); `pathsToLink` | GUI nix-ld libs (`:27-149`), `dconf`, `_1password-gui`, `thunar`, `foot` → core |
| `1password.nix` | `_1password-cli` package → `programs.nix` | `_1password-gui`, browser allowlist → core; file deleted |
| `security.nix` | docker assertion, `polkit`, `sudo.enable` | `rtkit` + rtprio `loginLimits` → `audio.pipewire`; greetd keyring PAM (`:50`) → core; rtcwake rule → host |
| `network.nix` | tailscale, NetworkManager, `hostName`, `timeServers`, `useDHCP`/`dhcpcd` off, firewall + 22, nftables | `enp8s0` profile (`:13-30`) → machine; 80/443 → `services.webserver`; `gai.conf` → host; NM `dns`, stubby, resolved (`:12`, `:58-100`) → `hosts/Sleipnir/dns.nix` |
| `env.nix` | `NIXOS`, session PATH, `pathsToLink`, time zone, locale | `SSH_ASKPASS_REQUIRE` → core |
| `kernel.nix` | `linuxPackages_latest`, initrd | `snd-*` modules → `audio.pipewire`; v4l2loopback (module, package, modprobe options) → core; blacklist → machine; Rust patch → host (until P6) |
| `lib.nix` | build libs: `glib`, `libffi`, `libiconv`, `libyaml`, `openssl(.dev)`, `pkg-config`, `zlib`, `icu` | hunspell dictionaries, `ffmpeg`, `glfw`, `pixman` → core |
| `util.nix` | `udisks2`, `sysprof` | `dconf`, `gnome-disks`, `devmon`, `gvfs` → core; logitech → `hardware.logitech`; opentabletdriver + uinput → `hardware.tablet`; i2c → machine |

`avahi`, `boot`, `cargo`, `locate`, `maintenance`, `ssh`, `cli` stay whole.
`cli.nix`'s shared list gains an x86 guard for `cpuid` and `x86info` in P5
(aarch64 base target).

**Invariants.**
- No base module reads the feature selection (ADR-001; there is no
  `features` argument to read).
- No base module duplicates something a feature switches (ADR-001 D6), and
  no feature restates a base setting. Two known cases set the same value:
  `polkit.enable` in `keyring.nix` (base: `security.nix`) and `avahi.enable`
  in `audio.nix` (base: `avahi.nix`). The feature's copy is dropped in the
  phase that moves it (P3, P4). The configuration is identical, and the gate
  proves it.
- `zsh` stays in the base with `user.nix`, which sets
  `defaultUserShell = pkgs.zsh`.

<!-- doctrine:section sec-3 -->
## Machine and host config

Two kinds of Sleipnir-only configuration, kept apart by DEC-019 and
DEC-028: what follows from its parts (machine), and what follows from its
site, account or tuning (host).

**`hosts/Sleipnir/machine.nix` gains:**

- `radeon.nix`, moved in verbatim (its file history stays with the deleted
  `modules/nixos/radeon.nix`; machine config is one file by DEC-019), plus `users.users.${username}.extraGroups = ["video"]`
  (the GPU is why the user needs `video`). The file stops being a module of
  its own (no `hardware.amdgpu` feature, DEC-028).
- the kernel blacklist (`ucsi_ccg`, `vc032x`, `gspca_vc032x`): Sleipnir's devices.
- `hardware.i2c.enable` (CHR-014 investigates whether it is needed).
- the `enp8s0` NetworkManager profile: Sleipnir's NIC and LAN address
  (Public under POL-001).
- nix `max-jobs`, `cores` and nix-daemon `MemoryHigh`: sized to its CPU and RAM.
- the 16G `/swapfile`: sized to its disk and RAM.

**Host config** is `config.nix` plus the files it imports beside it:

```nix
# hosts/Sleipnir/config.nix — after
{pkgs, inputs, ...}: {
  system.stateVersion = "24.11";

  # The session the greeter preselects; NixOS refuses a name that is not an
  # installed session.
  services.displayManager.defaultSession = "niri";

  nixpkgs.overlays = with inputs.self.overlays; [llama-prism whisper-rocm click-threading-fix];

  imports = [
    ./hardware-configuration.nix
    ./machine.nix
    ../../modules/nixos # the NixOS base (DEC-027)
    ./dns.nix
    ./oom.nix
  ];

  # gai.conf: prefer IPv4 (ISP v6 egress; README § Prefer IPv4) — moved verbatim
  # rtcwake sudo rule for snooze — moved verbatim
  # Rust kernel patch — moved verbatim; removed in P6
}
```

- `dns.nix` (DEC-029): NetworkManager's `dns = "systemd-resolved"`, stubby
  with the ControlD upstreams, resolved, stubby's restart policy, moved
  unchanged. Its header names POL-001 and IMP-002: the profile hostname is
  Private and stays here only until IMP-002 replaces this file.
- `oom.nix`: `modules/nixos/oom.nix` moved (`git mv`) without the swapfile.
  Its session-slice reservation and earlyoom avoid list name this host's
  compositors and UID; IMP-022 parametrises it per host.
- Overlays stay (W9).

The rtcwake rule leaves `security.nix`'s `extraRules`. sudoers is
last-match-wins, but the rules on Sleipnir are disjoint commands at plain
priority, so a changed order is harmless (`mem.fact.nix.sudo-rule-order`,
DEC-013). The gate still shows the reorder.

<!-- doctrine:section sec-4 -->
## Desktop, compositor and shell features

Three sibling areas (DEC-026), appended to `features/default.nix` in this
order after `desktop`: `compositor`, `shell`.

**`desktop.core`** is the largest record: about 400 lines across eight
modules. One file would bury the structure, so the record lives in
`features/desktop/core.nix` and its NixOS half imports the moved modules
from `features/desktop/core/`:

```nix
# features/desktop/core.nix
# The shared Wayland stack every compositor session here uses (DEC-026).
# Never toggled in parts; compositors require it.
{
  name = "core";
  nixos = _: {
    imports = [
      ./core/wayland.nix
      ./core/wayland_packages.nix
      ./core/x11.nix
      ./core/xdg.nix
      ./core/qt.nix
      ./core/keyring.nix          # + greetd keyring PAM from security.nix; minus polkit
      ./core/gui.nix              # GUI programs and libraries, session glue
      ./core/v4l2loopback.nix     # from kernel.nix
    ];
  };
}
```

Each whole-file module moves with `git mv` under its own name, so its
history follows. `gui.nix` and `v4l2loopback.nix` are new: they collect the
desktop halves of split files. `gui.nix` holds GUI programs and libraries
and the session glue they need, from `programs`, `1password`, `util`, `lib`,
`env` and `user`; its header names each part's origin. It is not called
`apps`, the name of an existing area whose meaning IMP-016 has yet to settle. `xdg.nix`'s comment on where `umbriel`
defines its portal section (`:13`, "./umbriel.nix") is corrected to the
`compositor.umbriel` record's upstream module. The
`imports` list is explicit (ADR-002 D7) and the record is still one record
with one half. It is the first record to compose modules this way, which
ADR-002 D3 ("the own file holds the whole record") does not yet admit.
REV-006 revises D3: a record too big for one file may import modules of its
own from `features/<area>/<name>/`, listed explicitly, belonging to that
record only. The revision is applied in P3 with the README's "own file" rule,
so the two never disagree. An unselected record's `imports` sit inside a
class value and are never forced, so ADR-002 D4's boundary holds.

**`desktop.greeter`**: `greeter.nix` whole, no `requires` (DEC-026). Its
hard-coded `default = "niri"` (`:19`) becomes the host's choice:

```nix
# in the greeter record's nixos half ({config, lib, ...})
services.displayManager.noctalia-greeter.settings.default =
  lib.mkIf (config.services.displayManager.defaultSession != null)
  config.services.displayManager.defaultSession;
```

`services.displayManager.defaultSession` is the standard NixOS option for
the preselected session. NixOS asserts that it names an installed session
(`nixos/modules/services/display-managers/default.nix:196`), so a dropped
compositor or a typo fails evaluation instead of the login screen. The
noctalia-greeter module does not read it itself, hence the two lines above.
A host that leaves it unset gets noctalia's own behaviour. GDM, LightDM and
SDDM also read the option; none is enabled here, so P3 expects the
greeter's config to be the only consumer, and the gate proves it.
`console.*` stays with the greeter: it serves the greeter's TTY handover.

**`desktop.fonts`**: unchanged.

**`compositor.*`**: the five existing records move from `features/desktop.nix`
to `features/compositor.nix` unchanged, each gaining
`requires = ["desktop.core"]`. `features/desktop/sway.nix` moves to
`features/compositor/sway.nix`. `compositor.umbriel` is `umbriel.nix` as a
record, in the `mango` shape (upstream module import plus enable).
`compositor.niri` loses the noctalia package line.

**`shell.noctalia`**: `environment.systemPackages = [inputs.noctalia.packages.${system}.default]`,
no `requires`. The noctalia greeter stays in `desktop.greeter`: it is a
greeter, whatever shell it comes from.

**Renaming is a breaking change to the option paths.** `feature.desktop.<wm>`
becomes `feature.compositor.<wm>` in `hosts/Sleipnir/features.nix`,
`features-test.nix` and the README in the same phase. An old path left
anywhere fails evaluation (undeclared option), so nothing can be missed
silently.

Selection: `desktop.core` by `workstation`; `greeter`, `compositor.*`,
`shell.noctalia` by Sleipnir.

<!-- doctrine:section sec-5 -->
## Audio, hardware and service features

All inline in their area files; none passes the ~100-line prompt for its
own file.

| feature | content | selected by | position |
|---|---|---|---|
| `audio.pipewire` | `audio.nix` minus `avahi.enable` (base); `security.rtkit`; the `@users` rtprio `loginLimits`; `boot.kernelModules` `snd-seq`, `snd-rawmidi`, `snd-aloop`; user groups `audio`, `jackaudio` | workstation | first in `features/audio.nix` |
| `hardware.bluetooth` | `bluetooth.nix` whole | Sleipnir | after `openrgb` |
| `hardware.qmk` | `keyboard.nix` whole | Sleipnir | |
| `hardware.tablet` | `hardware.opentabletdriver`, `hardware.uinput`, `boot.kernelModules = ["uinput"]` | Sleipnir | |
| `hardware.logitech` | `hardware.logitech.wireless` | Sleipnir | |
| `services.postgresql` | `postgresql.nix` whole, its stray 80/443 included until P6 | Sleipnir | after `printing` |
| `services.webserver` | gains `networking.firewall.allowedTCPPorts = [80 443]` from `network.nix` | Sleipnir (unchanged) | |

- The hardware features are host-selected: a peripheral is a property of
  the host that has it (DEC-011, DEC-021).
- No `requires` edges. `audio.mpd` and `audio.dictate` need pipewire to do
  anything, but both are selected wherever it is, and the decisions add no
  edge (ADR-001 D4 only obliges profiles to carry the edges that exist).
- `compositor.cosmic` overlaps three of these switches upstream (nixpkgs
  `services/desktop-managers/cosmic.nix`): it sets `hardware.bluetooth.enable`
  and `services.avahi.enable` with `mkDefault`, and `security.rtkit.enable`
  plainly. While cosmic is selected, switching `hardware.bluetooth` off
  removes this host's bluetooth settings, blueman and tools but leaves the
  bluetooth stack on, and switching `audio.pipewire` off leaves rtkit on.
  Accepted, not engineered around: the user plans to drop cosmic after this
  slice. The negative controls state it (§ Phases and verification).

<!-- doctrine:section sec-6 -->
## Base evaluation on aarch64

"The base works on a headless aarch64 host" is W7's premise. Without a
check it is only a claim, so SL-007 adds an evaluation-only target in the
coverage style (ADR-005), checked by `just coverage`:

```nix
# hosts.nix, beside the other coverage targets
# The NixOS base alone on aarch64-linux (DEC-027): proves it evaluates
# headless and off x86, with no host, feature or machine config. Builds nothing.
coverage."base@aarch64-linux" = lib.nixosSystem {
  specialArgs = args "base";
  modules = [
    ./modules/nixos
    (platformModule {system = "aarch64-linux";})
    {
      system.stateVersion = "24.11";
      fileSystems."/" = {device = "/dev/disk/by-label/nixos"; fsType = "ext4";};
    }
  ];
};
```

- It uses `platformModule`, so it gets the same overlays and `stable`
  argument as a real host.
- The inline module provides only what a host must provide: `stateVersion`
  (now per host) and a root filesystem.
- `just coverage` prints its `toplevel` drvPath. Evaluating that forces
  every package in `systemPackages`, so a package marked unavailable on
  aarch64 fails here.

**Known breakers.** `cpuid` and `x86info` in the shared CLI list
(`modules/shared/cli/_packages/system.nix:41,51`) are x86-only. Each is
guarded where it sits, with
`] ++ lib.optional pkgs.stdenv.hostPlatform.isx86 pkgs.cpuid ++ [`, so
Sleipnir's list keeps its order. P5 may find others. A guard at the
package's own site is in scope. Anything larger (a module that needs
restructuring for aarch64) is a `/consult`, not an improvisation.

**Assumption (ASM, to record at plan time):** an evaluation of the
toplevel on an x86_64 builder is enough evidence for W4. Building or booting
it is W7's job.

<!-- doctrine:section sec-7 -->
## Behaviour changes (P6)

Every phase before P6 preserves Sleipnir's configuration. P6 is the one
phase that changes it, and its allowed diff is exactly this list:

| change | site after P1–P5 | expected effect |
|---|---|---|
| IMP-004 prune: `wob`, `i3status`, `wf-config`, `gnomeExtensions.appindicator`, `marble-shell-theme` | `features/desktop/core/wayland_packages.nix` | 5 fewer system packages; none used (research: repo and dotfile grep) |
| duplicate `sway-easyfocus` | `features/compositor/sway.nix:15,19` | one entry fewer; unique set unchanged |
| keyring `greedt` typo | `features/desktop/core/keyring.nix` | `/etc/pam.d/greedt` gone; `greetd` keeps keyring unlock through the `greetd` entry |
| postgresql's stray 80/443 | `services.postgresql` record | ports unchanged (`services.webserver` opens them); `allowedTCPPorts` loses the duplicates at option level; the rendered ruleset is unchanged, since NixOS already deduplicates (RV-016 F-2) |
| undefined `dev` group | `modules/nixos/user.nix` | `extraGroups` loses `dev`, at option level only: the group never existed, so no build output changes (RV-016 F-2) |
| `helix` from nix-ld libraries to `systemPackages` | `modules/nixos/programs.nix` | nix-ld env loses helix; root gets `hx` on PATH, which is what "root's editor" meant |
| drop the Rust `kernelPatch` | `hosts/Sleipnir/config.nix` | kernel becomes the cached `linuxPackages_latest` build |

**Rust patch.** nixpkgs already enables Rust by default on x86_64 and
aarch64 for kernels ≥ 6.12 (`rustByDefault`, `kernel/common-config.nix`;
slice notes, Harvest), so the patch only forces an uncached build. Before
removing it, P6 compares the kernel `.config` of both builds (the
`configfile` derivations, cheap to build): it must be identical. If it is
not, stop and `/consult`. Once verified, the finding becomes a memory.

After P6, IMP-004 is done and closed at slice close.

<!-- doctrine:section sec-8 -->
## Phases and verification

The SL-006 gate carries over unchanged (`mem.pattern.flakes.drv-gate`;
SL-006 design § Gate and probe): `just drvs`, `just drvs-sets`,
`just probe`, `just coverage` and `just gate` before the first edit and
after each phase, each phase compared with the one before. An
ordering-only diff is accepted when every probe measure is identical, or
when the only changed measure is a built artefact whose drv `nix-diff`
shows differs only by list order. A flipped collision winner
(`mem.fact.nix.systempath-collision-first-wins`; research lists 13
duplicated packages) means stop and `/consult`.

**Order is not preserved, deliberately.** Feature modules are appended after
the host's own modules (DEC-007), so a module moving into a feature changes
the order of merged lists. This deviates from ADR-002 D5 ("migration
preserves existing order") in the same way SL-006 did, and is accepted on
the same terms: every reorder is proven harmless per phase by the gate.

**New files are tracked before evaluation.** The flake sees only tracked
files (`mem.fact.flakes.git-add-n`): every new file (`modules/nixos/default.nix`,
`hosts/Sleipnir/dns.nix`, `features/{compositor,shell}.nix`,
`features/desktop/core.nix`, `features/desktop/core/*`) is `git add -N`ed
before the phase's gate runs.

**What `config.nix` still imports flat** from `modules/nixos/` after each
phase (the base import, `hardware-configuration.nix` and `machine.nix` are
always there):

| after | flat imports left | gone this phase, to |
|---|---|---|
| P1 | `1password audio bluetooth greeter keyboard keyring oom postgresql qt radeon umbriel wayland wayland_packages x11 xdg` | base modules → `default.nix` |
| P2 | as P1, minus `oom radeon` | `oom` → `./oom.nix`, radeon → `machine.nix`; `./dns.nix` added |
| P3 | `audio bluetooth keyboard postgresql` | desktop files → `desktop.core`, `desktop.greeter`, `compositor.umbriel`; `1password` split (CLI → `programs.nix`, GUI → core) |
| P4 | none | → `audio.pipewire`, `hardware.bluetooth`, `hardware.qmk`, `services.postgresql` |

One commit per phase. Anything not in a phase's row is red: `nix-diff` it
and stop. Home, Draupnir, packages, legacyPackages and templates lines are
identical at every phase unless the row says otherwise.

| # | phase | allowed diff | proof |
|---|---|---|---|
| P1 | **base**: `modules/nixos/default.nix`; mixed modules imported whole; lix into `nix.nix`; `stateVersion` into `config.nix` | none, or order only | every `drvs` line identical, or every probe measure identical |
| P2 | **machine + host**: radeon (+ `video`), blacklist, i2c, `enp8s0`, nix tuning, swapfile → `machine.nix`; `oom.nix`, `dns.nix`, `gai.conf`, rtcwake, Rust patch → host | order of `kernelModules`, `kernelParams`, `swapDevices`, `extraGroups`, `sudo.extraRules`, `systemPackages` | every probe measure identical |
| P3 | **desktop, compositor, shell**: `desktop.core`, `desktop.greeter`, `compositor.*` (rename + umbriel), `shell.noctalia` | order of `systemPackages`, `nix-ld.libraries`, `extraPortals`, `sessionPackages`, `kernelModules`, `extraGroups`; home: order of the sway and niri halves | every probe measure identical, system and home; the greeter's `greeter.toml` identical (`default` now comes from `defaultSession`) |
| P4 | **audio, hardware, services**: `audio.pipewire`, `hardware.{bluetooth,qmk,tablet,logitech}`, `services.postgresql`, webserver ports | order of `systemPackages`, `kernelModules`, `allowedTCPPorts`, `extraGroups`, `loginLimits` | every probe measure identical (`ports` included) |
| P5 | **aarch64 base target**; x86 guards in shared cli | none on Sleipnir; `coverage` gains `base@aarch64-linux` | every `drvs` line identical; the new target evaluates |
| P6 | **behaviour changes** (§ Behaviour changes) | exactly that table | `drvs-sets` system count drops by 6 (5 pruned + 1 duplicate) and gains 1 (`helix`); probe diff is exactly the table's rows; kernel `.config` identical |

After P4, `modules/nixos/` holds only the base's files and the two parked
ones; P4's check is `ls modules/nixos` against `default.nix`.

**Resolver tests** (`features-test.nix`), red first, in the phase that adds
each feature:
- `testSleipnirSelectsMigrated`: `desktop.<wm>` tags become
  `compositor.<wm>` (P3); gains `desktop.core`, `desktop.greeter`,
  `compositor.umbriel`, `shell.noctalia` (P3), `audio.pipewire`, the four
  `hardware.*`, `services.postgresql` (P4), each `#nixos`, `[true false]`.
- `testCompositorRequiresCore` (P3): the real tree, no host file,
  `[on "compositor.sway"]` is refused, and with `desktop.core` also on it
  resolves. This is the `testGamescopeRequiresSteam` shape.
- No `testOffFeatures` changes: no new feature is off.

**Negative controls** (one-off evaluations, not committed;
`mem.fact.nix.verify-closure-not-option`). Deselect with `lib.mkForce false`
and check the closure, not the option:

| feature | signature gone |
|---|---|
| `desktop.core`, with the compositors (which require it); greeter and shell stay on | `wayland-utils` and `seahorse` absent from system-path; `qt.enable` false |
| `desktop.greeter` | `noctalia-greeter` display manager off. Also, once: `defaultSession = "bogus"` is refused at evaluation |
| `compositor.umbriel` | `programs.umbriel.enable` false |
| `shell.noctalia` | noctalia absent from system-path |
| `audio.pipewire` | `pavucontrol`, `ncpamixer` absent; no `@users` rtprio limit |
| `hardware.bluetooth` / `qmk` / `tablet` / `logitech` | `bluetui` / `qmk` / `opentabletdriver` / `ltunify` absent from system-path. For bluetooth also `services.blueman.enable` false, and `hardware.bluetooth.enable` still true while cosmic is selected (§ Audio, hardware and service features); deselect cosmic too and it is false |
| `services.postgresql` | `postgresql` unit absent |
| `services.webserver` | 80 and 443 absent from `ports`. This only holds from P6, because postgresql opens them until then; re-run in P6 |

The existing compositor controls (SL-006) are re-run under the new paths.
Every control that deselects niri (the `desktop.core` control and niri's own)
also sets `services.displayManager.defaultSession = lib.mkForce null`:
otherwise the NixOS assertion that it names an installed session refuses
evaluation before any signature is checked. That refusal is itself checked
once, under `desktop.greeter`.

**Close:** every `modules/nixos/*.nix` is in `default.nix` or parked;
`git grep -En 'feature\.desktop\.(sway|niri|cosmic|kde|mango)|modules/nixos/(1password|audio|bluetooth|greeter|keyboard|keyring|oom|postgresql|qt|radeon|umbriel|wayland|wayland_packages|x11|xdg)\.nix'`
over tracked files under `flakes/` (excluding `.doctrine/`) finds nothing;
`just gate` green.

<!-- doctrine:section sec-9 -->
## Code impact and docs

| path | change | phase |
|---|---|---|
| `modules/nixos/default.nix` | new: the base import list | P1 |
| `modules/nixos/{nix,user,programs,security,network,env,kernel,lib,util}.nix` | split to their base halves (§ The NixOS base) | P1–P4 |
| `modules/nixos/{1password,oom,radeon,audio,bluetooth,keyboard,postgresql,greeter,umbriel,wayland,wayland_packages,x11,xdg,qt,keyring}.nix` | moved or deleted | P2–P4 |
| `modules/shared/cli/_packages/system.nix` | x86 guards on `cpuid`, `x86info` | P5 |
| `hosts/Sleipnir/config.nix` | imports the base; `stateVersion`, `gai.conf`, rtcwake, Rust patch | P1–P2, P6 |
| `hosts/Sleipnir/machine.nix` | radeon, blacklist, i2c, `enp8s0`, nix tuning, swapfile | P2 |
| `hosts/Sleipnir/{dns,oom}.nix` | new / moved | P2 |
| `hosts/Sleipnir/features.nix` | new selections; `desktop.*` → `compositor.*` | P3–P4 |
| `features/default.nix` | `compositor`, `shell` areas | P3 |
| `features/desktop.nix`, `features/desktop/core.nix`, `features/desktop/core/*` | `core`, `greeter`; compositors leave; header comment rewritten | P3 |
| `features/compositor.nix`, `features/compositor/sway.nix` | new; sway moved | P3 |
| `features/shell.nix` | new | P3 |
| `features/{audio,hardware,services}.nix` | new records; webserver ports | P4 |
| `features/profiles/workstation.nix` | `desktop.core`, `audio.pipewire` | P3–P4 |
| `features-test.nix` | renames, new tags, the compositor `requires` test | P3–P4 |
| `hosts.nix` | `coverage."base@aarch64-linux"` | P5 |
| `README.md` | per phase (below) | each |
| `SATAN.md`, `modules/home/linux/sleipnir-doctor.nix` | pointers follow moved files (RV-016 F-5) | P3–P4 |
| ADR-002 D3 | revised by REV-006 | P3 |

`hosts.nix`'s factories do not change (DEC-027).

**README**, updated in the phase that makes each statement true:
- Features: the tree listing gains `compositor/`, `shell/`, `desktop/core/`
  and the new records. The "own file" rule gains the record-imports-modules
  form, worded as REV-006 words ADR-002 D3 (P3). "Parked is not a feature" is unchanged.
- Hosts: a "base" paragraph (P1): what the base is, where it lives, that a
  host imports it, and the four-class table from § Shape.
- Coverage (P5): the aarch64 base target.
- Prose that names moved files (OOM resilience → `hosts/Sleipnir/oom.nix`,
  Prefer IPv4 → `hosts/Sleipnir/config.nix`, Printing's `avahi.nix`).

**Governance at close:** RFC-001 W4 row done, with W5 told to follow the
same base pattern (DEC-027); IMP-004 closed; DEC-016's stale `features`
argument corrected in passing (research, revision candidates); DEC-024's
consequences refreshed (below). ADR-002 D3 is revised by REV-006 in P3
(§ Desktop, compositor and shell); areas, records and profiles otherwise
keep their ADR-002 shape.

