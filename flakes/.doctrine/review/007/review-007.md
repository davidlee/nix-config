# Review RV-007 — reconciliation of SL-003

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

<!-- Pre-reading + lines of attack: what this review is probing, the invariants
     it must hold the subject to, and where the bodies are likely buried. Seeded
     at `review new`; the reviewer fills it before raising findings. -->

Conformance audit of SL-003 against its locked design (sec-1..7) and DEC-015.
Lines of attack: the shape as written in the tree matches sec-1; the resolver
reads only key names, `name`, `requires` and positions (exclusion contract);
provenance is flake-relative; migration is a pure move (`just drvs`
identical); docs carry no stale path. Includes an external reviewer's
post-implementation critique (F-3..F-7), adjudicated on evidence.

## Synthesis

The implementation matches the design. Gates: `just drvs` identical to the
pre-edit capture after PHASE-01 and again after the F-4 fix; `just test` exit 0;
`just coverage` evaluates; `nix fmt` clean. Real provenance strings read
`features/session.nix:20 (session.snooze#nixos)`.

One code defect (F-4, misleading error for the likeliest spill mistake) was
fixed in audit. The rest are wording: the design overstated why `_file` must
not be a store path (F-6), and the provenance rule needs its precondition
stated, records written literally (F-5). Both go to the ADR-002 D6 revision.

Tooling gaps (ISS-005 path roots, CHR-010 gate recipe) are unchanged from
SL-002 and tolerated with by-hand evidence. Two plan-authoring lessons (F-3,
F-7): test a VA grep against the expected end state, and make red-first an
exit criterion.

Standing risk: none in code. The shape's cost (one parse per area) was
already accepted by ADR-002.

Open for the user (not a finding): areas could be listed as paths, their
names taken from `baseNameOf`, instead of `{ name; value; }` pairs. Agent
recommendation: keep the pairs, so identity is always written and never
derived from storage (the DEC-015 principle). Folded into the REV only if the
user chooses it.

## Reconciliation Brief

### Per-slice (direct edit)
- design.md sec-3 (F-6): replace the "would churn derivations" rationale
  with: relative for readable errors; `just drvs` covers derivation risk.
  State that position follows `name` (F-5).

### Governance/spec (REV)
One REV over ADR-001, ADR-002, ADR-003 (F-9, F-5, F-6):
- ADR-002 D1: a feature is `{ name; nixos?; homeManager?; darwin?; requires?; }`,
  `name` required; class values inline modules by convention.
- ADR-002 D2: `features/default.nix` lists areas as `{ name; value; }` pairs;
  each area is one file, `features/<area>.nix`, a list of self-named features.
- ADR-002 D3: granularity per DEC-015: halves together; own file by
  judgement (~100 lines prompts it), never split by platform; assets near
  their feature.
- ADR-002 D4: exclusion contract: descriptors may be inspected during
  selection; unselected class implementations and their package expressions
  are never forced by resolution or projection.
- ADR-002 D6: `_file` = "<flake-relative file>:<line> (<area>.<name>#<class>)",
  from the position of `name`; records are written literally (a helper that
  builds them reports its own line); relative for readability, not
  derivation stability.
- ADR-001, ADR-002, ADR-003: MULTIHOST.md citations → RFC-001,
  `mem.fact.nix.merge-order`, `mem.pattern.flakes.drv-gate` (CHR-011).

### Knowledge
- DEC-015 supersedes DEC-003 and DEC-010 (F-8): `doctrine supersede`.

### Evidence (direct edit, per user 2026-10-15)
- RFC-001: W1 done; W2/W3 start from the DEC-015 shape; tree diagram
  (`<area>/default.nix` at line 72) updated.

### Backlog
- CHR-011, CHR-012: resolved by SL-003 at close.
