# Notes SL-019: TypeSafe Jev behind the LLM gateway

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-28 · ready (design locked rev 39; PHASE-01..04 planned, none started; ISS-020 hotfix live, committed) · 504ebca5

### Produced
- IMP-054 rewritten: native LiteLLM TypeSafe provider, not a pass-through
- slice, research.md, design run → `design.md` (sec-1..8); no code yet
- minted: CHR-024 — stale LiteLLM 1.102.1 line references in gateway code
- folded in: ISS-015 (DEC-091)
- minted: ISS-020 — live body-guard bypass via form Content-Type (RV-041 F-1); fixed by sec-4
- roll-forward (operator, 2026-10-28): the ISS-020 hotfix, master-key boot override (DEC-050), `ParserAgreementTest`, two test repairs for LiteLLM 1.106.2; see § Roll-forward
- minted: CHR-025
- plan.toml / plan.md: PHASE-01..04; committed 71ef935e. No code changed
  by SL-019 yet; gate not run.

### Learned
- mem.fact.gateway.litellm-decisions-routes — native TypeSafe in 1.106.2; `/v1/decisions` fetches remote images
- mem.fact.typesafe.sdk-js-wire — SDK sends zstd and multipart; `models.list()` shape

### Open
- ISS-020 hotfix verified (check + live probe) and deployed; committed 504ebca5. Next: /phase-plan PHASE-01 (sec-4 must keep canonical replay)
- CHR-025 — drop redundant `allowed_openai_params` (LiteLLM 1.106.2)
- CHR-017 widened — ruff + pylint in the devshell and gate, then a lint pass
- ASM-002 — TypeSafe's 1Password ref, to confirm at rollout
- DEC-084 — its choice text names "both decisions routes"; DEC-092 narrows it to `/v1/systemone`

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
  call) are the operator's: the run halts before them. PHASE-04 stays
  `planned`.
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
