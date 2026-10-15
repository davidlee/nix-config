# Implementation Plan SL-001: Snooze pilot: first feature under the typed outer resolver

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML. Use this for the plan's rationale and sequencing.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

Three phases, each ending at the derivation-identity baseline:

```
PHASE-01  mechanism        features.nix + hosts.nix + checks, empty tree   drvs = baseline
PHASE-02  migration        snooze + openrgb onto the tree, flags removed    drvs = baseline
PHASE-03  coverage + docs  flake.coverage, just coverage, README            drvs = baseline
```

## Sequencing & Rationale

**Mechanism before migration.** PHASE-01 lands the resolver and the factory
wiring with an empty feature tree. The legacy flags are untouched, so the
identity gate isolates one question: did rewiring `hosts.nix` change
anything? If PHASE-02 then moves the gate, the cause is the moves, not the
wiring. A combined phase would mix the two.

**The resolver can't be rewritten alone.** Its signature changes from
`hostname` to `{ tree, classes, modules }`, so `features.nix` and its only
caller `hosts.nix` change in the same phase, or the flake stops evaluating.

**Baseline first.** The identity snapshots (`just drvs`, `just drvs-sets`)
are an entrance criterion of PHASE-01: they must come from the tree as
found, before any edit (`mem.pattern.flakes.drv-gate`).

**Red first.** Fixture tests are written against the old `features.nix`
(wrong arity, so all red) before the rewrite. T1/T2 need snooze in the tree,
so they belong to PHASE-02, where they are red until the tree and profile
exist. `just coverage` is red until the output exists.

**The RV-001 F-3 control sits in PHASE-01**, the phase that rewires
`hosts.nix`, which is what it guards: a home-only build must fail on a failed
selection, because `mkHome` reads the shared guarded selection.

**Coverage after migration.** The coverage target selects openrgb, which
exists in the tree only after PHASE-02. Docs go last so they describe what
landed. Code comments change in the phase that changes their code.

## Notes

- New and moved files need `git add -N` before any evaluation
  (`mem.fact.flakes.git-add-n`).
- `nix fmt` re-locks emacs-overlay; that drift is never committed
  (`mem.fact.flakes.fmt-relock`).
- Out of the phases, at close: record the result as evidence for HYP-001
  (refuted naming the test, or supporting with HYP-001 left `proposed`;
  design sec-8), and the ADR amendments by revision at reconcile (DEC-009).
- `perSystem.nix` sits at the flake root (`flake.nix` imports
  `./perSystem.nix`), so the runner imports `./features-test.nix`. Design
  sec-6 says `../`; that is a slip in the design text, not a design change.
- The `just test` build of the check uses `--no-link`, so it leaves no
  `result` symlink.
- Identity gate hygiene: the drvs recipes evaluate local override inputs
  (`oubliette` via `git+file`, `agents`, `emacs`) from their working trees.
  If the gate differs, first compare those inputs' HEAD and dirty state with
  the ones recorded at baseline: a moved input is a false difference, not a
  regression. `oubliette` was dirty when this plan was written.
