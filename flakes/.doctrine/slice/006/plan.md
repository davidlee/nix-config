# Implementation Plan SL-006: Legacy flags to feature tree: the rest of W3

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

Five phases, one commit each, in the design's order (design § Phases and
verification):

```
PHASE-01 probe + games ─> PHASE-02 ai ─> PHASE-03 audio/services/apps ─> PHASE-04 desktop ─> PHASE-05 retire
 bin/gate-probe            off, 2         speech overlay repair,           +IMP-004 (waybar)    modules/features.nix
 games.{steam,gamescope,   coverage       dictate assets move,             features/lib args    gone; resolver
 mangohud}; gamemode grp   targets        caddy group out                  leave host files     returns modules only
 └──────────── each phase gated against the previous phase's snapshot ────────────────────────────┘
```

No phase changes Sleipnir's behaviour (ADR-001 D7). The speech overlay repair
changes only an off feature's evaluation.

## Sequencing & Rationale

- **Probe first, baseline before any config edit.** The promoted probe adds
  measures for the order-sensitive lists the moves will reorder (RV-013 F-2).
  The baseline must be taken with the extended probe on the unchanged
  config, or PHASE-01's comparison has nothing to compare against.
- **games first.** Small, both evaluation classes (system and home), and it
  exercises `requires`, the group move (IMP-003), and the home probe — every
  mechanism later phases rely on, on the smallest surface.
- **ai second.** Both features are off, so the expected diff is none: a cheap
  check that removing false gates is drv-neutral, and two coverage targets.
- **Singletons third.** Mixed classes, an asset move (dictate), and the one
  repair (speech overlay, RV-013 F-1), isolated from the desktop surface.
- **Desktop last of the migrations.** Largest surface: five compositors,
  session files, portals, fonts. By then the probe has been exercised four
  times. The last gates leave the host files here, so their now-unused
  `features`/`lib` args go here too (deadnix, RV-013 F-8).
- **Retirement last.** Only possible once no flag is read; expected diff is
  none.

Red first in every phase: the resolver test naming the phase's features is
written before the records exist. Off features are tested as selectable, not
only unselected — an unselected assertion passes vacuously before the record
exists.

## Notes

- Routed findings from RV-013: F-1 (demonstrate) lands as PHASE-03 EX-3;
  F-2 (probe) as PHASE-01 EX-2 and each phase's gate criterion.
- Negative controls use `lib.mkForce false`: Sleipnir's selections are plain
  definitions (RV-013 F-4).
- Any probe measure that changes, or any changed drv the probe cannot
  explain, is red: `nix-diff`, stop, `/consult` (design § Gate and probe).
