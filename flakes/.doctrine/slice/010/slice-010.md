# Base tidy: optional pieces out of modules/ (RFC-001 W9)

## Context

RFC-001 W9 (tidy). SL-007 and SL-008 settled the shape: `modules/nixos/` is
the NixOS base (DEC-027), `modules/home/` the home base with its `linux/`
and `darwin/` layers (DEC-031). Anything optional is a feature.

A pass over `modules/` (2026-10-17) found pieces in the base that are not
needed by every host, plus dead and parked files:

```
modules/
  nixos/   base (16)  ── some contents optional: dev libs, cargo, admin/debug
                         tools, 1password, rust-motd, tailscale, avahi,
                         udisks2/sysprof
           hyprland.nix, kmscon.nix   parked (do not evaluate)
  home/    base (5)   ── yazi (programs.nix), shpool optional
           linux/{helix,slk,bough}.nix   imported nowhere
  DESIGN.md           retirement is CHR-001
  treefmt.nix.txt     referenced nowhere
```

Why now: W7 (`nixosvm`, headless aarch64) imports the NixOS base. A base that
carries desktop automation, debug tooling and dev libraries makes that guest
fat for no reason. Smaller base = cheaper host (RFC-001 goal).

## Scope & Objectives

User direction (2026-10-17): option 1, "optional only"; parked modules move
aside, not deleted.

1. **Move optional pieces out of the base into features.** Candidates
   (placement is design's job):

   | from | pieces | likely target |
   |---|---|---|
   | `modules/nixos/lib.nix` | glib, libffi, openssl.dev, pkg-config, … | `dev.build` |
   | `modules/nixos/cargo.nix` | cargo, cargo-update | `dev.runtimes` |
   | `modules/nixos/cli.nix` | distrobox, valgrind, strace, nethogs, sysprof, ydotool, … | split: base keeps hardware/log inspection; the rest → features |
   | `modules/nixos/programs.nix` | `_1password`, rust-motd (nix-ld, zsh likely stay) | `security.credentials`, … |
   | `modules/nixos/util.nix` | udisks2, sysprof service | `files.disk`, `system.monitor` |
   | `modules/nixos/network.nix` | tailscale | a `net` feature |
   | `modules/nixos/avahi.nix` | mDNS | with `services.printing`, or site |
   | `modules/home/programs.nix` | yazi + plugins | `files.manage` |

   Added in design (DEC-042): `terminal.zsh` takes zsh off both bases
   (system `programs.zsh`; home `zsh.nix`, mcfly, zsh packages) and root's
   login shell becomes NixOS's default bash; tailscale's daemon and
   `desktop.core`'s tray become `net.tailscale`; rust-motd, root's helix and
   nix-ld stay base; ssh and locate become `services.ssh` / `files.locate`
   (DEC-044). Placement of every piece: DEC-042 + DEC-044.

   Each moved piece stays selected on Sleipnir (and Draupnir where it has
   it) through a profile, so those hosts build the same derivations.

2. **Delete dead files:** `modules/home/linux/{helix,slk,bough}.nix`,
   `modules/treefmt.nix.txt`, and the commented `./helix.nix` import.

3. **Park, don't delete:** move `modules/nixos/{hyprland,kmscon}.nix`,
   `modules/home/shpool.nix` (IMP-001; user, 2026-10-17) and the commented
   `danksearch.nix` reference to a parked directory outside
   `modules/` (e.g. `parked/`), so `modules/` holds only base. Update the
   commented imports in `hosts/Sleipnir/config.nix` and the README's
   "Parked is not a feature" paragraph.

   IMP-001's other half: emacs's session tool is zmx (no daemon), today
   installed only incidentally by `terminal.utils`; make it an explicit
   dependency of `editor.emacs`. Parking shpool also stops its systemd user
   service reaching Draupnir's home.

4. **Record the amended base contents**: DEC-042 amends DEC-027 and DEC-031;
   DEC-043 records `parked/`. Update README and RFC-001 W9.

## Non-Goals

- Turning the base itself into features (rejected, option 2: reopens DEC-027
  / DEC-031).
- `darwin/` (the darwin base): out of scope.
- Locale / timezone in `env.nix` (site-bound config, IMP-017).
- `modules/DESIGN.md` retirement (CHR-001), unless trivially adjacent.
- W9's other items: `alarm.nix` device, Sleipnir's overlays → features,
  `sleipnir-doctor` naming.
- Building the `headless` profile (W7).

## Affected surface

`modules/nixos/*`, `modules/home/*`, `features/*.nix`, `features/profiles/*`,
`hosts/Sleipnir/config.nix`, a new parked dir, `README.md`, RFC-001.

## Risks & assumptions

- **Derivation identity.** Moves must keep `just drvs` identical for every
  host (mem.pattern.flakes.drv-gate); a moved import reorders merged lists
  (mem.fact.nix.merge-order). Ordering-only diffs need proof via
  `drvs-sets` / `nix-diff`.
- `coverage."base@aarch64-linux"` and `home@aarch64-linux` shrink: that is
  the point, but it changes their drvPaths (expected diff).
- Draupnir's home imports the home base: moving yazi out changes it unless
  `personal`/`personal-darwin` selects it. Parking shpool is an intended
  behaviour diff on both homes (Sleipnir loses the daemon; Draupnir loses a
  systemd unit it could never run).
- New files are invisible until `git add -N` (mem.fact.flakes.git-add-n).

## Open questions

OQ-1..4 answered by the user 2026-10-17 and recorded in DEC-042 / DEC-043.

## Verification / closure

- `just drvs`: identical or ordering-only (proven) except the intended
  diffs: Sleipnir system (root's shell), both homes (shpool), coverage
  `base@`/`home@aarch64-linux` (shrink).
- `just test` and `just coverage` green.
- `modules/` holds only base modules (+ DESIGN.md pending CHR-001); no dead
  or parked file under it.
- New decision recorded; README and RFC-001 updated.

## Summary

## Follow-Ups
