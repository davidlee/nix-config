# Notes SL-019: TypeSafe Jev behind the LLM gateway

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-28 · design locked (run rev 39), planned (PHASE-01..04) · 71ef935e

### Produced
- IMP-054 rewritten: native LiteLLM TypeSafe provider, not a pass-through
- slice, research.md, design run → `design.md` (sec-1..8); no code yet
- minted: CHR-024 — stale LiteLLM 1.102.1 line references in gateway code
- folded in: ISS-015 (DEC-091)
- minted: ISS-020 — live body-guard bypass via form Content-Type (RV-041 F-1); fixed by sec-4
- uncommitted: all `.doctrine/` changes this session (staged in part; new
  files under `slice/019/`, `knowledge/`, `memory/`, `backlog/chore/024`
  untracked). No code changed; gate not run.

### Learned
- mem.fact.gateway.litellm-decisions-routes — native TypeSafe in 1.106.2; `/v1/decisions` fetches remote images
- mem.fact.typesafe.sdk-js-wire — SDK sends zstd and multipart; `models.list()` shape

### Open
- PHASE-01 waits on the operator's ISS-020 fix (gateway_hooks.py, uncommitted): verify it, then /phase-plan
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
