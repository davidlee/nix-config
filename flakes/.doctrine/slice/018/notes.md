# Notes SL-018: Read-only workspace deps by default; rw opt-in

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: <yyyy-mm-dd> · <PHASE-NN | stage> · <head-commit>

### Produced

### Learned

### Open

## Design review passes (2026-10-27)

Human review only. A further (adversarial) pass would probe: bwrap's
later-mount-wins behaviour for the launch dir (DEC-082) — asserted from bwrap
semantics, verified only as argv order in tests, since the build sandbox has
no user namespaces; and whether any maker bypasses `makeJailedAgent`'s
workspace args. Judged unnecessary: small surface, behaviour pinned by the
launcher-text tests, and the consumer is the operator.
