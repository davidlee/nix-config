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
fresh-as-of: 2026-10-18 · implementation complete (PHASE-05, 5/5) · 7718bf9b

### Produced
- PHASE-01 pi block optional — 188a96b7
- PHASE-02 OpenRouter + Fireworks providers, params, price rule — 6d7be2fe
- PHASE-03 request body guard (allow-list + `thinking`/`reasoning`, 16 MiB/413) — 484b8f84; EN-2 rulings by user, sec-9 re-accepted
- PHASE-04 `llm-gateway models` verb — 5c334926
- PHASE-05 README — a51d8188; live rollout + VH-1..3 — 5fcfd28c (dropped `openrouter/deepseek/deepseek-flash`, sec-2/sec-6 re-accepted), 7718bf9b; detail in § PHASE-05 live
- design run rev 42, accepted; RV-029 stale vs sec-2/6/9 — audit's to address
- verify-vt UNATTRIBUTABLE throughout (ISS-005); evidence is `just test` + the VH notes
- minted: CHR-017 — ruff for gateway Python in the gate
- handback to emacs:SL-015 — bad id at `dl-gptel.el:121` (given to user)

### Learned
- mem.fact.litellm.proxy-hook-behaviours — appended: query strings inert; DeepSeek `thinking` native; OpenRouter `reasoning` keeps cost; double-registered callbacks double-charge
- mem.fact.flakes.llm-gateway-no-sudo — `models` verb; 4 dp spend display; new-provider credentials need the new build before switch
- mem.system.flakes.home-worktree — `git commit --only` when the user has staged work

### Open
- slice A2 — void: no BYOK route served
- reconcile: DEC-063, DEC-051, DEC-050 amendments; IMP-029 resolution, OpenAI to IMP-035 (design sec-8)
- one `401: unknown key` at 00:52:43 on 2026-10-18 — likely eca with a stale key (user)

## PHASE-05 live (2026-10-18)
- Rollout in sec-7 order: `just system-build`, `./result/sw/bin/llm-gateway credentials openrouter fireworks`, `just system-switch` (user ran). Unit active with 3 providers, 18 models.
- VH-1: v4-flash, fireworks nemotron, openrouter/auto → 200. `openrouter/deepseek/deepseek-flash` → 400 "not a valid model ID"; not on OpenRouter's public list (other 15 ids are). Dropped from `agents/gateway.nix`; sec-2/sec-6 amended (run rev 39-40; acceptance invalidated, user re-accepts). A2 void: no BYOK route served.
- gptel's OpenRouter list (`dl-gptel.el:121`) carries the same bad id — emacs:SL-015.
- VH-1 spend: `llm-gateway list` shows 0.0000 for the probe, but tiny requests cost ~1e-6 USD and no DEC-068 zero-cost warning was logged. Needs a larger probe to show non-zero at 4 dp.
- VH-1 (rerun, key sl014-probe-2, after switching to 5fcfd28c): v4-flash 5.7e-05 (= OpenRouter usage.cost), fireworks nemotron 3.0e-04 (packaged map), openrouter/auto 7.5e-04 (= usage.cost); `llm-gateway list` spent 0.0012. Pass. Key revoked.
- VH-2: minuet body (provider.sort, reasoning_effort none, max_tokens 56, top_p, stream) on openrouter/deepseek/deepseek-v4-flash → 200. Pass.
- VH-3: `llm-gateway models eca-2 deepseek-flash` ok (live alias is eca-2; `eca` was revoked); user confirmed eca works. Pass.
- Unexplained: one `401: unknown key` at 00:52:43 in the gateway log, not from the probes — a client with a stale key file?
