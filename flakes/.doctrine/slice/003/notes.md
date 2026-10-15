# Notes SL-003: Feature shape: area files and self-named features

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Design review passes (2026-10-15)

The shape (DEC-015) had one external adversarial pass before the slice
opened: an online agent's critique, adjudicated point by point in session
(accepted: unit framing, threshold as guidance, exclusion contract wording,
move ≠ literal cut-paste, dual provenance, softened asset rule; rejected:
inline/spilled equivalence test, which would only test `import`).

No further adversarial pass proposed. Residual risk is mechanical and is
caught by gates, not review: `_file` reaching a derivation (the `just drvs`
gate), and the resolver's short-circuit for unnamed features (its own test).
A further pass would probe only those two, and the gates already do.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: <yyyy-mm-dd> · <PHASE-NN | stage> · <head-commit>

### Produced

### Learned

### Open
