# REV REV-001 — reconcile SL-001

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

<!-- Why this revision: what authored truth needs to change and why, the scope of
     the staged delta, and (for ADR/POL/STD/prose rows) the before/after excerpts
     the structured payload only labels. Seeded at `revision new`. -->

ADR-001..005 were proposed before SL-001 (the snooze pilot) built the
mechanism. DEC-009 deferred their amendment to reconcile, so the ADRs
describe the contract that was built and tested, then go to the user for
acceptance.

## Reconcile narrative (SL-001)

Source: RV-003 Reconciliation Brief, F-4 (DEC-009 set and RV-002
additions) and F-7 (flag collision, enforced). Wording reviewed by the user
and an external second opinion, 2026-10-15.

- **ADR-001 D2** — the option is `feature.<area>.<name>.enable`, default
  false, beside the legacy flags. No path is both a flag and a feature,
  and the resolver enforces this (RV-003 F-7).
- **ADR-001 D4** — the resolver never selects anything. Before: "may
  default a prerequisite on for convenience". After: an unselected
  prerequisite of a selected feature is an error however it came to be
  off; a profile that selects a feature also selects its prerequisites
  (DEC-005).
- **ADR-001 trailing paragraph and Negative** — `specialArgs.features`
  carries the legacy flags only; the selection is removed from it (DEC-002,
  DEC-006). Drop "(or accept a resolver default)".
- **ADR-002 D1** — optional descriptor key `requires`; the key set is
  closed (RV-002 F-1).
- **ADR-002 D2** — two levels, `{ name; value; }` index lists rooted at
  `features/default.nix`; no `.` in names (DEC-003, RV-002 F-2).
- **ADR-002 D4** — structural checks read every descriptor and fail every
  host; reading key names and option declarations forces no class value
  (RV-002 F-1/F-2/F-5, RV-003 F-7).
- **ADR-003 Decision** — darwin's embedded Home Manager receives no
  projected modules; a feature needing a darwin home half is blocked on
  IMP-012 (DEC-001). Reviewer's wording.
- **ADR-005 D1** — transitional: binds only features in the tree.
- **ADR-005 Verification** — targets in the flake output `coverage`,
  forced by `just coverage` (DEC-008).
