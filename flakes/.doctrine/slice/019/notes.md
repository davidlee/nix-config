# Notes SL-019: TypeSafe Jev behind the LLM gateway

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-28 · PHASE-04 (all phases complete; pre-audit) · 761e0165

### Produced
- ISS-020 hotfix + LiteLLM 1.106.2 roll-forward (504ebca5; § Roll-forward)
- PHASE-01 route gate: ROUTES, /v1/systemone, bounded zstd (10559b4c)
- PHASE-02 typesafe provider, four Jev models, through-proxy tests (bd26aef4)
- PHASE-03 llm-gateway refuses root, ISS-015 (26ef21fa)
- PHASE-04 README § LLM gateway (653e7d43); rollout + VH-1 passed live (761e0165; § Rollout)
- `just test` green at 26ef21fa; `just coverage` evaluates at bd26aef4; code unchanged since
- envelope decisions and deferrals: § Autonomy log (audit reads it)
- minted earlier: CHR-024, CHR-025; folded in ISS-015

### Learned
- mem.fact.gateway.litellm-decisions-routes — native TypeSafe in 1.106.2; reply `model` is the bare upstream id (prefix stripped)
- mem.fact.typesafe.sdk-js-wire — SDK sends zstd and multipart; `models.list()` shape
- mem.fact.litellm.proxy-hook-behaviours — updated for 1.106.2 in b73eb889

### Open
- SPEC-001 drift for reconcile — listed in § Autonomy log (PHASE-04 VA-1), one item beyond design sec-8
- DEC-084 — its choice text names "both decisions routes"; DEC-092 narrows it to `/v1/systemone`
- audit flag: empty content-encoding elements refused (A3, § Autonomy log)
- audit flag: README SDK limits rest on mem.fact.typesafe.sdk-js-wire (medium trust)
- CHR-017 — ruff + pylint in the gate; 3 pre-existing ruff findings in gateway-test; `llm-gateway` docstring omits the root refusal
- CHR-025 — drop redundant `allowed_openai_params`
- IMP-054, ISS-015, ISS-020 — close at reconcile (PHASE-04 EX-3)

## Further review

ISS-020 early hotfix (operator request, while design review is open): the
existing guard canonicalizes replay headers and has focused regression tests.
SL-019 sec-4 must retain this behavior when adding zstd decoding and update
the tests for decoded length. Verify the gateway check and deploy before
closing ISS-020; source changes alone do not fix the running service.

After RV-041 (Codex, gpt-6.1-sol, two rounds), no further design pass is
needed before planning. The repairs are small and each has a VT in sec-6
that fails on today's gate; the implementation's tests are the stronger
check now.

A further pass, if wanted, would probe what RV-041 did not: request
headers that LiteLLM turns into request parameters (provider-specific
header forwarding, `litellm_pre_call_utils.py` `add_provider_specific_headers_to_request`),
which the field allow-list does not see. That surface predates SL-019 and
applies to every route; inference, not checked. Query parameters were
checked: only `api-version` reaches handler data.

## Roll-forward 2026-10-28: gateway restored on LiteLLM 1.106.2

The lock bump to LiteLLM 1.106.2 put the gateway in a restart loop:
a new boot check (`proxy/auth/master_key_boot_check.py`, called at
`proxy_server.py:1471`) refuses to start without a master key. DEC-050 decides
there is none. `checks.llm-gateway` failed at the same point, so no test ran.

- `proxy.nix`: `general_settings.dangerously_permit_weak_or_unset_master_key = true`.
  Evidence: the flag is read only by that boot check (grep of the pinned
  package); `custom_auth` returns before any master-key comparison
  (`user_api_key_auth.py:1637`). Startup behaviour is as before 1.106.2.
  The rejected alternative was an ephemeral in-memory key: it breaks
  DEC-050 and makes `master_key` non-None, which changes LiteLLM's auth
  branches (`is_no_auth_dev_mode`).
- `gateway-test` `ParserAgreementTest`: the ISS-020 real-parser VT from sec-6,
  plain variant (zstd comes with sec-4). It sends a form-urlencoded, multipart
  or protobuf polyglot through the real proxy on both chat aliases. The body
  must reach the fake upstream as the JSON the guard checked, and a second
  loopback listener must receive nothing. Red with the fix disabled
  (form: 500, multipart: 400); protobuf passes either way, so it is a control.
- The upgrade surfaced two other failures, both upstream behaviour changes:
  - `SpendTest`: LiteLLM now applies the price map's `off_peak_pricing`
    (deepseek-flash: half price, weekdays 10:00–00:00 UTC). The ledger was
    right; the test's restated price was not. It now uses `price_now`.
  - `PassThroughTest` twin: OpenRouter accepts `reasoning_effort` on every
    model (`llms/openrouter/chat/transformation.py:41-46`). The twin now
    asserts that the request is served. Dropping the redundant
    `allowed_openai_params` is CHR-025.
- Verified: `checks.llm-gateway` 56/56 OK. Live (operator switched): the
  service is active, its config carries the flag and the hook fix, and an
  unauthenticated `GET /v1/models` on 127.0.0.1:4000 gets 401.
- Live probe (`/tmp/iss-020-probe.py`, key `pi-2`, which allows
  deepseek-flash): the JSON and form-typed polyglots both got 403 `model None
  not allowed`. The model appears only inside the `messages` string. Had
  LiteLLM parsed the form, it would have seen the embedded
  `model=deepseek-flash`, and the model gate would have judged that model
  instead. So LiteLLM read the form body as JSON: the canonical replay holds
  live. Neither request reached a provider. The probe script calls this
  INCONCLUSIVE because it treats every 403 that way.
- Still open: ISS-020 closes at SL-019's rollout (sec-7), per design. Committed
  504ebca5.

## Implementation run

Super-orchestrator run, started 2026-10-28, from b73eb889 (tree clean under `~/flakes`).

- Operator ruling: **Claude-only workers.** quotient's policy does not allow
  `~/flakes` as a root, and the operator chose not to widen it. No pi runs.
  Sub-orchestrators use `capsule-worker`: **Sonnet by default** (operator:
  "use sonnet where sonnet makes sense, it's pretty strong"), Opus only for
  real judgement, reason stated; or they do small steps themselves.
- Host gate: `just test`, run from `~/flakes` (it builds `checks.<system>.*`
  with the local overrides, then the script tests; `keystore-test` included).
  Targeted, for iteration: `nix build ".#checks.x86_64-linux.llm-gateway"
  --no-link --no-write-lock-file`. The gate is authoritative; end each phase
  on a full `just test`.
- Lint: no Python lint gate yet (CHR-017). Ad hoc:
  `nix run nixpkgs#ruff -- check <file>` on files the phase touches; fix
  findings only in lines the phase changes.
- Charters: PHASE-01 (alone, heavy); PHASE-02 (alone, heavy); PHASE-03 + the
  README part of PHASE-04 (EX-1, VA-1). PHASE-04 EX-2/EX-3/VH-1 (rollout, live
  call) are the operator's: the run halts before them. PHASE-04 is
  `in_progress` (README done, rollout pending); it completes after VH-1.
- ASM-002 stays assumed: PHASE-02 uses `op://API_KEYS/TYPESAFE_API_KEY/credential`;
  the operator confirms at rollout.
- Out of bounds for every phase: flake.lock, hosts.nix,
  hosts/Sleipnir/features.nix, modules/nixos/kernel.nix. The git worktree is
  `$HOME`: scope every git command to a path; commit with `git commit <paths>`.
- Preflight warnings: background tasks are on (spawns run in the
  background; the parent is notified when they finish).

## Autonomy log
<!-- one line per envelope decision: phase · what · why · decided|deferred|escalated -->
- PHASE-01 · A1 probe (3.14.8 `compression.zstd`) holds: window_log_max 24 refuses the 11-byte 2^27-window frame; max_length, eof, unused_data as designed · design's two decode bounds stand · decided
- PHASE-01 · A3: content-encoding list kept literal; empty elements not dropped (`zstd,` and an empty header are 415), though RFC 9110 § 5.6.1 lets a recipient ignore them · stricter reading of sec-4; flag at audit · decided
- PHASE-01 · A5 refusal texts: 415 `content-encoding not supported`; 400 `zstd body is not one complete frame` / `zstd body does not decode`; 413 reuses TOO_LARGE; an empty zstd body is 400 (not one frame) · design leaves wording open · decided
- PHASE-01 · `_decoded` returns a `Refusal(status, error)` NamedTuple; `WINDOW_LOG_MAX = MAX_BODY_BYTES.bit_length() - 1` (24) ties the window cap to the body cap · helper names, in scope · decided
- PHASE-01 · systemone refusal test also covers `images` and `metadata`; window test asserts the frame decodes uncapped (control) · strengthens VT-1/VT-2 · decided
- PHASE-01 · the Sonnet worker staged its first green (git index) against the no-staging brief; harmless, commit is path-scoped · friction · decided
- PHASE-02 · A-1/A-2 hold on 1.106.2: upstream POST `<api_base − /v1>/v1/systemone`, `authorization: Bearer <TYPESAFE_API_KEY>`, `content-type: application/json`, model `jev-1.14.0`; spend priced from `usage.input_tokens` by the packaged map · design's provider path stands · decided
- PHASE-02 · `routed` generalised to `named <provider> <helper> <ids>` (agents/gateway.nix), shared by openrouter and typesafe; `FakeOpenRouter` renamed `FakeUpstream`, systemone requests recorded as (lowercased headers, body); test class `JevTest`; `post_json` helper under `chat`/`systemone` · names and fixture shape, in scope · decided
- PHASE-02 · JevTest asserts the packaged Jev price is > 0 (else the spend check is vacuous) and the Jev-on-chat case also leaves chat upstream untouched · strengthens VT-1 · decided
- PHASE-02 · Sonnet capsule-worker (operator default) did the phase in one pass; ruff's 3 findings are pre-existing lines (23, FakeGateway `open`, `BODY` class attr), left per the lint rule · friction · decided
- PHASE-03 · done by the sub-orchestrator, no spawn (4 source lines + one test class); the root check runs before argument parsing, so a usage error as root is also exit 2 with the sec-5 message; RootRefused also asserts no `--out` file and a non-root control · "first in main" read strictly; strengthens VT-1 · decided
- PHASE-04 · flipped `in_progress` and left there: EX-1/VA-1 done (README), EN-2 (ASM-002), EX-2, EX-3, VH-1 are the operator's rollout · charter; supersedes the "stays planned" line · decided
- PHASE-04 · README: Routes and TypeSafe-SDK paragraphs after the Providers table; no parallel rollout runbook (sec-7 is "Adding a provider" + the `issue` examples); screwtape worked example left out · structure within § LLM gateway · decided
- PHASE-04 · VA-1 SPEC-001 drift for reconcile (all in design sec-8, plus one): § Client contract routes lack `POST /v1/systemone` and the `/v1/decisions` 404; § Body and FR-002 (REQ text) name `ALLOWED_FIELDS`, now per-route `CHAT_FIELDS`/`SYSTEMONE_FIELDS` via `ROUTES` (not in sec-8); refusals table lacks 415 encoding, 400 zstd frame/decode, 413 on decoded size; § Request path lacks zstd decode and the application/json replay; § Model names / Providers lack typesafe and Jev; SDK `models.list()`/multipart unsupported (DEC-089); § Admin CLI lacks the root refusal · deferred
- PHASE-04 · `llm-gateway` module docstring does not mention the root refusal (comment-only gap, left; fold into CHR-017's lint pass or reconcile) · deferred

## Rollout (PHASE-04)

2026-10-28, operator: the 1Password item exists (ASM-002 validated); system
switched with the typesafe credential; `screwtape` key issued
(`~/.config/llm-gateway/keys/screwtape`).

VH-1 evidence (agent-run, live through the relay at 127.0.0.1:4000, key `screwtape`):
- `POST /v1/systemone`, `typesafe/jev-1.14.0`, one noul question: 200;
  upstream answered `model: jev-1.14.0`, `usage.input_tokens` 281;
  `x-litellm-response-cost` 1.1802e-05 = 281 × 4.2e-8 (output 0).
- The same body with `Content-Encoding: zstd`: 200, same answer and cost.
- Refusals: `/v1/decisions` 404; gzip body on systemone 415
  (`llm-gateway: content-encoding not supported`).
- Not checked by the agent: the ledger spend for `screwtape` (`llm-gateway
  list` needs sudo). VH-1 is the operator's to confirm.
- Operator, `llm-gateway list`: `screwtape typesafe/jev-1.14.0 20.0000 0.0000`.
  Spend is shown to 4 decimals, and 2.4e-05 rounds to 0.0000 ("it's a
  rounding error"). Operator: "agreed": VH-1 passed. PHASE-04 completed.
