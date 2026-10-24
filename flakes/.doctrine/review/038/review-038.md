# Review RV-038 — reconciliation of SL-017

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

<!-- Pre-reading + lines of attack: what this review is probing, the invariants
     it must hold the subject to, and where the bodies are likely buried. Seeded
     at `review new`; the reviewer fills it before raising findings. -->

Audit the committed PHASE-01 implementation against SL-017's locked design and
plan. Check the package and room-door identity paths, service/timer attributes,
runtime command closure, path-only key reference, tunnel/readiness failure
handling, dump arguments, cleanup, atomic publication, complete-set retention,
and runbook claims. Check both `doctrine slice selector doctor 17` and `doctrine
slice conformance 17` against the committed delta. The Doctrine root is
`/home/david/flakes`, while Git's worktree root is `/home/david`; the selectors
are kept Doctrine-root-relative, and the source paths in the Git diff carry the
`flakes/` prefix. Record any remaining disagreement as a conformance/tooling
finding rather than masking it with selectors the selector doctor rejects.
Verification is source review plus `bash -n` and Nix parsing only; the design
excludes builds, tests, activation, service runs, tunnels, and database
operations.

## Synthesis

The implementation matches the accepted SL-017 design on the reviewed source:
the Home Manager feature is enabled by the personal Linux profile, uses the
locked nested room-client package and existing room-door identity path, and
declares a 03:00 persistent user timer without room autostart or wake behavior.
The script forwards the local PostgreSQL Unix socket, bounds readiness, creates
both PostgreSQL 18 custom-format archives in a private staging directory,
publishes the pair atomically, and prunes only timestamped sets containing both
archives. The runbook describes the service controls and restore source without
claiming a restore rehearsal.

Source checks passed: `bash -n` and `nix-instantiate --parse`. No build, test,
activation, service, tunnel, or database operation was run, as required by the
design. No implementation divergence was found. The only audit finding is the
known Git-root versus Doctrine-root conformance path mismatch in F-1; it is
verified and routed to existing ISS-005. The root-relative selector set passes
`doctrine slice selector doctor --assert`; the conformance report remains
mechanically noisy until ISS-005 is resolved.

## Reconciliation Brief

### Per-slice (direct edit)

- None. The implementation and runbook agree with `design.md`; the selector
  registry has been restored to Doctrine-root-relative paths.

### Governance/spec (REV)

- None.

### Existing tooling follow-up

- F-1 is verified and routed to existing ISS-005 for source-delta path
  normalization. No SL-017 reconciliation edit is needed for this tooling
  limitation.

## Reconciliation Outcome

### Direct edits applied

- `.doctrine/slice/017/slice-017.toml`: kept selectors relative to the Doctrine
  root and included the committed implementation plus intentional slice,
  backlog, decision, and design-review artifacts. `selector doctor --assert`
  passes. No change to `design.md` or `slice-017.md` was needed.
- `.doctrine/slice/017/notes.md`: refreshed the PHASE-01 and audit harvest.

### REVs completed

- None; the design and other governance truth match the implementation.

### Follow-up

- F-1 remains verified and routed to existing ISS-005. The selector/conformance
  root mismatch is outside this slice's implementation and is not hidden by
  rewriting valid Doctrine-root selectors.
