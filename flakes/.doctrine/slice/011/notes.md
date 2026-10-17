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

## PHASE-05 (agent-doable part, 2026-10-17)

Human rulings (user, 2026-10-17, via capsule-driver):
1. Credential path: keep the absolute-path `LoadCredentialEncrypted` form. Before a provider credential exists, systemd fails the unit at credential setup (`status=243/CREDENTIALS`), not the launcher's message; the first `just system-switch` reporting a failed llm-gateway unit is expected. VH-1 is reworded accordingly (below). Drift for reconcile: design sec-2 says a missing credential is "not reliably fatal" and the sec-1 diagram is stale; plan VH-1 wording names the launcher message, which PHASE-02 VT-4 proves instead.
2. Hardening: PHASE-05 may loosen `features/agents/gateway.nix` hardening minimally, only for a failure observed in the live checks; each change and its reason recorded here. None made in the agent-doable part (no speculative loosening).
3. Alias reuse: DEC-051 stands. README rotation text: rotation = issue a new alias; a revoked alias is never reissued.

VH-1 (reworded per ruling 1): `just system-switch` activates the new generation and reports `llm-gateway.service` failed; `systemctl status llm-gateway` shows `status=243/CREDENTIALS` and `journalctl -u llm-gateway -b` shows systemd failing to load credential `deepseek` from `/etc/credstore.encrypted/llm-gateway.deepseek`. Expected before the first `just gateway-credentials`.

Planning:
- The PHASE-04 hand-off claim that the eca record already passed `gateway` was wrong: `features/agents.nix` at HEAD still had `apiKeys`. PHASE-05 did all of the eca wiring (requires = ["agents.gateway"], gateway from constants, no apiKeys) plus features-test `testEcaRequiresGateway` (red `[true true]`, then green `[false true]`).
- Jailed eca loses OpenRouter (gateway configures DeepSeek only; design sec-5). Documented under README "What it does not cover".
- Rotation for eca: keyFile is a fixed path, the alias only the ledger's name: move the old file aside, `issue eca-<n> --out keys/eca`, `revoke eca`.
- Design sec-7 lists a README § Jailed Agents note that EX-2 omits; added (one paragraph).
- Drift for reconcile: VH-4 says "just home-switch; eca's config.json ... points at the gateway". `~/.config/eca/config.json` is untracked and not home-managed, so the human edits it by hand (README § LLM gateway shows the provider block); home-switch alone changes only the jailed-eca wrapper.

Worker: sonnet. drvs: only homeConfigurations."david@Sleipnir" (and its alias `david`) changed; nix-diff bottoms out at `jailed-eca` (`jailed-eca-api-keys.env` gone, wrapper text differs). A later home drv move was attributed to the `~/dev/goad` checkout moving (37c201a8 -> 7a218263) mid-phase, not the docs. Built `jailed-eca` (not run): no `op run`, no provider var names; `--args 22`, `LLM_GATEWAY_URL`, key path present. flake.lock diff hash unchanged. `just test`, `just gate` green (re-run by orchestrator). README staged hunk-wise via `git apply --cached`; the user's Speech hunk stays unstaged.

PHASE-05 left in_progress: VH-1..7 await the human.

## PHASE-05 (live VH results and model-list adaptation, 2026-10-17)

VH results (human, live): VH-1, VH-2, VH-3 pass. `just system-switch` done; provider credential encrypted (`just gateway-credentials`); service running; key `eca` issued for `deepseek-v4-pro,deepseek-v4-flash`.
- VH-1 actual journal wording does NOT name the credential path: "llm-gateway.service: Failed to set up credentials: No such file or directory" / "Failed at step CREDENTIALS spawning …: No such file or directory", then start-limit-hit after the restarts. The VH-1 wording above (credential path named) is superseded by this; README § LLM gateway "First run" reworded to match, plus `sudo systemctl reset-failed llm-gateway` if `just gateway-credentials`' restart is refused by the start limit (the CLI does a plain `systemctl restart`, no reset-failed).

Adaptation — model list (user, 2026-10-17, via capsule-driver): the gateway serves only `deepseek-flash` -> `deepseek/deepseek-flash` (DeepSeek v4.1; the human's rationale: better than v4-pro, so the v4 pair has no reason to stay). LiteLLM 1.102.1's packaged price map carries `deepseek/deepseek-flash` (seat-verified: input 3e-7, output 1.2e-6 per token, 1M context), so the EX-3 spend check stays on the production mapping. Changed: `proxy.nix` models, `llm-gateway` MODELS, `gateway-test` (PRICED = deepseek-flash; the narrow-key test now issues for UNPRICED and asserts PRICED is refused), README issue example and eca provider block. Live follow-up for the human: system-switch, issue `eca-2` for deepseek-flash (rotation per README), revoke `eca`, edit `~/.config/eca/config.json` models.
Worker: sonnet (mechanical rename + doc wording). `just test`, `just gate` green (orchestrator).

Audit observations (not fixed):
- (a) Startup race: `just gateway-credentials` returns before uvicorn creates `/run/llm-gateway/api.sock`; a request ~15 ms after the restart got HTTP 000 from the relay. Candidates: a readiness wait in the recipe/CLI, or `Type=notify` on the unit. Related: the CLI could `reset-failed` before restart, removing the README caveat above.
- (b) `systemd-creds` warned "Credential secret file '/var/lib/systemd/credential.secret' is not located on encrypted media". The credential is still host+TPM2 bound; record for audit (host key on unencrypted media weakens the host half of the binding, not the TPM2 half).

PHASE-05 left in_progress.

## PHASE-05 (VH-4..7 live results; bwrap environ rework, 2026-10-17)

VH results (human, live): VH-4, VH-5, VH-7 PASS. eca replied once the user fixed an https -> http typo in their `~/.config/eca/config.json`. Ledger: key `eca` revoked; `eca-2` spent 0.0051 on deepseek-flash.

VH-6 FAIL (seat-verified live). In a running gateway-mode `jailed-eca`, the agent (`eca server`) has a clean env (LLM_GATEWAY_KEY, LLM_GATEWAY_URL only), but both bwrap processes — outer (host pid ns) and inner (PID 1 in the jail pid ns) — carried the launching session's full environment, provider *_API_KEY names included. `--clearenv` clears only the child's env, not bwrap's own. Inside the jail /proc/1 (bwrap) is dumpable, same uid/userns as the agent, CapPrm 0, NoNewPrivs 1; Yama ptrace_scope=1 does not block PTRACE_MODE_READ, so `/proc/1/environ` yields the session keys. Confirmed by nsenter (names only). Affects every jail, not only gateway mode.

Ruling (user, via capsule-driver): fix for ALL jails — bwrap is exec'd with an empty environment, after the launcher has expanded everything it needs.

Fix: `agents/jailed-agents.nix` builds `jail` with `jail-nix.lib.extend { inherit pkgs; bubblewrapPackage = bwrapEmptyEnv; }` (was `lib.init pkgs`); `bwrapEmptyEnv` is a `bwrap` script that `exec env -i <pkgs.bubblewrap>/bin/bwrap "$@"`. jail.nix (rev 404e7da) refers to bwrap only via `bubblewrapPackage`, so this is the whole seam; no upstream change. Ordering: `op run` -> inner launcher expands `--setenv` values, `--args 21` (provider keys) / `--args 22` (gateway key) process substitutions and the runtime-closure fd, then execs the seam; fds are not CLOEXEC and survive both execs. bubblewrap 0.11.2 reads only `getenv("HOME")` in the no-`--chdir` fallback; every jail passes `--chdir`. Side effect: session LD_*/glibc tunables no longer reach bwrap.
Test: `jailed-agents-test.nix` swaps a fake bwrap in via `pkgs.extend` that dumps its own /proc/$$/environ, argv and fds 21/22; runs real generated launchers with planted fake keys; asserts empty bwrap environ, keys only on their fds, HOME in argv; plus a structural check that real launchers exec the `env -i` seam. Red before fix (`test -s bwrap-environ` held), green after. Limits: real bwrap not run (no userns in the sandbox); `op run` and the gateway outer wrapper not exercised. README § Environment variables documents the invariant.
Worker: opus (security fix; env semantics across op run, a jail.nix launcher we don't own, and bwrap's own environ). agents check, `just test`, `just gate` green (orchestrator re-ran). `just drvs`: only homeConfigurations."david@Sleipnir"/`david` changed (jailed-eca x2, jailed-satan-gptel-harness, new bwrap seam, rollups).
Live re-check for VH-6 (human): home-switch, relaunch jailed-eca, check /proc/1/environ names inside the jail; confirm jailed-pi (op run path) still works.

Out-of-scope observation (for the seat): the emacs flake's `jailed-shell` (defined in ~/.config/emacs's flake, not this repo) exposes DEEPSEEK/GEMINI/JEV/MISTRAL/OPENAI/OPENROUTER/VOYAGE_API_KEY in the jail's own env — likely deliberate forwarding; raise with the human. Also note it builds its own jail and does not get this fix unless it uses `agents/`'s jail.

PHASE-05 left in_progress.

### PHASE-05 — VH-6 re-check after b17e348a (seat, 2026-10-17)

- VH-6 PASS. Relaunched jailed-eca after `just home-switch`. From inside its namespaces (nsenter, names only), PID 1 = bwrap with an empty environ (0 vars). The user had the jailed agent inspect its own env: the only credential was `LLM_GATEWAY_KEY`.
- op-run path: the user confirmed jailed pi still runs as expected after the empty-environment wrapper.
- VH-1..7 all pass. PHASE-05 completed.
- Follow-ups: IMP-028 (move pi to the gateway, remove the auth.json deepseek key; the user wants it next), IMP-029 (more providers). The emacs flake's `jailed-shell` forwards provider keys and builds its own jail, if it doesn't use `agents/`; the user's preference is to move pi to the gateway and rip out keys (see IMP-028).
