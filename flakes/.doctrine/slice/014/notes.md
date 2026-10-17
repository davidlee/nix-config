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
fresh-as-of: 2026-10-17 · design/reviewing · 28754062 (SL-014 .doctrine work uncommitted)

### Produced
- research/research.md — three threads; OQ-1 closed (no local price map), OpenRouter self-pricing confirmed
- design.md sec-1..8 materialised (run rev 25); review pass RV-029
- minted: DEC-064..072 — the nine design decisions; IMP-035 — OpenAI via subscription OAuth; IDE-008 — publish gateway+agents standalone
- slice retitled (OpenAI dropped); scope rewritten to the decisions

### Learned
- mem.fact.litellm.proxy-hook-behaviours — appended: no local price map; OpenRouter usage/extra_body/route behaviour; reasoning_effort 400

### Open
- RV-029 — first Codex pass (not yet raised): model-gate bypass via OpenRouter models/route/extra_body.model (sec-1/3); budget bypass via client usage.include=false (sec-3/6); half-priced needsMap rule unenforced (sec-3). User running a fuller Codex pass that raises on RV-029 directly
- DEC-066 — SL-013 already landed "pi required"; SL-014 amends it
- DEC-067 / sec-7 — does `llm-gateway credentials` restart the service: check at phase planning
