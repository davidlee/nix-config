# Notes SL-017: Daily host-side PostgreSQL backups for the Oubliette room

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-24 · reconcile · fe0f21ef

### Produced

- IMP-040, SL-017, DEC-080, RV-037 — intake, approved design, 30-set retention decision, and concluded zero-finding design review.
- PHASE-01 — added the host backup feature, socket-tunnel dump script, profile default, and operator runbook (commit fe0f21ef); registered its source delta after the automatic capture resolved to the read-only primary tree.
- RV-038 — source conformance audit found no implementation divergence; F-1 routes the known path-root tooling mismatch to ISS-005, and reconciliation required no design or governance changes.

### Learned

- none

### Open

- ISS-005 — source-delta and selector roots remain inconsistent for this nested checkout.
