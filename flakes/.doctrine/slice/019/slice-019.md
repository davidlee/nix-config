# TypeSafe Jev behind the LLM gateway

## Context

IMP-054 (operator, 2026-10-28): serve TypeSafe's Jev decision model through
the LLM gateway, so a consumer holds only a gateway key, never the TypeSafe
key. screwtape:SL-004 (the Jev mail classifier) is the first consumer and
waits on this.

The gateway's pinned LiteLLM (1.106.2, from the system `nixpkgs` input)
already supports TypeSafe natively, so no pass-through endpoint or vendored
upstream code is needed (IMP-054 § Revised):

```
client ──Bearer <gateway key>──> route_gate ──> LiteLLM 1.106.2
                                 (allow-list,    POST /v1/systemone
                                  body guard)      user_api_key_auth ─> custom_auth (keystore)
                                                   model_gate?  ledger?          (spike)
                                                   typesafe decisions provider
                                                     └─ TYPESAFE_API_KEY ──> api.typesafe.ai
```

- Provider: `llms/typesafe/decisions/transformation.py` (`TYPESAFE_API_KEY`,
  base `https://api.typesafe.ai`).
- Routes: `proxy/decisions_endpoints/endpoints.py`, `/v1/systemone` and
  `/v1/decisions` (with unversioned twins), each behind `user_api_key_auth`.
- Price: the packaged map prices `typesafe/jev-*` at 4.2e-8 USD per input
  token, so the price check (DEC-064) admits it unchanged.

SL-014 (OpenRouter and Fireworks) is the precedent for adding a provider,
its tests and its rollout.

## Scope & Objectives

1. **Provider** `typesafe` in `proxy.nix` defaults: `TYPESAFE_API_KEY`, a
   public 1Password ref (POL-001), by convention
   `op://API_KEYS/TYPESAFE_API_KEY/credential` (to confirm at rollout).
0. **Goal** (DEC-084): the next Jev consumer needs only a gateway key.
2. **Served models** in `agents/gateway.nix` (DEC-085, DEC-069 names):
   `typesafe/jev-latest`, `jev-preview`, `jev-1.14.0`, `jev-1.13.0`. No pi
   block: pi is not a decisions client.
3. **Route gate**: admit `POST /v1/systemone` only (DEC-092, superseding
   DEC-086: `/v1/decisions` would make the gateway fetch remote image URLs).
   The body allow-list becomes per route (DEC-087): chat unchanged;
   systemone `{model, state, questions, assets}`. `typesafe-danger-zone-*`
   headers pass through (DEC-090).
3b. **CLI** (DEC-091, ISS-015): `llm-gateway` refuses to run as root.
3a. **zstd bodies** (DEC-088): decoded on every POST before the field
   check, bounded at 16 MiB encoded and decoded; any other encoding is a 415.
4. **Key scope and metering**: `model_gate` refuses a key without the Jev
   model; `ledger` records its cost. Static trace says both run on the
   decisions routes (research.md); the first red tests prove it.
5. **Tests**: against a fake TypeSafe upstream on loopback, as SL-014's
   fake OpenRouter. No key → 401; key without the model → 403; an off-list
   body field → 400, per route; zstd decoded; another encoding → 415; a
   decoded body over the bound → 413; one cross-route request fails; a
   served request's cost reaches the ledger; the upstream gets the TypeSafe
   key, the client never sees it.
6. **Docs**: SPEC-001 § Client contract (routes, body fields) through a
   revision; README § LLM gateway (provider table, decisions route).
7. **Rollout (VH)**: credential, then switch (DEC-067); a key for the
   screwtape consumer; one live Jev call. Close IMP-054.

## Non-Goals

- Request encodings other than zstd (DEC-088).
- The TypeSafe SDK's `models.list()` and its multipart image requests
  (DEC-089): documented as unsupported.
- Upstream `main`'s `/typesafe/{endpoint}` pass-through, Jev
  complexity-router classifier and TypeSafe guardrail (v1.107.0-dev+).
- A LiteLLM bump.
- The screwtape client itself (screwtape:SL-004).

## Affected surface

| path | change |
|---|---|
| `features/agents/gateway/proxy.nix` | `typesafe` provider |
| `agents/gateway.nix` | served Jev model |
| `features/agents/gateway/gateway_hooks.py` | routes; per-route body allow-list; zstd decode |
| `features/agents/gateway/llm-gateway`, `keystore-test` | refuse root (DEC-091) |
| `features/agents/gateway/gateway-test`, `perSystem.nix` | fake TypeSafe; route, auth, ledger tests |
| `.doctrine/spec/tech/001/` | SPEC-001 client contract (via revision) |
| `README.md` § LLM gateway | docs |

## Open questions (settled in design)

- OQ-1: `model_gate` and `ledger` run on the decisions routes (research.md,
  static trace); the first phase's red tests prove it.
- OQ-2: DEC-085. OQ-3: DEC-092 (supersedes DEC-086). OQ-4: out of scope, CHR-024.

## Verification

`just test` green with the new tests (VT); SPEC-001 revised; one live Jev
call through the gateway with spend recorded (VH).

## Summary

## Follow-Ups
