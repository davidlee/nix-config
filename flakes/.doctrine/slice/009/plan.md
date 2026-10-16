# Implementation Plan SL-009: VM enablers and agents onto the tree (RFC-001 W6 + W2)

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML. Use this for the plan's rationale and sequencing.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

Four phases, one commit each, matching the design's § Phases and verification
P1–P4. Each is proved by the drv gate (`mem.pattern.flakes.drv-gate`) against
a baseline retaken just before its first edit.

```
P1 dev checkouts + lock ──> P2 meta schema ──> P3 overlay scope ──> P4 agents area
   (diffs: named consumers)   (no diff)          (no diff)            (reorder; base coverage)
```

## Sequencing & Rationale

- **P1 first.** It replaces the override variables every later gate run
  uses, so the later phases are measured with the final recipe shape. It is
  the only phase whose allowed diff depends on state outside the repo (the
  `~/dev` checkouts).
- **P1 has two internal checkpoints, one commit.** Checkpoint A changes the
  justfile and script with declarations untouched: any drv change there comes
  from `path:` → `git+file` (or a moved checkout). Checkpoint B re-declares
  and re-locks: with checkouts present the overrides win, so drvs must equal
  A. Splitting the proof this way attributes each diff to one cause without
  splitting the design's phase.
- **P2 and P3 are no-diff phases**, kept apart so a P3 diff (callPackage
  auto-arguments) can't hide behind P2's evaluation changes. P3 stops on any
  diff rather than fixing forward.
- **P4 last.** It moves modules between files and expects only reordering, so
  it is measured against a baseline that already lacks the overlay noise.

## Notes

- **Moving checkouts.** Agents work in the `~/dev` checkouts (oubliette had a
  modified tracked file at design time; doctrine is under active work too).
  Every snapshot records each listed checkout's HEAD and dirty state, and a
  diff is attributed to a recorded move rather than demanding equality
  (RV-019 F-1, generalised at the user's note, 2026-10-16). doctrine itself
  is not an input of this flake (only transitive, from GitHub), so its
  checkout cannot change a drv.
- **The user's `push-local` recipe** is uncommitted in the justfile. P1
  commits only its own hunks by staging a filtered copy; `push-local` stays
  in the working tree for the user.
- **just evaluates every backtick on load**, so `bin/dev-checkouts override`
  runs for every recipe. A refusal (whitespace root) therefore fails every
  recipe, loudly. Accepted: it is the design's intent (RV-019 F-3).
- **Design text drift** to fix at reconcile: design.md § Code impact says
  "three verbs"; § Dev checkouts defines four (`override stub ahead names`).
- **VH-1** (Draupnir) is listed on P4 but exercises P1's change; the user
  can run it any time after P1 lands.
- Records to update at reconcile: design.md § Code impact and docs →
  Records at reconcile.
