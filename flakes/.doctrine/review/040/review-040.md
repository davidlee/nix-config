# Review RV-040 — reconciliation of SL-018

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

<!-- Pre-reading + lines of attack: what this review is probing, the invariants
     it must hold the subject to, and where the bodies are likely buried. Seeded
     at `review new`; the reviewer fills it before raising findings. -->

Conformance audit of SL-018 (IMP-044, programme W1) against design.md
(locked; DEC-081 ro default + rw opt-in, DEC-082 launch dir last) and
plan.toml PHASE-01/02. Surface: primary tree, commits bdc8a72f..adb782ac,
plus `~/.config/emacs` 94a1f9e (outside the repo, no selector).

Lines of attack:
- sec-2 API: `workspaceDepsRw`, both env vars, merge/dedupe per mode,
  normalisation, guards over the union, flag by mode, escaping in both modes.
- sec-3 order: launch-dir bind after every workspace bind; `--chdir` kept.
- Tests non-vacuous (the `failsToEvaluate` cases pass on any eval error).
- Docs: every tracked description of workspace-dep binding now says ro.
- Rollout (sec-6): CHR-023 names every live consumer whose writes break.
- Conformance algebra read with ISS-005 (git `flakes/` prefix) in mind.


## Synthesis

The code matches the design. `makeJailedAgent` builds one list of bind specs
tagged by mode (`bindSpecsFor`), and the two guards (relative path, duplicate
destination) check both lists together. `bindFlags` maps each mode to its
`bwrap` flag. The launch dir is bound after the deps, and `--chdir` stays in
`launchDirOptions`. Each point is pinned by a test that can fail: three
mutants (old order; duplicate guard on ro only; relative guard on ro only)
each turned `checks.jailed-agents` red. That matters because the
`failsToEvaluate` cases pass on any evaluation error. Real launchers confirm
the behaviour: the Emacs devshell's (PHASE-02 VA-1) and the template's (F-3,
built at audit).

The gaps were in the rollout around the code, not in the code:
- SATAN.md still described the old rw binding (F-1, fixed).
- CHR-023 missed seven consumers, because design sec-6 named only six
  (F-2, fixed in CHR-023; design prose goes to reconcile).

Standing risks:
- Every consumer on a live `.envrc` already binds its deps ro. Jails that
  write `notes`, `.local/state/behaviour` or `satan` (satan, satan-corpus,
  org-incremental-writing) fail on write until CHR-023 lands. That is the
  intended fix-forward (sec-6, inq-2); the Emacs devshell is already done.
- A path moved to a static rw list while still in an ro env var fails
  evaluation, by design. This trap is noted in CHR-023.
- Mount order is checked only as argv order, because the build sandbox has
  no user namespaces (accepted at design).

Accepted tradeoffs: the missed `started` flip (F-5) stays tolerated;
conformance reads red only through ISS-005 (F-4).

## Reconciliation Brief

### Per-slice (direct edit)
- design.md sec-5 (F-3): change the template-launcher VA to the Emacs devshell
  launcher (plan PHASE-02 VA-1), with the template build (one ro and one rw
  entry) recorded as audit evidence.
- design.md sec-6 (F-2): the consumer list should cite CHR-023's full table
  (adds satan-corpus, bough, vk, forgettable, spec-driver, _SDLC, notes)
  instead of naming six.

### Governance/spec (REV)
- None. No spec governs the jail library's workspace binding; DEC-081 and
  DEC-082 hold as implemented.

### Backlog (at close)
- IMP-044 (W1) is still `started`: resolve it `done` when SL-018 closes.

## Reconciliation Outcome

### Direct edits applied (user agreed, 2026-10-27)
- design.md sec-5: the VA now names the Emacs devshell launcher (plan
  PHASE-02 VA-1), with the template build as audit evidence (F-3).
- design.md sec-6: consumer list defers to CHR-023's full table and names the
  seven repos the first list missed (F-2).

### REVs completed
- None needed: no governance or spec item in the brief.

### Fixed in the audit unit
- F-1 SATAN.md, F-2 CHR-023 body (commit 048197af).

### Withdrawn / tolerated
- F-4 aligned (ISS-005 path prefix); F-5 tolerated (missed `started` flip);
  rationale in each disposition.

### Carried to close
- IMP-044: resolve `done`.

Reconcile pass complete — handoff to /close.
