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

## PHASE-02 execution notes (LiteLLM adapter, launcher, integration check)

- Files: gateway_hooks.py, llm-gateway-serve, gateway-test, proxy.nix; perSystem.nix checks restructured as `{features; host-meta;} // optionalAttrs isLinux {llm-gateway}` (flake-parts `checks` is lazyAttrsOf, so `mkIf false` still lists the attr); `just test` line guarded by `uname -s = Linux`. Gateway check not defined on darwin (orchestrator decision: gateway is NixOS-only).
- F-2 carried by the check: mock_response takes the production pricing path (cost 2.7e-05 = 10x3e-07 + 20x1.2e-06; provider deepseek; no mock branch in cost_calculator.py or litellm_logging.py:1691-1790; the mock only fixes usage, main.py:989-1004). DeepSeek's real usage parsing remains VH-7.
- Unpriced models cost 0.0 silently; the ledger warns (naming the alias) on zero cost. EX-5 reads the packaged price JSON, because the proxy adds empty `model_cost` entries for configured models at startup.
- Offline: only `unset SSL_CERT_FILE` was needed in the sandbox (stdenv points it at a missing file). HOME, LITELLM_NON_ROOT, LITELLM_UI_PATH not needed. LITELLM_LOCAL_MODEL_COST_MAP=True still avoids a ~3 s GitHub attempt.
- LiteLLM 1.102.1 facts: client mock_response stripped (litellm_pre_call_utils.py:224-232); hook modules loaded per reference outside sys.modules (types_utils/utils.py:42-50), so hooks are stateless; custom_auth gets api_key=None with no key; hash at kwargs.litellm_params.metadata.user_api_key_hash, set server-side.
- Non-HTTPException auth errors become 500 via a prisma import in auth_exception_handler.py:62 (still refused, e.g. client api_base).
- Design-wording drift: two callbacks (model_gate, ledger) instead of the design's single-ledger YAML snippet; status codes 401 (key) / 403 (model).
- PHASE-03 seams: `import proxy.nix {pkgs lib}` -> .python, .configDir {models providers}, .defaults; CONFIG_FILE_PATH=${configDir}/config.yaml; baked PROVIDERS and SOCKET in llm-gateway-serve; StateDirectory provides STATE_DIRECTORY read by hooks.

## PHASE-03 execution notes (gateway service)

- agents.gateway record in features/agents/gateway.nix (NixOS half only), with gateway/constants.nix and gateway/bake.nix. Bake is a pure-Nix line rewrite (`NAME = <toJSON>`, shebang -> store python); evaluation fails naming the script unless every NAME matches exactly one line; build parses output with `ast`. Sources stay runnable by their tests.
- Credential set derived from the providers the models use; one value feeds the CLI, the launcher and LoadCredentialEncrypted. `credentialPath` in gateway.nix is the only Nix-side copy of the credstore path, paired with the CLI's `encrypt_argv`.
- drvs gate: only nixosConfigurations.Sleipnir changed (i8jgqf6l -> sbvfvmz2). systemd-analyze verify on built units clean. Launcher without CREDENTIALS_DIRECTORY exits 1 naming deepseek and just gateway-credentials.
- Orchestrator decisions: OQ-1 implemented as authored (absolute path); OQ-2 keyDirectory "$HOME/.config/llm-gateway/keys"; OQ-3 services.llm-gateway.*; OQ-4 relay requires+after; no PrivateNetwork on relay.
- OPEN (escalated) R1/OQ-1: systemd.exec(5) (systemd 261) says a missing credential is non-fatal only for the path-less / credential-id form. With the absolute path a missing file is fatal at setup (243/CREDENTIALS), so VH-1 will see systemd's error, not the launcher's message; contradicts design sec-2 "not reliably fatal". Options: amend VH-1 wording, or switch to id-only form (renames credential to llm-gateway.<p> on CLI + launcher).
- VA-1 risks for PHASE-05 live checks: @system-service coverage for uvicorn/uvloop (SIGSYS); AF_NETLINK denied (getaddrinfo fallback); socket mode under UMask 0077 depends on uvicorn chmod 0666 (relay EACCES otherwise, VH-5); sudo keeps caller cwd (VH-3); StateDirectory vs credential-setup order on first failed start. --name=<p> vs unit id `deepseek` matches by man page; VH-2 proves it. Possible tightening: SystemCallArchitectures=native.
- First `just system-switch` will report a failed unit until credentials exist (VH-1 wording, R2). Any hardening loosening can only happen in PHASE-05, whose objective does not list gateway.nix edits.

## PHASE-04 — jail gateway mode (agents/jailed-agents.nix)

- `gateway ? null` = `{ keyFile; url; runDirectory; }`, strings only, exact attr set (shape checked by `throw` before any read). OQ-1 ruling: `runDirectory` added beyond design sec-5's `{keyFile; url}` because agents/ is a published flake and cannot import gateway constants; PHASE-05 passes `"/run/${constants.runtimeDirectory}"`. Minor design drift — note at reconcile.
- OQ-2: gateway + `offline` profile not refused (plan silent; relay unreachable there).
- `apiKeys` defaults to `[]` in gateway mode; gateway + non-empty apiKeys refused by assert.
- Key forwarded over literal `--args 22` via `printf … "$(< keyFile)"` (builtin read, not in any argv); `LLM_GATEWAY_URL` by set-env. Refactor: `setenvsByArgsFd fd setenvs` shared with provider keys (FD 21); provider launchers byte-identical (drv gate: only goad dev-checkout noise).
- `gatewayOuter` checks key file (-r/-s) and runDirectory, naming `llm-gateway issue …` / `just system-switch`; never reads the key.
- Finding: bare `! grep` assertions in jailed-agents-test.nix never failed the build (bash errexit ignores negated commands). Converted to a `refute` helper; all pass. Other repo shell tests may share the flaw (unaudited).
- `just test` now builds `agents#checks.<sys>.jailed-agents` (Linux).
- Worker: opus — POL-001 secret-in-argv correctness risk in nested shell quoting.
