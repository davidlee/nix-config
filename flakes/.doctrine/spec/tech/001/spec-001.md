# SPEC-001: LLM gateway

<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

The LLM gateway is a LiteLLM proxy that holds the model providers' API keys,
so that agents never need one. Each client gets its own gateway key instead:
it works only on this host, only for the models on its list, and only until
its budget is spent.

```
clients (jails: eca, pi, claude …; gptel, minuet; later satan, oubliette rooms)
   │  OpenAI chat-completions, Bearer <gateway key>
   ▼
127.0.0.1:4000 ── relay (systemd-socket-proxyd, socket-activated, group llm-gateway)
   ▼
/run/llm-gateway/api.sock (dir 0750) ── llm-gateway.service: LiteLLM + our hooks
   ├─ route gate   route on the list? body fields on the list? size ≤ 16 MiB?
   ├─ auth         key known, live, under budget?             ┐
   ├─ model gate   model and fallbacks on the key's list?      ├─ keys.db (SQLite)
   ├─ provider     LiteLLM adapter, key from systemd creds     │
   └─ ledger       spent += response_cost                     ┘
```

C4 level: container, one deployable unit. Its parts are sections below, not
specs of their own. There is no product spec yet; the why is the paragraph
above.

**Posture: retrospective.** This describes the gateway as shipped by SL-011,
SL-013 and SL-014 (2026-10). Requirements are `pending` until reconciled
against evidence; the tests named here are where that evidence lives.

**Reading order.** A client author needs only § Client contract. A
maintainer reads on.

## Client contract

What a client may rely on and must do. It changes only by decision.

**Reach.** `http://127.0.0.1:4000/v1`, from this host only. A jail gets the
address and its key from `jailLib.gatewayClient "<client>"` (DEC-059); the key
file is `~/.config/llm-gateway/keys/<client>`, passed into the jail as
`LLM_GATEWAY_KEY` (DEC-049).

A jail without network (bwrap `--unshare-net`) reaches the same URL through
an in-jail forwarder to `/run/llm-gateway-client/api.sock` (socket mode,
DEC-076); the client sees no difference. Authentication is the same bearer
key; the socket adds no trust (DEC-077).

**Routes.** Only these, anything else is a 404 marked
`x-llm-gateway: no such route` (FR-001):

| method | path |
|---|---|
| POST | `/chat/completions`, `/v1/chat/completions` |
| GET | `/models`, `/v1/models` |

**Body.** A JSON object whose top-level fields are all from this list, else
a 400 naming the field; over 16 MiB is a 413 (FR-002, DEC-073). The list is
complete; it is `ALLOWED_FIELDS` in `gateway_hooks.py`:

| fields | from |
|---|---|
| `model`, `messages`, `stream`, `stream_options`, `temperature`, `top_p`, `max_tokens`, `max_completion_tokens`, `stop`, `n`, `seed`, `presence_penalty`, `frequency_penalty`, `logit_bias`, `logprobs`, `top_logprobs`, `tools`, `tool_choice`, `parallel_tool_calls`, `response_format`, `user` | OpenAI chat completions, a subset |
| `reasoning_effort` | OpenAI; the one reasoning control clients should use (DEC-074) |
| `thinking` | DeepSeek's native switch; pi sends it |
| `reasoning` | OpenRouter's native `{effort}`; older gptel sends it |
| `provider` | OpenRouter routing preferences (`sort`, `order`, …); minuet sends it |

Fields are checked by name at the top level only; their contents pass to
LiteLLM as sent. A field OpenAI adds later is not admitted until it is added
here. Adding one is a decision, with its reason.

Refused, among others: `extra_body`, `litellm_params`,
`custom_llm_provider`, `models`, `route`, `usage`, `metadata`, and every
fallback form (`fallbacks`, `context_window_fallbacks`,
`content_policy_fallbacks`, `router_settings_override`), even to models on
the key's list. Each could re-route a request past the model gate or
suppress the cost report.

**Reasoning effort.** Send flat `reasoning_effort`, on any model (FR-006).
The gateway translates nothing; LiteLLM's adapter maps it to each provider's
form. Given both a native shape and `reasoning_effort`, the adapter decides
(DeepSeek drops `reasoning_effort`).

**Model names.** `<provider>/<upstream id>`, e.g.
`openrouter/z-ai/glm-5.3-flash`, `fireworks/nemotron-lightning-3p5-30b-a3b`
(DEC-069). The one exception is `deepseek-flash`. Names are exact.

**Refusals.**

| status | meaning | marker |
|---|---|---|
| 404 | route not served | `x-llm-gateway: no such route` |
| 400 | body field not allowed (fallbacks included), or body not a JSON object | `x-llm-gateway: body refused` |
| 413 | body over 16 MiB | `x-llm-gateway: body refused` |
| 401 | key missing, unknown, revoked or out of budget | — |
| 403 | model not on the key's list | — |

Messages name the key's alias, never the key. Upstream errors are
LiteLLM's and not specified here.

**Budget.** A safety net on recorded spend, not a hard cap. Each call is
checked against the key's lifetime USD budget before it runs; its cost is
recorded after it succeeds (DEC-051). With accounting healthy, concurrent
requests overshoot by about one request's cost each. Lost accounting has no
bound: a cost of 0 or none counts 0 (DEC-068), and a failed ledger write is
logged and the cost dropped.

**Responses and streaming.** OpenAI-shaped responses, streamed (SSE) when
`stream` is set; LiteLLM produces them. A streamed request is charged once
its stream completes. Not specified, and unverified:

- whether a stream the client abandons, or the gateway cuts (a restart,
  ~25 s), is charged; the provider may still bill it;
- whether LiteLLM retries a failed upstream call (the gateway configures no
  retries; LiteLLM's defaults are not checked), and so whether one request
  can incur more than one provider charge.

A client that retries sends a new request and is charged for it.

## Responsibilities

- Serve an OpenAI-compatible chat-completions endpoint to local clients.
- Hold the provider keys so no client needs one (NF-001).
- Authenticate each client by its own key; enforce its model list and budget
  (FR-003, FR-004).
- Record each request's cost against its key (FR-005).
- Refuse every route and body field outside the contract (FR-001, FR-002).
- Administer keys and provider credentials locally (FR-008).

Not its job: the jails and how they get their key (`agents/`, DEC-049,
DEC-058); subscription logins such as Codex OAuth (IMP-035); anything off
this host.

## Mechanism

### Request path

`route_gate` is an ASGI wrapper around LiteLLM's app
(`gateway_hooks.py`). It sees the client's verbatim request before LiteLLM
adds anything, so it checks the route, buffers the body (bounded at 16 MiB)
and checks its top-level fields, then replays the body to LiteLLM. The rest
are LiteLLM hooks named in the generated `config.yaml`:

| hook | LiteLLM slot | does |
|---|---|---|
| `authenticate` | `general_settings.custom_auth` | key → row via `keystore.authenticate`; refuses with 401 |
| `model_gate` | callback, `async_pre_call_hook` | the request's model, 403; also every fallback via LiteLLM's `iter_request_fallback_targets`, defence in depth behind the body guard (RV-026 F-4) |
| `ledger` | callback, `async_log_success_event` | `keystore.record_spend(hash, response_cost)`; never raises |

The model gate is ours because LiteLLM does not enforce
`UserAPIKeyAuth.models` for custom auth (DEC-046). LiteLLM loads each hook
by reference outside `sys.modules`, so hooks are stateless and reopen the
store per call.

### Key store and ledger

One SQLite table in `/var/lib/llm-gateway/keys.db` (dir 0700), stdlib only
(`keystore.py`, DEC-046, DEC-051):

```
keys(hash PK = sha256(key), alias UNIQUE, models, budget_usd, spent_usd, created, revoked_at)
```

Revoking marks the row and keeps it, so an alias is never reused (DEC-051).
A key is issued `sk-<token>` and returned once.

### Served models and cost

The served-model list is plain data in `agents/gateway.nix` (`models`): name
→ LiteLLM `model`, `provider`, optional `params` merged into its LiteLLM
params under the generated `model` and `api_key` (DEC-070), and an optional
`pi` block the gateway ignores (DEC-063, DEC-066). OpenRouter models are
explicit entries, no wildcard (DEC-065); each sets
`allowed_openai_params = ["reasoning_effort"]` so LiteLLM does not refuse
it on models it does not flag as reasoning.

Each model needs a cost source, checked at build (FR-007, DEC-064):

```
provider.reportsCost ──yes──> OpenRouter's usage.cost, per request
        │no
both prices in params ──yes──> explicit price
        │no
in LiteLLM's packaged price map ──yes──> map price
        │no
build fails, naming the model
```

At run time a cost of 0 or none is warned and counted 0 (DEC-068).

### Providers and credentials

`services.llm-gateway.providers` (default in `proxy.nix`): name → key
variable, 1Password reference, `reportsCost`. Only providers that a served
model uses get a credential. `llm-gateway credentials` reads each key with
`op read` and encrypts it with `systemd-creds` against the host key and
TPM2 into `/etc/credstore.encrypted/llm-gateway.<provider>`; the unit loads
it with `LoadCredentialEncrypted` (DEC-048). A missing credential makes
systemd refuse the unit. A new provider rolls out credentials first, from
the new build's CLI, then switches (DEC-067).

### Perimeter

```
any local process ──> 127.0.0.1:4000 ───────────────────────────┐
the user's processes ──> /run/llm-gateway-client/api.sock ──────┴─> relay ──group──> api.sock (0750 dir) ──> LiteLLM
                         (user 0600, dir root 0755)                 key check fails closed: 401
```

One gateway socket, one relay with two listeners (DEC-075); the key is the
only per-client identity (DEC-047, DEC-077). The client socket is the relay's,
so the 0750 gate on the gateway socket is unchanged.
uvicorn makes the socket 0666, so the directory mode is the gate. Service
and relay share a hardening set (strict filesystem, no capabilities,
`@system-service` filter, UMask 0077); the service cannot be network-private
because it reaches the providers.

### Admin CLI

`llm-gateway`, run as the service user via sudo on the store; no master key
and no admin route (DEC-050). Verbs: `issue`, `list`, `revoke`, `budget`,
`models` (replace a live key's list, DEC-071), `reset`, `credentials`. Keys
travel on stdin, never argv; `issue --out` writes a new 0600 file and revokes
the key if the write fails.

## Concerns

- **Fail closed.** Unknown routes, unknown body fields, unknown keys and
  errors in auth all refuse. The route gate sees the client's body before
  LiteLLM adds server keys, so a LiteLLM release that forwards a new field
  cannot open a bypass.
- **LiteLLM upgrades.** Hook signatures, fallback handling and cost
  reporting are LiteLLM internals (memory
  `mem.fact.litellm.proxy-hook-behaviours`, verified on 1.102.1).
  `checks.<system>.llm-gateway` runs the real proxy offline with fake
  upstreams; it must pass on every bump.
- **Secrets** (NF-001, NF-002, POL-001). Three places a key can be:

  | | provider keys | client keys |
  |---|---|---|
  | stored by the gateway | encrypted systemd credentials | sha256 only |
  | in memory at run time | the service's credentials directory and its process environment; `op read` → `systemd-creds` pipe while provisioning | the request, briefly |
  | held by clients | never | the client's key file and environment |

  Root on the running machine can still decrypt the credentials and read
  the service's environment.
- **Budget** is a safety net, not a cap: concurrent requests overshoot, and
  lost accounting is unbounded (§ Client contract, Budget).
- **Restart cost.** A switch or credentials change restarts the service,
  ~25 s; in-flight requests are cut.

## Hypotheses

- LiteLLM's adapters map flat `reasoning_effort` correctly for every served
  provider. Verified on OpenRouter only; IMP-038 tests DeepSeek and
  Fireworks.
- OpenRouter keeps returning `usage.cost` when LiteLLM injects
  `usage: {include: true}`; the ledger's accuracy for OpenRouter rests on it.
- One shared key for all pi jails (`pi`) is an acceptable blast radius.

## Decisions

The decisions this spec composes. Read one with `doctrine show DEC-NNN`.

| area | decisions |
|---|---|
| store, auth, budgets | DEC-046, DEC-050, DEC-051, DEC-071 |
| perimeter, credentials | DEC-047, DEC-048, DEC-067 |
| client side (in `agents/`) | DEC-049, DEC-058, DEC-059, DEC-061, DEC-062 |
| served models, cost | DEC-063, DEC-064, DEC-065, DEC-066, DEC-068, DEC-069, DEC-070, DEC-072 |
| wire contract | DEC-073, DEC-074 |

## Open questions

- **Who owns `agents/gateway.nix`.** It holds the address, the served models
  and pi's blocks, and the gateway reads it across the sub-flake boundary by
  relative path. IDE-008 prefers: the gateway owns address and models; the
  jail library takes `url` and `keyFile` from its caller; pi's blocks stay
  with the jails. Not decided.
- **Portability.** If the gateway moves to oubliette (IDE-008), this spec
  moves with it. What is Sleipnir-specific (port 4000, 1Password refs, TPM)
  becomes options; the contract does not change.
