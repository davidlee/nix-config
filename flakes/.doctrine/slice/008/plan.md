# Implementation Plan SL-008: Home base / personal split (RFC-001 W5)

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML. Use this for the plan's rationale and sequencing.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

Seven phases, one commit each, following the phase table in design.md
§ Phases and verification. Phases 1 to 6 change structure and are proved by
the drv gate (`mem.pattern.flakes.drv-gate`): identical, or an order-only
change. Phase 7 is the only one allowed to change content, and only as its
table says.

```
P1 resolver ──> P2 home base ──> P3 GUI features ──> P4 cli + editors ──> P5 personal
  (platforms,     (layers)          (desktop.core       (personal profile)     (personal-linux/
   system arg)                       home half)                                  -darwin, doctor)
                                                                                      │
                               P7 behaviour (availableOn, dedupe, docs) <── P6 verification targets
```

## Sequencing & Rationale

- **The resolver comes first (P1).** Every later record may carry `platforms`,
  and the refusal is what makes a wrong selection on Draupnir loud. P1 changes
  no configuration, so its gate is the strictest one: every line identical.
  The ADR-002 and ADR-005 REVs are raised before it starts, so the code never
  runs ahead of accepted governance.
- **The base comes before the features (P2).** Features attach to a home
  that already has its final shape. Until P3 to P5 move the GUI and personal
  modules out, the Linux layer imports them temporarily.
- **GUI before cli (P3, then P4).** The GUI modules are Linux-only and
  Sleipnir-only, so P3 cannot touch Draupnir; that keeps the riskier darwin
  identity question to P4 alone. P3 also fixes ISS-008 while the compositor
  records are being touched.
- **cli and editors together (P4).** One completeness check covers every
  package that leaves `modules/shared/cli`, and `personal` is created when its
  contents exist. Draupnir imports `personal` directly until P5 creates
  `personal-darwin`.
- **Personal last among the moves (P5).** It needs `editor.emacs` (from P4)
  for `satan.harness`'s `requires`, and `services.postgresql` already exists.
  It carries the one non-order diff before P7: nudge's script path.
- **Verification targets after the moves (P6).** The home target and the
  isolation check assert the finished shape: the base reaches no editor
  input, and a lean home reaches no local-path input.
- **Behaviour last (P7).** All content changes are isolated in one phase with
  an explicit table, so every earlier phase can be proved by identity.

## Notes

- **Baselines drift.** emacs-overlay re-resolves and moves the home and darwin
  derivations, so each phase retakes its "before" snapshot just before
  editing, not at the end of the previous phase.
- **Draupnir has no probe.** Its gate is `drvs`, `drvs-sets` and `nix-diff`.
  Sleipnir's probe stands in for collision winners, and the user's link-map
  check at the next Draupnir switch closes the rest (PHASE-07 VH-2).
- **P4 is the largest phase.** It is mostly mechanical moves of package lists.
  Its risk is in the guards (a `linuxHome` package must stay guarded) and in
  the order of `home.packages`. The completeness check and `drvs-sets` on
  both systems catch the first; the probe catches the second.
- **The ADR-002 and ADR-005 REVs and the DEC-006/DEC-024 edits** are applied
  at `/reconcile`, as REV-006 was for SL-007.
