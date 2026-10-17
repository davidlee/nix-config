# Review RV-031 — reconciliation of SL-014

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

Mode: conformance self-audit. Surface: primary tree (`$HOME` worktree), HEAD
519e87c4; slice commits 188a96b7..7718bf9b. Not dispatched.

Lines of attack:
- Code vs locked design (run rev 42): sec-2 model list and names (DEC-069),
  sec-3 merge order / `checkPrices` on every model / `needsMap` (DEC-064,
  DEC-070), sec-4 pi filter (DEC-066), sec-5 `set_models` in one
  transaction (DEC-071), sec-9 `ALLOWED_FIELDS`, 413 cap, replay (DEC-073).
- Every plan VT has a test carrying its keywords (verify-vt is
  UNATTRIBUTABLE under ISS-005, so by grep), and `just test` +
  `doctrine check gate` are green.
- VH-1..3 evidence in notes.md § PHASE-05 live.
- `slice conformance` cells, read through the `flakes/` prefix (ISS-005).
- Drift in per-slice text (slice-014.md, design sec-8) and governance
  (DEC-050, DEC-051, DEC-063, IMP-029) after the sec-2/6/9 changes.
- Design changes made after RV-029 concluded (sec-9 `thinking`, `reasoning`,
  16 MiB cap; sec-2/6 dropped id): evidence that they hold.

## Synthesis

SL-014 delivers what the locked design (run rev 42) describes. OpenRouter
(15 models) and Fireworks (1) are served beside DeepSeek. Code matches the
design on each point the brief listed: DEC-069 names; `params` merged under
the generated `model`/`api_key` (DEC-070); `checkPrices` on every entry,
`extraModels` included, and `needsMap` choosing which ids price-check.py
sees (DEC-064); pi filtered by `m ? pi` (DEC-066); `set_models` refusing a
revoked key in the same transaction as the update (DEC-071);
`ALLOWED_FIELDS`, the 16 MiB/413 cap and single-message replay in
`route_gate` (DEC-073). Every plan VT has a test carrying its keywords.
`just test` passes (exit 0), `doctrine check gate` passes (treefmt: 0
changed), and VH-1..3 passed live (notes § PHASE-05 live).

```
client ─> route_gate ─(404 route | 413 size | 400 field)─> LiteLLM
                                                     ├─ custom_auth  (key live, budget)
                                                     ├─ model_gate   (key's list; models verb edits it)
                                                     └─ ledger       (usage.cost | packaged map | params price)
```

No blockers. The findings are drift, not defects:
- governance still describes SL-011/013 behaviour: DEC-063 (pi required),
  DEC-051 (packaged map only), DEC-050 (verb set). IMP-029 is still open
  (F-4..F-7);
- per-slice text: selectors and sec-8 miss the files PHASE-02 D1 and DEC-073
  touched (F-1); slice-014.md still counts 16 and plans a BYOK check (F-8);
- tooling: ISS-005 garbles conformance and verify-vt (F-2); there is no
  Python lint in the gate (F-9, CHR-017);
- process: the lifecycle stayed `ready`, now moved to `audit` (F-3).

**Standing risks.**
- The guard's allow-list depends on LiteLLM's internals: which top-level
  fields it merges, that query params are inert (PHASE-03 F3), and that
  nested `thinking`/`reasoning` stay outside its own params. A LiteLLM
  bump can change any of these. The e2e twins in gateway-test catch the
  known bypasses, not new ones. Re-run the RV-029 probe set on a LiteLLM
  bump.
- Explicit `params` prices go stale silently (slice R1). No model uses one
  yet.
- Moving OpenRouter aliases (`~…-latest`, `openrouter/auto`) change upstream
  under a fixed gateway name. That is accepted: OpenRouter reports the
  cost, so spend stays correct.

**Tradeoffs accepted.** A child-process fake gateway in tests, so one
process never registers the callbacks twice (registering them twice
double-charges). The plan text stays stale on 16 models and the BYOK check,
because plan criteria are immutable. Two ~25 s gateway outages per new
provider (DEC-067).

**Where to look.** `doctrine show DEC-073` (the guard's contract),
`doctrine show DEC-064` (cost sources), `doctrine review show RV-029` (the
bypasses the guard closes). `features/agents/gateway/gateway_hooks.py`
`_guard_body` is the main new behaviour. `BodyGuardTest` and
`RouteGateUnitTest` in `gateway-test` test it.

## Reconciliation Brief

### Per-slice (direct edit)
- F-1, registry (load-bearing): `doctrine slice selector add 14
  --intent design-target features/agents/gateway/gateway_hooks.py
  features/agents/gateway/bake.nix features/agents/gateway/llm-gateway-serve`
  (check the verb's exact shape). Mirror: design.md sec-8 table gains rows
  for `bake.nix` (`script` hoisted, `{pkgs, lib}: name: python: values:`)
  and `llm-gateway-serve` (baked via `proxy.serve`); sec-3 notes
  `proxy.serve providers values`, the single PROVIDERS projection shared by
  the service and checks.llm-gateway (CredentialTest).
- F-8: slice-014.md scope 2 -> gptel's 14 valid OpenRouter ids plus
  minuet's, 15 in all; `deepseek/deepseek-flash` is not an OpenRouter id
  (5fcfd28c). A2 -> void: no BYOK route is served. Leave plan.toml
  untouched (immutable).

### Governance/spec (REV / record edit)
- F-4 DEC-063: choice ends "a served model without a pi block is not
  offered to pi (DEC-066)"; consequences drop the evaluation error.
- F-5 DEC-051: build-time clause -> DEC-064's rule (provider reports cost,
  or both `params` prices, or the packaged map; one price alone is an
  evaluation error). Consequence "Model prices come from the pinned
  packaged cost map" -> "…for models whose provider does not report cost
  and which set no prices".
- F-6 DEC-050: verb set "(issue, list, revoke, budget, spend)" gains
  `models` (DEC-071).
- F-7 IMP-029: resolve, partial: OpenRouter and Fireworks delivered by
  SL-014; OpenAI deferred to IMP-035 (DEC-072).
- Not to edit: SL-011/SL-013 design text ("packaged map only", "pi
  required") is historical (design sec-8).

## Reconciliation Outcome

User agreed to every item (2026-10-18, "agreed").

### Direct edits applied
- Slice file list: `doctrine slice selector add 14 --intent design-target` for `gateway_hooks.py`, `bake.nix`, `llm-gateway-serve` (F-1).
- design.md sec-3: `proxy.serve` / `bake.nix` as the single PROVIDERS projection. Sec-8 table: rows for `bake.nix` and `llm-gateway-serve`; the `proxy.nix` row gains `serve` (F-1).
- slice-014.md scope 2: 15 OpenRouter models, the dropped id named. A2 marked void (F-8). plan.toml left untouched (immutable).

### Governance (F-4..F-7)
No REV: the engine accepts only SPEC/PRD/REQ/ADR/POL/STD targets (SL-012 precedent, RV-027). Each decision's choice was changed with `doctrine knowledge edit decision`, and a dated reconcile note appended to its body:
- DEC-063: a model without a pi block is not offered to pi (DEC-066); the consequence now reads "Offering a served model to pi…".
- DEC-051: the build-time clause is DEC-064's cost-source rule; consequence updated.
- DEC-050: the verb set gains `models` (DEC-071).
The consequence entries were edited in `record-0NN.toml` directly: the CLI's comma-separated list would have split DEC-051's third entry. `doctrine validate` reports the corpus clean.
- IMP-029: resolved (done), partial; OpenAI → IMP-035 (DEC-072); note in its body.

### Withdrawn / tolerated
- F-2: conformance stays red from the `flakes/` prefix alone (ISS-005).
- F-9: CHR-017. F-10, F-11: aligned. F-3: fixed in audit.

Reconcile pass complete; handoff to /close.
