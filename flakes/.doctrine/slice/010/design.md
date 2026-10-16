<!-- doctrine:section sec-1 -->
## Shape

Pieces that not every host needs leave the two bases for feature records.
Dead files go; parked modules move to `parked/`. The resolver, the record
shape and the factories are untouched.

```
before                                        after
──────                                        ─────
modules/nixos/  16 modules                    modules/nixos/  nix user network boot kernel
  lib cargo util avahi ssh locate               env maintenance security programs cli
  + optional bits of cli, programs,             (cli = inspection set only)
    network, user (root zsh)
  hyprland kmscon (parked)                    parked/  hyprland kmscon shpool
modules/home/   zsh nushell programs          modules/home/   nushell programs (direnv) cli
  shpool cli                                    (cli without the zsh bucket)
  linux/{helix,slk,bough} (dead)              deleted, with modules/treefmt.nix.txt

features: existing records gain nixos halves  dev.build dev.runtimes dev.tools net.tools
  (homeManager halves untouched)                files.disk security.credentials desktop.core
          new records                         virt.sandbox net.tailscale services.avahi
                                                services.ssh files.locate terminal.zsh
```

Decisions: DEC-042 (what stays, where each piece goes; amends DEC-027,
DEC-031), DEC-043 (`parked/`, dead files, zmx), DEC-044 (ssh, locate).
Evidence: `research/research.md`.

Every moved piece stays selected on the hosts that have it today, through a
profile they already import, so a pure move is ordering-only in the drv gate.
Behaviour changes are confined to one phase (§ Phases and verification).

<!-- doctrine:section sec-2 -->
## NixOS side

System packages stay system packages: each lands in a `nixos` half beside
the feature's existing `homeManager` half (research X1). A darwin host has no
nixos evaluation, so these halves never reach Draupnir (F2).

| from | piece | record · half | selected by |
|---|---|---|---|
| `lib.nix` (deleted) | glib libffi libiconv libyaml openssl openssl.dev pkg-config zlib icu | `dev.build` · nixos | personal |
| `cargo.nix` (deleted) | cargo cargo-update | `dev.runtimes` · nixos | personal |
| `cli.nix` | valgrind sysprof | `dev.tools` · nixos | personal |
| `util.nix` (deleted) | `services.sysprof.enable` | `dev.tools` · nixos | personal |
| `util.nix` | `services.udisks2.enable` | `files.disk` · nixos (udiskie's backend) | personal |
| `cli.nix` | iptraf-ng nethogs nmon vnstat | `net.tools` · nixos | personal |
| `programs.nix` | `programs._1password`, `_1password-cli` | `security.credentials` · nixos | personal |
| `cli.nix` | ydotool | `desktop.core` · `core/gui.nix` | workstation |
| `cli.nix` | bubblewrap distrobox distrobox-tui | **`virt.sandbox`** (new, nixos) | workstation |
| `network.nix` | `services.tailscale.enable` | **`net.tailscale`** (new) · nixos | personal-linux |
| `desktop/core/home.nix` | `services.tailscale-systray` | `net.tailscale` · homeManager | (same record) |
| `avahi.nix` (deleted) | `services.avahi` | **`services.avahi`** (new, nixos) | Sleipnir (beside printing) |
| `ssh.nix` (deleted) | openssh + settings, fail2ban; `allowedTCPPorts [22]` from `network.nix` | **`services.ssh`** (new, nixos) | personal-linux |
| `locate.nix` (deleted) | `services.locate` (plocate) | **`files.locate`** (new, nixos) | personal-linux |

- `net.tailscale` carries `platforms = lib.platforms.linux` (its home half is a
  systemd user unit). The tray is `PartOf`/`WantedBy`
  `graphical-session.target`, so on a headless host it stays inert (verified
  against Home Manager's module).
- `services.printing` gains `requires = ["services.avahi"]`. `requires` never
  selects (ADR-001 D4), so `hosts/Sleipnir/features.nix` selects
  `services.avahi` explicitly; `hosts/Sleipnir/dns.nix`'s `MulticastDNS =
  false` comment names the feature.
- `portable` records (`dev.*`, `net.tools`, `files.disk`,
  `security.credentials`) keep no `platforms`; the nixos half is simply absent
  from darwin evaluations.
- Base after: `cli.nix` keeps strace, the hardware/disk inspection set, atop
  iotop lm_sensors, isd lazyjournal systemctl-tui; `programs.nix` keeps nix-ld,
  rust-motd, helix (root's editor); `network.nix` keeps NetworkManager,
  firewall (no ports), nftables, hostName, timeServers.
- The `virt.docker` assertion in `security.nix` stays in the base (it guards
  every host).

<!-- doctrine:section sec-3 -->
## Home side, zsh and root's shell

| from | piece | record · half | selected by |
|---|---|---|---|
| `home/programs.nix` | `programs.yazi` + plugins | `files.manage` · homeManager | personal |
| `home/programs.nix` | `programs.nix-search-tv.enableTelevisionIntegration` | `files.search` · homeManager (its package lives there) | personal |
| `home/zsh.nix` (moved) | `programs.zsh`, `programs.mcfly` | **`terminal.zsh`** (new) · homeManager | personal |
| `home/cli.nix` | zsh zsh-autocomplete antidote | `terminal.zsh` · homeManager | personal |
| `nixos/programs.nix`, `nixos/env.nix` | `programs.zsh.enable`, `pathsToLink "/share/zsh"` | `terminal.zsh` · nixos | personal |
| `nixos/user.nix` | `users.defaultUserShell = pkgs.zsh` | dropped: root gets NixOS's default bash | — |
| `home/shpool.nix` | shpool user service | `parked/` | — |
| — | zmx | `editor.emacs` lists it (IMP-001) | personal |

- **Why root's shell changes.** NixOS refuses a zsh login shell without
  `programs.zsh.enable`. With root on zsh the base could not shed zsh, and
  `coverage."base@aarch64-linux"` (base alone) would fail. bash is POSIX and
  rescue-safe; nushell and fish are not (DEC-042 alternatives). The user's own
  login shell stays nushell (`user.nix`).
- **Draupnir.** The Mac logs straight into nu (the user ran `chsh`); the PATH
  block in `modules/home/darwin/default.nix` is the live route. zsh stays
  available there via `personal`.
- `terminal.zsh` has no `platforms`: both halves are portable, and the nixos
  half is absent on darwin. `programs.zsh.initContent` already orders with
  `mkOrder`, so moving the module does not reorder zsh init.
- `home/zsh.nix` moves as a file to `features/terminal/zsh.nix` (the record's
  home half imports it), keeping the area file small; the record itself is
  inline in `features/terminal.nix`.
- zstd stays in the base cli (general-purpose).

<!-- doctrine:section sec-4 -->
## Parked and dead files

```
parked/                 at the flake root; never imported, never evaluated
  hyprland.nix          from modules/nixos/  (hyprlandPlugins.hyprexpo gone)
  kmscon.nix            from modules/nixos/  (services.kmscon.fonts removed)
  shpool.nix            from modules/home/   (emacs uses zmx; IMP-001)
```

- `git mv`, so history follows. A file in `parked/` is not a feature and not
  an import (ADR-005): selecting it would promise a switch that breaks the build.
- `hosts/Sleipnir/config.nix` parked comments point at `../../parked/…`.
- Deleted: `modules/home/linux/{helix,slk,bough}.nix`, `modules/treefmt.nix.txt`,
  and the commented `./helix.nix` and `./danksearch.nix` lines in
  `modules/home/linux/default.nix` (danksearch.nix itself is already gone, F7).
- `modules/DESIGN.md` stays until CHR-001.

<!-- doctrine:section sec-5 -->
## Phases and verification

Gate per phase: `just drvs` before and after (mem.pattern.flakes.drv-gate),
dev checkout HEADs recorded with each snapshot; ordering-only diffs proven with
`just drvs-sets` / `nix-diff`. New files `git add -N` before evaluating.

| phase | change | expected `just drvs` diff |
|---|---|---|
| P1 parked + dead | § Parked and dead files, minus shpool | none |
| P2 NixOS moves | § NixOS side | Sleipnir system + home, coverage `Sleipnir+*`: ordering-only (home: the tray moves records). `base@aarch64-linux`: shrinks (expected) |
| P3 home moves | yazi, nix-search-tv, `terminal.zsh` home half + zsh packages | Sleipnir + Draupnir homes: ordering-only. `home@aarch64-linux`: shrinks |
| P4 behaviour | root → bash; system zsh → `terminal.zsh` nixos half; shpool parked; zmx in `editor.emacs` | Sleipnir system: root's shell, `/share/zsh` dedupe. Both homes: shpool unit gone, zmx dedups. `base@aarch64-linux`: no zsh |
| P5 docs | README, RFC-001 W9, DEC-027/031 consequences | none |

P4 is separate so P2–P3 can be proven pure moves. The system zsh move rides
with the root-shell change because each alone breaks: base without
`programs.zsh` but root on zsh fails NixOS's shell assertion.

Also each phase: `just test` (resolver tests, script tests, lock guard) and
`just coverage` (incl. `just isolation`) green; `nix fmt` on touched files,
without committing the `emacs-overlay` re-lock (mem.fact.flakes.fmt-relock).

For P4, built `/etc/passwd` root entry is checked by option value
(`users.users.root.shell`), since the probe does not measure `/etc`.

<!-- doctrine:section sec-6 -->
## Code impact and docs

```
modules/nixos/default.nix   imports: − avahi cargo lib locate ssh util
modules/nixos/{cli,programs,network,env,user}.nix   pieces out (§ NixOS side, § Home side)
modules/nixos/{avahi,cargo,lib,locate,ssh,util}.nix  deleted
modules/home/default.nix    imports: − zsh shpool
modules/home/{programs,cli}.nix  yazi, nix-search-tv, zsh bucket out
modules/home/zsh.nix        → features/terminal/zsh.nix
modules/home/linux/default.nix  dead comments out
features/{dev,net,files,security,services,virt,terminal}.nix  halves / records
features/desktop/core/{gui,home}.nix  ydotool in, tray out (comment updated)
features/editor/emacs.nix   + zmx
features/profiles/{personal,personal-linux,workstation}.nix  new selections
hosts/Sleipnir/{features,config,dns}.nix  avahi selection, parked paths, comment
parked/                     hyprland kmscon shpool
README.md                   feature-tree listing, base description, Parked,
                            Printing (avahi), Feature tree areas
RFC-001                     W9 row, where things stand
```

Docs: README § Feature tree area listing gains the new records; § Hosts base
description; § "Parked is not a feature" names `parked/`; § Printing says
avahi is `services.avahi`. RFC-001: W9 row and "Where things stand". DEC-027
and DEC-031 gain a consequence pointing at DEC-042. IMP-001 closes with this
slice.

