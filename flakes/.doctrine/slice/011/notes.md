# Notes SL-011: LiteLLM credential broker with own key store

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-17 · ready · 7fc3f7f8

### Produced
- design locked (run dr-01a14771…, design.md) — broker shape, key store, CLI, jail gateway mode, eca (commits bd88aec0, 85151124)
- plan: PHASE-01..05 authored and materialised (commit 7fc3f7f8)
- minted: DEC-047..051 — trust model, TPM credential, key by FD, no master key, key-store semantics
- minted: IMP-028 — jailed pi onto the broker (fast follow); IDE-006 — LUKS on Sleipnir
- RV-024 — design review; F-1, F-3 (probe) and F-2, F-5, F-6 (control) answered, verified after their phase criteria land
- known drift: design sec-1 diagram (route check in custom_auth; creds path) — correct at reconcile

### Learned
- mem.fact.doctrine.design-section-reviewed — section review is att-N declarations, not a checkpoint act
- mem_01a1445e… (existing) — severe design findings need a route before review-disposed

### Open
- DEC-046 — governing choice (own SQLite key store), amended by DEC-047's single-socket clause
- RV-024 F-1, F-2, F-3, F-5, F-6 — instrument-routed; criteria on PHASE-01/02
- point-of-use checks (plan.md risks): mock_response pricing path, systemd-creds --name vs credential id, LiteLLM offline in the Nix sandbox

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

## Design review (2026-10-17, RV-024)

Two adversarial passes by GPT (gpt-6-sol, read-only) over design.md, DEC-046..051
and the LiteLLM 1.100.1 source. Seven findings, all fixed in the design:
F-1 route gate in front of LiteLLM (unauthenticated `/health/liveness`,
`/public/*`), F-2 spend check on the production pricing path, F-3/F-7 `usd()`
as the finite guard plus non-negative CHECKs, F-4/F-5 credentials in
`/etc/credstore.encrypted` by absolute path with a launcher presence check,
F-6 `issue --out` preflight, atomic write and revoke-on-failure. DEC-048's
choice text updated for the store location.

Found sound by pass 2: pre-call hook runs for chat completions
(`proxy/common_request_processing.py:1920`); custom_auth works without a master
key (`proxy/auth/user_api_key_auth.py:1290`); a sha256 hex `api_key` is kept,
not re-hashed (`proxy/_types.py:2918`), and reaches callbacks as
`user_api_key_hash` (`proxy/litellm_pre_call_utils.py:1365`); the Nix default
referencing `gateway` evaluates.

**A further pass is not needed before lock.** What one would probe, and where
it is covered instead:
- the sudo re-exec path of the admin CLI (beyond F-6) → P3 tests and code review;
- hardening options other than `@system-service` (`ProtectHome`,
  `MemoryDenyWriteExecute` if added) against CPython/uvicorn → P3 brings the
  unit up on Sleipnir; loosen only what fails, with the reason in the unit;
- whether `mock_response` takes the production pricing path → P2, with the
  named fallback in design § Phases;
- all surfaces again on LiteLLM 1.102.1 → `checks.<system>.llm-gateway`.

## PHASE-01 execution notes (key store and admin CLI)

- Sheet A1-A6 taken as written, except `authenticate` raises `Refused` (reason text: unknown key / revoked / budget exhausted) instead of returning None; PHASE-02 maps it to 401.
- RV-024 F-6 vs `alias unique` (sheet Q1): option (a) chosen by the orchestrator. Schema kept per DEC-051; a failed `issue --out` revokes, and a revoked alias stays taken. Rotate with a new alias. PHASE-05 README rotation text must say so. Escalated to the seat as a possible DEC-051 follow-up (partial unique index).
- D5: `--out` publishes via mkstemp + fchmod 0600 + fsync, then `os.link` + unlink (link refuses an existing destination; rename would overwrite).
- `op read --no-newline` keeps a trailing newline out of the encrypted credential.
- D2: the baked config block (MODELS, PROVIDERS, DB) at the top of `llm-gateway` is the PHASE-03 substitution seam (sudo drops env).
- Under sudo, `llm-gateway` puts its own directory on `sys.path` to find `keystore`; PHASE-03 must install `keystore.py` beside it.
- Ambient ruff config is broad (RUF100, TRY004, PLW1510, UP035, I001 fire).
