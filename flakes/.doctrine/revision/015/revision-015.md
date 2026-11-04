# REV REV-015 — reconcile SL-023

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

SL-023 created SPEC-003 and its audit (RV-047) found it behind the code in three
ways: REQ-029 claims something false for the dispatch jail, § Concerns carries a
question F-2 closed, and no requirement had moved off `pending`. The code is the
truth; this revision brings the spec to it.

## Reconcile narrative

- [RV-047 F-1] REQ-029's "which no jail binds" is false: Doctrine's dispatch jail
  is `--ro-bind / /` with an inherited env. It now sets its own socket. REQ-029's
  statement says so and gains two criteria: the confinement test, and the hand
  probes in the prefix's shape (not a real dispatch run). § Concerns gains the
  dispatch jail.
- [RV-047 F-2] `hostNames` takes `hostOnlyEnv`. § `devEnv` schema, § Host facts
  and § Mechanism follow; the `SCCACHE_SERVER_UDS` concern goes; the first open
  question narrows to library-set names. REQ-026's statement follows, which the
  brief did not name but F-2 implies.
- [RV-047 F-11] REQ-024..030 move to `active` on PHASE-07 and `just test` evidence
  (user, "agreed"). The first active requirements in this repo. Limits stay in
  their criteria: REQ-025 is stub only, REQ-030's missing-helper case is untested,
  REQ-029's dispatch evidence is a test plus hand probes. REQ-029 assumes the
  operator commits doctrine's repair before /close.
