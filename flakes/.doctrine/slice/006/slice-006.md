# Legacy flags to feature tree: games, ai, singletons

## Context

RFC-001 W3 moves every legacy flag (`modules/features.nix`, read as
`specialArgs.features` to gate imports) onto the feature tree (`features/`,
selected by `feature.<area>.<name>.enable`). SL-005 took hardware, virt and
the app formats, and established the method: one phase per area, each gated
by `just drvs` / `drvs-sets` plus `.doctrine/slice/005/gate-probe.sh`,
negative controls, ADR-005 coverage for off features.

This slice takes everything left except desktop. Desktop (sway, niri,
cosmic, kde, mango) touches CPT-001, ISS-001 and IMP-005, and is the
following slice, which also retires `modules/features.nix`.

```
legacy flag (Sleipnir value)               gate today
games.enable (on)                          hosts/Sleipnir/config.nix  → modules/nixos/games.nix
games.gamescope (← games.enable)           hosts/Sleipnir/config.nix  → modules/nixos/gamescope.nix
games.mangohud  (← games.enable)           modules/home/linux/default.nix → modules/home/linux/games.nix
ai.llama-cpp (off)                         config.nix → modules/nixos/llama-cpp.nix
ai.rocm (off)                              config.nix → modules/nixos/rocm.nix
fonts, printing, webserver (on)            config.nix → modules/nixos/<name>.nix
speech, sunshine (off)                     config.nix → modules/nixos/<name>.nix
mpd (on)                                   config.nix → modules/nixos/mpd.nix
dictate (on)                               modules/home/linux/default.nix → dictate.nix
```

## Scope & Objectives

Retire the ten flags above (`games.*`, `ai.*`, `fonts`, `printing`, `speech`,
`webserver`, `dictate`, `mpd`, `sunshine`) with Sleipnir's derivations
unchanged or proven ordering-only (`mem.pattern.flakes.drv-gate`). No
intended behaviour change.

- Each becomes a tree feature in DEC-015 shape (area files), with its
  NixOS and/or home-manager halves inline; the old module files fold into
  the records or move beside them.
- Remove the flags from `modules/features.nix`, their gates from
  `hosts/Sleipnir/config.nix` and `modules/home/linux/default.nix`, and their
  settings from `hosts/Sleipnir/features.nix`.
- Features Sleipnir leaves off (llama-cpp, rocm, speech, sunshine) get
  `flake.coverage` targets (ADR-005).
- IMP-003 where it falls out: the `gamemode` group (enabled by
  `modules/nixos/gamescope.nix`) moves out of `user.nix` into the feature
  that owns it. `jackaudio` has no owner module; out of scope.
- README: flag table, tree listing, "moved here" line.

**Reduced ceremony** (user, 2026-10-16): no separate research round — the
SL-005 method and probe are reused; phase sheets carry a task list only.
The per-phase gate and the audit stay.

## Non-Goals

- Desktop flags and the retirement of `modules/features.nix` /
  `specialArgs.features` (next W3 slice).
- `apps.cad` stays a legacy flag unless design decides to move it verbatim;
  the apps taxonomy is IMP-016.
- Default leaning (IMP-006): tree features default off, but Sleipnir keeps
  its effective selection.
- Parked modules (hyprland, kmscon, danksearch).

## Open questions (for design)

- Areas: names and grouping (e.g. `games`, `ai`, `media`/`audio` for
  mpd/speech/dictate, `desktop-services`/`system` for fonts, printing,
  webserver, sunshine).
- games: one feature with nixos + homeManager halves, or games / gamescope
  / mangohud as three features with `requires` (replacing the `follows`
  defaults)?
- Selection: workstation profile vs host property, per feature.
- `apps.cad` verbatim into this slice, so the desktop slice can retire
  `modules/features.nix`?
- Home-only features (dictate, mangohud) are Linux-only: Draupnir selects
  none, so QUE-001 does not bite here; confirm.
- `gate-probe.sh` lives under SL-005: reuse in place or promote to a shared
  location.

## Verification / closure intent

Per phase: `just drvs` shows only Sleipnir's toplevel (and, for home
halves, `david@Sleipnir`'s home) changed, `drvs-sets` counts explained,
probe (packages, groups, link map) identical; `just coverage` evaluates
every off feature; one negative control per migrated on-feature; resolver
test selects each migrated tag. At close: grep finds no reads of the
retired flags; `just gate` green.

## Summary

## Follow-Ups
