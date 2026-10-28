# IMP-054: TypeSafe Jev behind the LLM gateway via LiteLLM's native TypeSafe provider

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Operator direction, 2026-10-28, from a screwtape session. screwtape:SL-004
(the Jev mail classifier) needs this first.

**What:** serve TypeSafe's Jev decision model (https://docs.typesafe.ai)
through the LLM gateway, so consumers never hold the TypeSafe key.

**Why the gateway:** it already has provider-key custody (systemd-creds,
`LoadCredentialEncrypted`), per-client keys, the unix socket and the
127.0.0.1 relay.

## Revised 2026-10-28: native support is already pinned

The first version of this item assumed native TypeSafe support was blocked
on an upstream merge and proposed a `pass_through_endpoints` stand-in. That
premise is false for the gateway's pin. The gateway builds LiteLLM from the
system `nixpkgs` input: **1.106.2** (not 1.102.1, which the
`gateway_hooks.py` line references still cite). Read in that store path:

- `llms/typesafe/decisions/transformation.py`: a `typesafe` decisions
  provider; key `TYPESAFE_API_KEY`, base `https://api.typesafe.ai`.
- `proxy/decisions_endpoints/endpoints.py`: `POST /v1/systemone`,
  `/systemone`, `/v1/decisions`, `/decisions`, each behind
  `user_api_key_auth` (which calls our `custom_auth`), the model named in the
  body and resolved from the model list.
- Packaged price map: `typesafe/jev-1.13.0`, `jev-1.14.0`, `jev-latest`,
  `jev-preview`, each `input_cost_per_token = 4.2e-8`. DEC-064 is met with no
  new rule.

Upstream `main` (v1.107.0-dev+) adds a `/typesafe/{endpoint}` pass-through,
Jev as a complexity-router classifier and a TypeSafe guardrail. None is
needed to serve Jev; no pass-through, shim or vendored rc code.

## Work

- `typesafe` provider in `proxy.nix` defaults (`TYPESAFE_API_KEY`; the
  1Password reference is still to be confirmed).
- A served model, e.g. `typesafe/jev-1.14.0` (pinned version vs `jev-latest`
  is open), in `agents/gateway.nix`.
- `route_gate`: admit `POST /v1/systemone` (and `/v1/decisions`?); the body
  guard's allow-list becomes per route (`state`, `model`, `questions`,
  `assets`?).
- Tests against a fake TypeSafe upstream; SPEC-001 client contract (REV);
  README § LLM gateway; rollout (credential before switch, DEC-067).

## Still unverified (small spike)

1. Do `model_gate` (pre-call) and `ledger` (success) fire on the decisions
   route? Depends on `_process_decisions` running the common request
   processing.
2. Compression: first out of scope ("we don't need compression"), then in:
   the TypeSafe SDK sends zstd by default, and SL-019's DEC-088 decodes it.

The earlier fallback (operator, 2026-10-28: unauthenticated loopback access
accepted, "it's so cheap") is moot: the native routes authenticate.
