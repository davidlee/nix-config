# IMP-035: OpenAI subscription (Codex OAuth) behind the LLM gateway

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Split from IMP-029 by SL-014 (DEC-072, 2026-10-17). The user wants OpenAI
behind the gateway through the ChatGPT subscription, not API billing.
gptel's `openai-sub` backend (`gpt-5.6-terra`) and agent-shell/codex sign in
with OAuth today. An API-key `providers.openai` is not the goal.

Work out how LiteLLM can serve OpenAI models on a subscription OAuth login.
Candidate: a custom LiteLLM provider such as
https://github.com/jslorrma/litellm-codex-oauth-provider (unreviewed).

Questions for the spike:

- Token custody. Where do the OAuth refresh and access tokens live, and who
  refreshes them? The service user under DEC-048-style credentials, or a
  token file? Refresh means the gateway writes a secret back, which
  DEC-048's read-only credential model does not cover.
- Packaging. Can the provider be packaged into `proxy.nix`'s Python env, and
  does it load with no network at build time?
- Cost. The ledger records LiteLLM's `response_cost`. A subscription call has
  no per-request price, so it is probably 0, which DEC-068 logs as a
  warning. Decide whether subscription models are exempt or carry a nominal
  price through `params` (DEC-070).
- Terms. Is serving a personal subscription to local jails acceptable under
  OpenAI's terms for that product?

Once it works: add the provider, name models `openai/<id>` (DEC-069), create
credentials before the switch (DEC-067), and extend keys with
`llm-gateway models` (DEC-071). Then emacs:SL-015 can move gptel's
`openai-sub` onto the gateway.

## Revised (2026-10-29)

User decisions: one subscription account (david@davlee.com); the API-key
providers `openai-dav` / `openai-david` (DEC-093) are removed; models are named
`chatgpt/<id>` (DEC-069); serving the subscription to local jails is
acceptable under the terms (the spike's terms question is closed).
Tracked here, not as a slice (user, 2026-10-29).

Spike answers, from LiteLLM 1.106.2 (`litellm/llms/chatgpt/`):

- No custom provider needed: the pinned LiteLLM has a native `chatgpt`
  provider (chat and responses transformations).
- Token custody: one `auth.json` in `$CHATGPT_TOKEN_DIR`, read per
  `Authenticator()`, an env var, so one account per LiteLLM process. LiteLLM
  refreshes the access token itself and rewrites the file (`open(…, "w")`).
  The first login is a device-code flow needing a human; it refuses to run
  inside the proxy's event loop, so `auth.json` must exist before the first
  request.
- Cost: the packaged map lists `chatgpt/gpt-6-luna`, `gpt-6.1-sol`,
  `gpt-6-astra` (and others) in `responses` mode with no prices, so they
  cost 0. No `chatgpt/gpt-6.1-terra` or `chatgpt/gpt-5.4-mini`.

## Plan

```
llm-gateway chatgpt-login ──sudo -u llm-gateway──> device-code flow
                                                     └─> /var/lib/llm-gateway/chatgpt/auth.json (0600)
llm-gateway.service  CHATGPT_TOKEN_DIR=/var/lib/llm-gateway/chatgpt
  LiteLLM chatgpt provider ── reads, refreshes, rewrites auth.json ──> chatgpt.com
```

1. Provider kind. `defaults.providers.chatgpt` carries no `env`/`ref`; it is a
   token-file provider. `configDir` writes no `api_key` for it; the launcher's
   PROVIDERS and the unit's `LoadCredentialEncrypted` take key providers
   only. The unit sets `CHATGPT_TOKEN_DIR` under its existing StateDirectory
   (0700, writable under ProtectSystem=strict).
2. Models (`agents/gateway.nix`): `account "openai-dav" // account
   "openai-david"` becomes `named "chatgpt"` over the same ids, LiteLLM model
   `chatgpt/<id>`. pi entries keep their compat; the `(provider)` name suffix
   goes.
3. CLI: `llm-gateway chatgpt-login` runs the device-code login as the service
   user, writing `auth.json` into the token dir; refuses as root (DEC-091).
4. Remove `openai-dav` / `openai-david` providers and their credentials
   (README rollout: `rm /etc/credstore.encrypted/llm-gateway.openai-*`).
5. Tests (`gateway-test`): a chatgpt model has no `api_key`; the unit
   exports the token dir; the hand-priced test moves to
   `chatgpt/gpt-6.1-terra`; a request reaches a fake upstream via
   `CHATGPT_API_BASE` with a fake unexpired token, and its cost lands in the
   ledger.
6. Records: a DEC superseding DEC-093; SPEC-001 served models through a
   revision; README § LLM gateway (provider table, first run, rotation).
7. Rollout: switch; `llm-gateway chatgpt-login`; `llm-gateway models` to swap
   `openai-*` for `chatgpt/*` on the satan, satan-runner, malebolge and pi-2
   keys (DEC-071).

Risks: the chatgpt chat route is a bridge to the responses API (map mode
`responses`); reasoning_effort and pi's completions compat need a live check.
gpt-6.1-terra's availability on the subscription is unverified.

## Progress (2026-10-29)

Approved by the user with: charge at API rates (1a), drop gpt-5.4-mini.
Decision: DEC-094 (supersedes DEC-093). Spec: REV-014 (SPEC-001, REQ-008,
REQ-009), awaiting approval.

Done, `just test` green:

- `agents/gateway.nix`: `chatgpt/<id>` for luna, sol, terra, astra; LiteLLM
  model `chatgpt/responses/<id>`. Found by the red test: terra, absent from
  the price map, was sent to `/chat/completions`; the `responses/` prefix
  routes every model to the Responses API regardless of the map. Prices
  from the pi cost (input, output, cache read).
- `proxy.nix`: `providers.chatgpt = {}`; `keyed` filters the providers with
  a key, for `api_key`, the launcher's PROVIDERS, the CLI's PROVIDERS and
  `LoadCredentialEncrypted`.
- `features/agents/gateway.nix`: `CHATGPT_TOKEN_DIR`; `env`/`ref` nullable.
- `llm-gateway chatgpt-login` (+ keystore-test: argv, failure, 0600 token
  file through a stand-in litellm).
- gateway-test: a fake `/v1/responses` SSE upstream; sol and terra, streamed
  and not, reach it with the token, never a provider key, and charge the
  ledger exactly at the params prices; reasoning_effort reaches it.
- README § LLM gateway.
- Unrelated gate fix: `agents/jailed-agents-env-test.nix` stubs
  `llm-agents…pi` (482256f0 made `piInJail` force it).

Rollout (user, needs sudo and a browser):

1. `just system-switch`
2. `llm-gateway chatgpt-login` (david@davlee.com); it restarts the gateway.
   Found at rollout: a gateway started without a token drops the chatgpt
   deployments for the life of the process (journal 21:30:16, "Error
   creating deployment"; then 400 "no healthy deployments"). The first
   build's login did not restart; fixed so it does.
3. `llm-gateway models <alias> …` for satan, satan-runner, malebolge, pi-2:
   `openai-*` → `chatgpt/*`
4. `sudo rm /etc/credstore.encrypted/llm-gateway.openai-dav /etc/credstore.encrypted/llm-gateway.openai-david`
5. Live check: one chat request, streamed and with reasoning_effort, through
   the gateway; then resolve this item.

Unverified: whether the subscription serves gpt-6.1-terra; whether the
chatgpt backend accepts every chat field the gateway admits.
