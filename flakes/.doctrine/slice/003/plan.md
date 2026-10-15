# Implementation Plan SL-003: Feature shape: area files and self-named features

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML. Use this for the plan's rationale and sequencing.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

Two phases: code, then docs. Governance (the ADR-001..003 REV) and RFC-001
follow at reconcile, per design § Governance and docs.

## Sequencing & Rationale

PHASE-01 is one unit because it cannot be split green: once the resolver reads
`name` from the record, the real tree (`features/`) fails to evaluate until it
is migrated, and `features-test.nix` reads the real tree. Inside the phase the
order is TDD: reshape the fixture helper and add the unnamed and provenance
tests (red), change the resolver (fixtures green, real tree red), migrate the
three areas (all green), then the `just drvs` gate.

Within PHASE-01, the `just drvs` baseline is taken before any edit, and new
files are `git add -N`'d before the after-run, since flakes see only tracked
files. Moves use `git mv` where a file survives (snooze scripts) to keep
history.

PHASE-02 is docs only; it cannot change a derivation, so it needs no gate
beyond the grep for stale paths.

## Notes

- Risk: `_file` reaching a derivation. Expected none (no feature declares
  options); the gate decides.
- Risk: the unnamed-feature short-circuit. Structural checks and the option
  tree read `name`, so the unnamed check must run first and alone.
