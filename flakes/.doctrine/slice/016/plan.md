# Implementation Plan SL-016: Render malebolge's room door file

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML. Use this for the plan's rationale and sequencing.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

Two phases: a behaviour-neutral refactor, then the feature on top of it.

```
PHASE-01  evalTests helper        perSystem.nix          drv-neutral
   │
   ▼
PHASE-02  room data + render      room.nix, room-test.nix, runner.nix,
          + test + docs           perSystem.nix, justfile, SATAN.md
```

## Sequencing & Rationale

The refactor goes first and alone, so its one claim (no check derivation
moves) is checked against a clean baseline before anything else changes.
Folded into PHASE-02, the new check would sit beside it and muddy the
comparison.

PHASE-02 is one unit: the data file, its test and the render share one
invariant (the door's keys, DEC-079), and splitting them would leave a phase
that ships data nothing reads. It goes red first. The test is written while
`room.nix` is absent, then the data, then the render. The runner config's
store path is the check that the refactor of `runner.nix` is neutral.

Both phases baseline before editing (EN-2): the comparison is only
meaningful against a value taken from the unchanged tree.

## Notes

- The live check (PHASE-02 VH-1) needs `just home-switch`, which is the
  user's to run.
- The SL-027 handoff (PHASE-02 VA-4) is outward-facing: only with the user's
  OK, at close.
- README is deliberately untouched: its feature tree lists satan's features,
  not the files under `features/satan/`.
