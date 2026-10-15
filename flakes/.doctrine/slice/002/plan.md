# Implementation Plan SL-002: Capsule onto the feature tree

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML. Use this for the plan's rationale and sequencing.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

One phase. Capsule's host side moves from four base modules into one tree
feature, `feature.virt.capsule`, and Sleipnir selects it. Derivations stay
identical (design sec-4 allows one ordering-only sudoers swap).

## Sequencing & Rationale

**Why one phase.** The move must happen all at once. If the feature exists
before the base modules lose their pieces, capsule is defined twice. If the
base modules lose their pieces first, Sleipnir loses capsule. The identity
gate (EX-3) only makes sense on the finished move. With about 12 paths,
splitting adds handoffs and no checkpoint.

**Order within the phase** (the runtime sheet expands this):

```
baseline (EN-2) ─► test added ─► tree entry ─► RED [false false]
   ─► git mv + absorb pieces + strip base modules + drop import
   ─► selection line ─► GREEN ─► mutation check ─► gate ─► negative control
   ─► comments/docs ─► fmt ─► commit
```

- The tree entry (`features/virt/`, `features/default.nix`) lands before the
  selection line. The other way round, `feature.virt.capsule` is an unknown
  option: the `features` check fails to evaluate, and the test never
  reaches a clean red (design sec-5).
- `git add -N` new paths before any eval: flakes only see tracked files.
- The baseline has to be taken before anything is edited, so it is an entry
  criterion and not a task.
- Comment and doc edits (flake.nix, SATAN.md, README) do not affect
  derivations. They come after the gate, so the gate measures only the code
  move.

## Notes

- The new area name `virt` shares its first segment with the legacy flags
  `virt.qemu` and `virt.docker`. The resolver rejects only a flag at the
  exact feature path (`testFlagCollisionFails`: a sibling is allowed), so
  `feature.virt.capsule` and `virt.*` live side by side until W3.
- The baseline also records the HEAD and dirty status of each local override
  input. `system_override` reads `~/dev/oubliette` as it is on disk, so
  oubliette drifting during the phase would show up as a false gate failure.
- Leave the user's uncommitted `flake.lock` and `.doctrine/slice/001/notes.md`
  out of every commit.
