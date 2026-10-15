# Legacy flags to feature tree: hardware, virt, app formats

## Context

RFC-001 W3 moves every legacy flag (`modules/features.nix`, read as
`specialArgs.features` to gate imports) onto the feature tree (`features/`,
selected by `feature.<area>.<name>.enable`). W3 is on the critical path to
the VM host: W3 → W4 (NixOS base / host split) → W7 (nixosvm).

This is W3's first slice. It takes three small, NixOS-only flag groups:
`hardware`, `virt`, and the app formats from `apps`. `hardware` and `virt`
already exist as tree areas (openrgb, capsule).

```
today                                      after
modules/features.nix                       hosts/Sleipnir/machine.nix (DEC-019)
  hardware.{microcode,ssd}  (off)   ───>     microcode, ssd (machine config)
  virt.{qemu (on), docker (off)}    ───>   features/virt.nix  + qemu (+ libvirtd), docker
modules/nixos/podman.nix (unconditional) ─> features/virt.nix  + podman (off; DEC-022)
  apps.{appimage, flatpak} (on)     ───>   features/non-nix-packages.nix (+ folded duplicates)
  apps.cad (on)                     ───>   unchanged (IMP-016)
hosts/Sleipnir/config.nix lib.optional …   hosts/Sleipnir/features.nix / profile selects
```

## Scope & Objectives

Retire six legacy flags, with Sleipnir's derivations unchanged or proven
ordering-only, except the intended removal of podman (DEC-022) (the drv gate, `mem.pattern.flakes.drv-gate`). User decisions
2026-10-15 (research round, `research/research.md` D-a…D-d):

| flag | module | becomes |
|---|---|---|
| `hardware.microcode` | `modules/nixos/microcode.nix` | `hosts/Sleipnir/machine.nix` (not a feature) |
| `hardware.ssd` | `modules/nixos/ssd.nix` | `hosts/Sleipnir/machine.nix` (not a feature) |
| `virt.qemu` | `modules/nixos/qemu.nix` | tree feature, takes the `libvirtd` group |
| `virt.docker` | `modules/nixos/docker.nix` | tree feature, rootless only; no group (none exists) |
| `apps.appimage` | `modules/nixos/appimage.nix` | `non-nix-packages.appimage`; duplicates removed |
| `apps.flatpak` | `modules/nixos/flatpak.nix` | `non-nix-packages.flatpak`; duplicates removed |

- **Hardware → machine config.** microcode and ssd are bound to Sleipnir's parts
  (the 9950X `cpuModelId`, the root mount). They move to
  `hosts/Sleipnir/machine.nix` (DEC-019), imported by `hosts/Sleipnir/config.nix`, never into the generated
  `hardware-configuration.nix`. This sets the precedent for RFC-001 W4's
  host-bound class (machine config). `boot.shell_on_fail`, a generic boot
  param bundled in `microcode.nix`, moves to `modules/nixos/boot.nix`.
- **App formats.** appimage and flatpak are third-party app formats. Fold
  their unconditional duplicates (`programs.nix:157-158`, `nix.nix:93-94`)
  into the features, so each feature is the only switch. Area name:
  `non-nix-packages` (DEC-020).
- **IMP-003.** Remove the `docker` and `libvirtd` groups from `user.nix:15`.
  qemu adds libvirtd. docker adds none: rootless docker needs no group, and
  nixpkgs creates `docker` only for the rootful daemon.
- **Rootless only.** An unconditional assertion (`security.nix`) refuses
  `virtualisation.docker.enable`.
- **One engine (DEC-022).** `podman.nix` becomes the feature `virt.podman`,
  unselected on Sleipnir, with a `Sleipnir+podman` coverage target. The
  docker feature asserts podman is off. This is the slice's one intended
  behaviour change: Sleipnir loses podman. Podman's storage is not touched.
  IMP-018 later swaps the selection.
- Feature records use the DEC-015 shape. Design decides per feature whether
  Sleipnir selects it through a profile or as a host property.
- Remove the flags from `modules/features.nix`, their gates from
  `hosts/Sleipnir/config.nix` and their settings from
  `hosts/Sleipnir/features.nix`. Update the README.
- Coverage: any feature no host selects gets a `flake.coverage` target
  (ADR-005).

## Non-Goals

- `apps.cad` and the apps taxonomy (graphics, office, browsers/editors,
  TUI): deferred to IMP-016, alongside RFC-001 W5.
- Generic hardware features (radeon, bluetooth, QMK, game controllers) and
  splitting the modules that mix hardware with other config (kernel, util,
  audio, oom, network): RFC-001 W4 and the games slice. The inventory is in
  `research/raw/code-map.md`.
- Other W3 areas: desktop (own slice: ISS-001, IMP-005, CPT-001), games, ai,
  and the top-level single flags. Retiring `modules/features.nix` waits for
  those.
- Groups other than docker and libvirtd (caddy, gamemode, jackaudio) stay in
  `user.nix` until their owners migrate (IMP-003).

## Affected surface

- `features/virt.nix`, `features/non-nix-packages.nix` (new),
  `features/default.nix`, `features/profiles/`
- `modules/nixos/{microcode,ssd,qemu,docker,podman,appimage,flatpak}.nix`
- `modules/nixos/{user,programs,nix}.nix` (groups and duplicates out),
  `modules/nixos/{boot,security}.nix` (`shell_on_fail`; rootful-docker assertion)
- `modules/features.nix`, `hosts/Sleipnir/{config,features}.nix`,
  `hosts/Sleipnir/machine.nix` (new)
- `hosts.nix` coverage target `Sleipnir+podman`
- `README.md` (flag table, feature tree listing)

## Risks, assumptions, open questions

- **Settled:** microcode and ssd are Sleipnir machine config (user, 2026-10-15).
  RFC-001's "every optional module becomes a feature" needs qualifying for
  host-bound hardware.
- **Profile vs host property.** qemu, appimage and flatpak defaulted
  on, docker off; tree features default off. Which belong to
  `workstation` and which are Sleipnir properties?
- **Merge order.** Tree modules are appended after the host's import list, so
  merged lists (`systemPackages`, `extraGroups`) may reorder.
  Expect ordering-only drv diffs; prove them with `drvs-sets` / `nix-diff`, or
  pin order (`mem.fact.nix.merge-order`). Order also decides which package
  wins a colliding path in system-path, so the gate compares its link map
  (RV-011 F-8).
- `microcode.nix` imports an external NixOS module (`inputs.ucodenix`);
  capsule already does the same (`features/virt/capsule.nix:36-55`).
- Darwin hosts select none of these; the resolver must not refuse them.
- **Redundancy masks negative controls.** appimage is set unconditionally in
  `programs.nix` as well. Folding the duplicates in makes deselection real.

## Verification / closure intent

- `just drvs` before/after: Sleipnir system and home identical, or diffs
  proven ordering-only; Draupnir unchanged.
- `just test` green (resolver tests); `just coverage` evaluates any new target.
- The six flags no longer exist. The only `features.apps` read left is
  `apps.cad` (`grep`). appimage and flatpak have one switch each.
- README flag table and feature-tree section match the code.

## Summary

First W3 slice. Six flags are retired: two hardware flags become Sleipnir
host config, and virt plus the app formats become tree features that own
their groups and their duplicates. Derivations stay unchanged.

## Follow-Ups

- W3: games, ai, singletons, desktop slices; then retire
  `modules/features.nix` and `specialArgs.features`.
- RFC-001: record this slice under W3. Qualify "every optional module
  becomes a feature" for host-bound hardware.
- IMP-016: apps taxonomy and `apps.cad`.
