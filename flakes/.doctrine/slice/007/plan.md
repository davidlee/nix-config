# Implementation Plan SL-007: NixOS base / host split

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML. Use this for the plan's rationale and sequencing.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

Six phases, one commit each, in the order the user set (slice scope,
2026-10-16). Each moves one class of configuration into its place (design
§ Shape) and is gated against the previous phase's snapshot. Only PHASE-06
changes Sleipnir's configuration.

```
P1 base ─► P2 machine+host ─► P3 desktop/compositor/shell ─► P4 audio/hw/services ─► P5 aarch64 ─► P6 behaviour
   └───────────── structure only: drvs identical or order-only ─────────────┘   eval only     exact diff
```

## Sequencing & Rationale

- **Base first.** Naming the base before anything leaves it makes each later
  phase a subtraction from a known list, and the interim states are drawn
  (design § Phases and verification).
- **Machine and host before features.** Splitting the mixed base modules
  starts with the pieces that have no switch, so P3 and P4 move only
  feature-bound halves.
- **Desktop before audio and hardware.** P3 carries the option rename
  (`desktop.<wm>` → `compositor.<wm>`), the one breaking path change, and
  REV-006; landing it early keeps P4 a plain move.
- **aarch64 after the splits.** The base is only headless once P4 has moved
  every desktop and peripheral half out; checking it earlier would fail on
  pieces that are leaving anyway.
- **Behaviour last.** Every structural phase is proven by identity; P6's diff
  is then exactly its table, with nothing structural mixed in.

P3 is the largest phase (about 400 lines across eight modules plus the
rename). It stays one phase because `desktop.core`, the greeter and the
compositor `requires` edges only evaluate together; splitting it would
leave an interim tree in which compositors require a feature that does not
exist yet.

## Notes

- Negative controls are one-off evaluations, not committed
  (`mem.fact.nix.verify-closure-not-option`); they are recorded in notes.md.
- REV-006 is applied in P3 together with the README rule.
- Governance at close (design § Code impact and docs): RFC-001 W4, IMP-004,
  DEC-016's stale `features` argument, DEC-024's consequences.
