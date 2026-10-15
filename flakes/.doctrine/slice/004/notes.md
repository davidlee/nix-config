# Notes SL-004: Darwin standalone Home Manager and unified pkgs factories

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: <yyyy-mm-dd> · <PHASE-NN | stage> · <head-commit>

### Produced

### Learned

### Open

## Design review (RV-009)

2026-10-15. Codex (gpt-6.1-sol) adversarial review, four rounds, findings
F-1..F-10; Claude recorded Codex's acts (its sandbox could not take the
ledger lock). User chose the `stable` module argument over `pkgs.pkgsStable`
(F-2; DEC-016 amended). Lock drift split out as ISS-006.

**Further review passes: none needed before planning.** The last pass
(round 4) concluded with no blocker or major defect, and every later edit is
bookkeeping (routes, scope/selector sync). What remains open is settled by
instruments, not by more design review:

- F-1, F-4 (`demonstrate`): Mac build with the `agents` override; cut-over
  and switch-generation recovery on Draupnir. Criteria on RV-009.
- F-3 (`control`): `checks.factories` must reject four named wrong
  candidates (today's mkDarwin, a leftover `specialArgs.pkgs`, an empty
  darwin set, a `classesOf` that ignores `meta.home`).
- `just drvs` identity for NixOS and Linux home (Codex could not reach the
  Lix daemon; only consumer-level drvPaths were checked).

`/plan` reads the instrument-routed criteria on RV-009 (`doctrine review show
RV-009 -f F-1 -f F-3 -f F-4`).
