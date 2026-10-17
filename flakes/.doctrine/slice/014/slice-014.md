# OpenRouter and Fireworks behind the LLM gateway

## Context

SL-011's gateway (LiteLLM on `127.0.0.1:4000`, per-client keys, budgets)
serves one provider and one model: DeepSeek, `deepseek-flash`. IMP-029 asks
for OpenRouter, Fireworks (fireworks.ai) and OpenAI. It is a hard
prerequisite for emacs:SL-015, which moves gptel and minuet onto the gateway.

Two SL-011 constraints made this more than adding config entries: every
served model had to be in LiteLLM's *packaged* price map (DEC-051), and
the map lags upstream (LiteLLM release → nixpkgs → our lock). gptel's
OpenRouter list includes moving aliases (`~z-ai/glm-latest`) and
meta-models (`openrouter/pareto-code`) that no map will ever price.

Research (`research/research.md`) settled the mechanics. LiteLLM cannot load
a local price map. It does accept per-model prices in config, and it always
captures OpenRouter's own per-request cost, which overrides any map. With
those two facts, the design is:

```
served model (agents/gateway.nix)          cost source               build check
  openrouter/<id>   provider=openrouter ──> OpenRouter usage.cost      admitted
  fireworks/<id>    provider=fireworks  ──> packaged map | params price  must have one
  deepseek-flash    provider=deepseek   ──> packaged map               (unchanged)
```

**SL-013 is done.** It moved the served-model list into
`agents/gateway.nix` (DEC-059) and required a pi block per served model
(DEC-063). This slice builds on that layout (`after SL-013`) and makes the pi
block optional (DEC-066).

## Decisions (design run, inq-1..10)

| id | choice |
|---|---|
| DEC-064 | a model is admitted if it is OpenRouter (self-pricing), or in the packaged map, or explicitly priced in `params` |
| DEC-065 | explicit per-model entries, no `openrouter/*` wildcard |
| DEC-066 | the pi block is optional; without one, pi is not offered the model. SL-013 shipped it required; this slice changes it (PHASE-01) |
| DEC-067 | rollout: build, then create the new providers' credentials with the new build's CLI, then switch |
| DEC-068 | a cost of 0 or None at run time stays warn-and-count-0; add a test that OpenRouter's cost reaches the ledger |
| DEC-069 | new names are `<provider>/<upstream id>`; `deepseek-flash` keeps its name |
| DEC-070 | optional per-model `params`, merged into that model's `litellm_params` |
| DEC-071 | new admin verb `llm-gateway models ALIAS M,…` replaces a key's model list in place |
| DEC-072 | serve OpenRouter and Fireworks; OpenAI is deferred to IMP-035 |
| DEC-073 | `route_gate` admits only allow-listed top-level request body fields; others get a 400 (RV-029) |

## Scope & Objectives

1. **Providers**: `openrouter` (`OPENROUTER_API_KEY`) and `fireworks`
   (`FIREWORKS_API_KEY`) in `proxy.nix` defaults, each with a public
   1Password ref (POL-001).
2. **Served models** (DEC-069 names), in `agents/gateway.nix`:
   - gptel's OpenRouter ids (`dl-gptel.el:121-139`) except
     `deepseek/deepseek-flash`, which is not an OpenRouter id (5fcfd28c),
     and minuet's `deepseek/deepseek-v4-flash`: 15 in all, each as
     `openrouter/<id>`;
   - `fireworks/nemotron-lightning-3p5-30b-a3b`, which maps to
     `fireworks_ai/accounts/fireworks/models/nemotron-lightning-3p5-30b-a3b`.
   OpenRouter entries carry `params.allowed_openai_params =
   ["reasoning_effort"]`. Without it, a model LiteLLM does not flag as a
   reasoning model gets a 400.
3. **Price check** (`proxy.nix`): it admits a model per DEC-064 and keeps
   a negative twin for each branch. A model with only one of the two
   prices is an evaluation error, whatever its cost source.
3a. **Request body guard** (DEC-073, `gateway_hooks.py`): `route_gate`
   refuses a chat-completions body with any top-level field off an
   allow-list. It stops clients choosing another upstream model,
   suppressing OpenRouter's cost, or dropping their key from the ledger.
   It covers every model, so it also closes two SL-011 gaps on
   `deepseek-flash` (RV-029 F-4, F-5).
4. **`params`** (DEC-070): merged into `litellm_params` beneath the generated
   `model` and `api_key`, so those cannot be overridden.
5. **pi block optional** (DEC-066): SL-013 shipped it required; PHASE-01 changes it.
6. **Key model-list edit** (DEC-071): a keystore function and the CLI verb,
   with tests. It refuses unknown models and revoked keys.
7. **Tests**: OpenRouter's reported cost reaches the ledger, streamed and
   not (DEC-068), checked against a fake OpenRouter on loopback. The
   `provider` object and `reasoning_effort` reach the upstream body.
   `CredentialTest` stops hard-coding deepseek.
8. **Docs**: README § LLM gateway gets the providers, the adding-a-model and
   adding-a-provider steps (credentials before switch), the `models` verb,
   and the "What it does not cover" change.
9. **Rollout (VH)**: 1Password items for both providers, then
   `gateway-credentials`, then switch; one live request per provider.
   Close IMP-029.

## Non-Goals

- OpenAI provider (IMP-035).
- Moving any client onto the new providers (emacs:SL-015; jails IMP-030,
  IMP-034). Issuing the `gptel`/`minuet` keys stays with emacs:SL-015.
- Mistral, Voyage, Gemini, Anthropic: emacs:SL-015 drops them.
- Periodic or per-provider budgets (DEC-051 stays lifetime USD per key).
- Exposing the gateway off-host.
- Publishing the gateway as its own project (IDE-008).

## Affected surface

| path | change |
|---|---|
| `agents/gateway.nix` (from SL-013) | served models; optional `params` and `pi` |
| `agents/jailed-agents.nix` (+ test) | pi config filters out models with no pi block (DEC-066) |
| `features/agents/gateway/proxy.nix` | providers; merge `params` |
| `features/agents/gateway/gateway_hooks.py` | request body allow-list (DEC-073) |
| `features/agents/gateway/keystore.py`, `keystore-test` | replace a key's model list |
| `features/agents/gateway/llm-gateway` | `models` verb |
| `features/agents/gateway/gateway-test`, `perSystem.nix` | cost, pass-through, body-guard and price-rule tests |
| `README.md` § LLM gateway | docs |

## Risks & assumptions

- **A1** (settled 2026-10-17): SL-013 landed the served-model list in the
  shape DEC-059 and DEC-063 describe.
- **A2** (void 2026-10-18: no route using the caller's own provider key is
  served; `deepseek/deepseek-flash` was dropped, 5fcfd28c): OpenRouter returns `usage.cost` for every served model, including
  bring-your-own-key routes such as `deepseek/deepseek-flash`. The live check
  confirms it; if a BYOK route reports 0, that model is under-counted
  (DEC-068 logs a warning).
- **A3** (settled 2026-10-17): OpenRouter lists `qwen/qwen3.8-flash`; gptel's
  `qwen/qwen-3.8-flash` is wrong. Serve `openrouter/qwen/qwen3.8-flash`;
  emacs:SL-015 fixes gptel's id.
- **R1**: an explicit `params` price goes stale silently. Prefer the
  packaged map where it has the model.
- **R2**: the body allow-list refuses a field a client needs (400). Phase
  planning checks it against eca, pi, gptel and minuet bodies; a missing
  field is added with its reason.
- **R3**: rollout restarts the gateway twice (~25 s each); run it when no
  client is mid-request.

## Verification / closure intent

- VT: price-rule twins (OpenRouter unpriced accepted; direct unpriced
  refused; direct with a `params` price accepted).
- VT: the ledger records OpenRouter's reported cost, streamed and not.
- VT: pass-through of `provider` and `reasoning_effort`.
- VT: each RV-029 bypass body is refused with no upstream request and no
  spend change; recorded client bodies pass; half-priced models fail
  evaluation.
- VT: the `models` verb (replace, unknown refused, revoked refused).
- VT: pi config omits models without a pi block.
- VH: a live request per provider records non-zero spend, and minuet's
  routing fields are accepted.
- `just test` green, lint clean.

## Summary

Add OpenRouter and Fireworks to the gateway. Let OpenRouter price itself,
let direct providers use the packaged map or an explicit price, and make a
key's model list editable, so adding a model is one edit plus one CLI call.
Sequenced after SL-013; prerequisite for emacs:SL-015.

## Follow-Ups

- IMP-035: the OpenAI provider.
- IMP-030 and IMP-034 (other jails onto the gateway) can use these providers.
- IDE-008: publishing gateway and agents as a standalone project.
