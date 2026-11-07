# Notes SL-017: Daily host-side PostgreSQL backups for the Oubliette room

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-11-08 · close · 05bda7a7

### Produced

- IMP-040, SL-017, DEC-080, RV-037 — intake, approved design, 30-set retention decision, and concluded zero-finding design review.
- PHASE-01 — added the host backup feature, socket-tunnel dump script, profile default, and operator runbook (commit fe0f21ef); registered its source delta after the automatic capture resolved to the read-only primary tree.
- RV-038 — source conformance audit found no implementation divergence; F-1 routes the known path-root tooling mismatch to ISS-005, and reconciliation required no design or governance changes.
- 8d8e5ee2 — post-audit shellcheck fix: `:?` guards on the prune `rm`, no behaviour change.
- RV-036 — empty duplicate of RV-037, concluded without findings at close.

### Learned

- Live record at close: 9 of 12 scheduled runs succeeded (2026-10-27 to 2026-11-07). The failures are at the SSH tunnel and match the designed offline-room behaviour; they reach only the journal.

### Open

- ISS-005 — source-delta and selector roots remain inconsistent for this nested checkout.
- satan:ISS-065 — holds the follow-ups: failure alerting and a restore rehearsal.
