# Notes SL-014: OpenRouter and Fireworks behind the LLM gateway

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Design review passes (2026-10-17)

RV-029 (Codex) concluded: six findings, all fixed and verified. The fixes
are DEC-073 (request body allow-list, sec-9), the both-or-neither price
assertion (sec-3) and the stated rollout outages (sec-7).

No further design pass. What one would probe, and where it is covered
instead:

- whether an allow-listed field (`user`, `provider`, `n`) still reaches a
  LiteLLM internal parameter: the sec-6 end-to-end twins and the recorded
  client bodies prove the boundary in phase work;
- allow-list completeness against eca, pi, gptel and minuet bodies: a phase
  planning task (slice R2).

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-17 · ready (plan done, 0/5 phases) · f433c05b

### Produced
- research/research.md — three threads; OQ-1 closed (no local price map), OpenRouter self-pricing confirmed
- design.md sec-1..9, locked (run rev 34); RV-029 concluded, F-1..6 verified
- minted: DEC-064..073; IMP-035 — OpenAI via subscription OAuth; IDE-008 — publish gateway+agents standalone
- plan.toml / plan.md — PHASE-01..05; phase sheets materialised

### Learned
- mem.fact.litellm.proxy-hook-behaviours — no local price map; OpenRouter usage/extra_body/route; client litellm_params and custom_llm_provider reach internals; reasoning_effort 400

### Open
- slice R2 — allow-list vs real client bodies: PHASE-03 EN-2
- slice A2 — BYOK route reports cost: PHASE-05 VH-1
- plan.md Notes — no system-switch between PHASE-02 and PHASE-05 rollout
- reconcile: DEC-063, DEC-051, DEC-050 amendments; IMP-029 resolution (design sec-8 "Records at reconcile")

## PHASE-05 live (2026-10-18)
- Rollout in sec-7 order: `just system-build`, `./result/sw/bin/llm-gateway credentials openrouter fireworks`, `just system-switch` (user ran). Unit active with 3 providers, 18 models.
- VH-1: v4-flash, fireworks nemotron, openrouter/auto → 200. `openrouter/deepseek/deepseek-flash` → 400 "not a valid model ID"; not on OpenRouter's public list (other 15 ids are). Dropped from `agents/gateway.nix`; sec-2/sec-6 amended (run rev 39-40; acceptance invalidated, user re-accepts). A2 void: no BYOK route served.
- gptel's OpenRouter list (`dl-gptel.el:121`) carries the same bad id — emacs:SL-015.
- VH-1 spend: `llm-gateway list` shows 0.0000 for the probe, but tiny requests cost ~1e-6 USD and no DEC-068 zero-cost warning was logged. Needs a larger probe to show non-zero at 4 dp.
- VH-1 (rerun, key sl014-probe-2, after switching to 5fcfd28c): v4-flash 5.7e-05 (= OpenRouter usage.cost), fireworks nemotron 3.0e-04 (packaged map), openrouter/auto 7.5e-04 (= usage.cost); `llm-gateway list` spent 0.0012. Pass. Key revoked.
- VH-2: minuet body (provider.sort, reasoning_effort none, max_tokens 56, top_p, stream) on openrouter/deepseek/deepseek-v4-flash → 200. Pass.
- VH-3: `llm-gateway models eca-2 deepseek-flash` ok (live alias is eca-2; `eca` was revoked); user confirmed eca works. Pass.
- Unexplained: one `401: unknown key` at 00:52:43 in the gateway log, not from the probes — a client with a stale key file?
