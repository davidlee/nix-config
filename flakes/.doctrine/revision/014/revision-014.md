# REV REV-014 — ChatGPT subscription provider in SPEC-001

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

<!-- Why this revision: what authored truth needs to change and why, the scope of
     the staged delta, and (for ADR/POL/STD/prose rows) the before/after excerpts
     the structured payload only labels. Seeded at `revision new`. -->

IMP-035 / DEC-094 (2026-10-29) replace the API-billed `openai-dav` and
`openai-david` providers (DEC-093) with LiteLLM's native `chatgpt` provider,
signed in to the user's ChatGPT subscription. That provider has no key: it
holds an OAuth token that LiteLLM refreshes and rewrites. SPEC-001 assumes
every provider is a key held as a systemd credential; this revision records
the exception.

### SPEC-001

- Overview: "holds the model providers' API keys" → "holds the model
  providers' API keys, and the ChatGPT subscription's login"; diagram
  `provider` line: "key from systemd creds, or the ChatGPT token".
- § Served models and cost: `chatgpt/<id>` models are LiteLLM
  `chatgpt/responses/<id>` (the prefix sends a model the map does not list
  in responses mode to the Responses API, the backend's only route) and set
  both prices from their pi cost, as the map lists them at no price.
- § Providers and credentials: add `chatgpt`, with no key variable or
  reference and no credential. Its token is `auth.json` in
  `CHATGPT_TOKEN_DIR=/var/lib/llm-gateway/chatgpt`, in the 0700 state
  directory, written 0600 by `llm-gateway chatgpt-login` (device code, as
  the service user, umask 077) and refreshed in place by LiteLLM. One
  directory per process, so one account. Started without a token, the unit
  runs but LiteLLM drops the `chatgpt/*` deployments until a restart (400
  "no healthy deployments"); `chatgpt-login` restarts it after signing in.

### REQ-009 (NF-001)

Before: "Provider keys are stored only as host- and TPM2-encrypted systemd
credentials; …"

After: add "The ChatGPT subscription token, which the service refreshes and
rewrites, is the one exception: it is stored only in the service's state
directory (0700, the file 0600), readable by the service user alone."
Acceptance criterion added: "A chatgpt model's generated config has no
`api_key`; the token is never in config, a log or a client's request."

### REQ-008 (FR-008)

Add `chatgpt-login` to the CLI's verbs: it runs the subscription's
device-code login as the service user, then restarts the gateway and waits
for its socket. Refused as root, like every verb
(DEC-091).
