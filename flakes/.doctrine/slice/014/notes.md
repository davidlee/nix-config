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
