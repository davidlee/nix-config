# Notes SL-011: LiteLLM credential broker with own key store

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: <yyyy-mm-dd> · <PHASE-NN | stage> · <head-commit>

### Produced

### Learned

### Open

## Design triage (2026-10-17)

Evidence: `research/research.md` (gitignored; G = governance rows, C = code facts, L = LiteLLM facts).

**Constraining governance:** POL-001 r1/r4/r5 (no secret in store; only the broker user holds provider keys; logs carry secrets), ADR-002 (record shape, placement in `features/agents`), ADR-003/ADR-004 (system and home evaluations; shared values are constants or outer options), ADR-001 D4 (`requires`, no auto-select), ADR-005/DEC-008 (coverage, `just test`), DEC-046 (governing choice). The `agents/` sub-flake is published and has external consumers, so broker mode is opt-in (G10).

**Shaping decisions taken:** DEC-046 (own SQLite key store on LiteLLM hooks; supersedes DEC-045).

**Open questions** (design run inquiries):
- inq-1 naming
- inq-2 trust model/topology
- inq-3 secret delivery
- inq-4 first consumer
- inq-5 per-jail key delivery
- inq-6 admin path
- inq-7 key store semantics
- inq-8 service unit
- inq-9 verification
- inq-10 governance housekeeping
- inq-11 existing exposure

**Risks:**
- LiteLLM hook drift on upgrade (pin with tests).
- No precedent for secrets to a system service (C3).
- uvicorn forces the socket to 0666, so the parent directory is the gate (C1).
- pi's auth.json key silently overrides injection (C5).
- Jail tests not gated by `just test` (C6).

**Assumptions:**
- `response_cost` is populated for DeepSeek and OpenRouter (L1, cost map checked).
- LiteLLM can import our module from its config directory (L3, unverified).
