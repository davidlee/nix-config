# REV REV-002 — reconcile SL-003

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

Brings ADR-002 to the shape SL-003 built (DEC-015), and repoints the retired
MULTIHOST.md citations in ADR-001..003 (CHR-011, folded in by the user
2026-10-15). Driven by RV-008 § Reconciliation Brief, which carries RV-007's.
Wording reviewed by an external agent before landing; its points were
adjudicated in session (6 integrated, 1 contested: the ADR-001/003 targets
were already specified).

## Reconcile narrative (SL-003)

ADR-002 (primary):
- D1 [RV-007 F-9]: `name` required, the feature's identity; class values
  inline by convention, a path accepted and never read.
- D2 [RV-007 F-9; user decision 2026-10-15, keep pairs]: addressing kept;
  only the index sentences change (pairs for areas, area files of
  self-named features); names non-empty and dot-free [RV-008 F-5].
- D3 [RV-007 F-9]: granularity per DEC-015 (halves together, spill by
  judgement, assets near).
- D4 [RV-007 F-9; RV-008 F-2, F-3]: "evaluated for every host", descriptor
  parenthetical kept (ADR-004 "Features own their schemas" relies on it);
  structural-check list and the read set brought to the resolver as built.
- D5: "area-index list order" → list order (areas, then features).
- D6 [RV-007 F-5, F-6; RV-008 F-4]: identity rule and "error provenance
  only" kept; `_file` format added; relative only for records in this flake;
  "written literally" stated as unenforced convention.
- Negative consequences: the stale "needs the area index" bullet replaced.
- Context and References [CHR-011]: MULTIHOST.md → RFC-001,
  `mem.fact.nix.merge-order`, `mem.pattern.flakes.drv-gate`; DEC-015 added.

ADR-001 [CHR-011]: "MULTIHOST S7" → "RFC-001 W3, IMP-006" (RFC-001's W3 row
covers S7); References → RFC-001.

ADR-003 [CHR-011]: both nixos-unified citations → RFC-001 § "Considered and
not adopted: srid/nixos-unified".

All three are prose `modify` rows, landed by hand.
