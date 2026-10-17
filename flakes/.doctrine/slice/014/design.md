<!-- doctrine:section sec-1 -->
## Shape

Two providers join DeepSeek. Each served model gets its cost from one
source, and that source decides what the build checks (DEC-064):

```
agents/gateway.nix  models.<name> = { model; provider; params?; pi?; }
        │
        ├──> proxy.nix configDir ──> config.yaml  litellm_params = params // {model; api_key} // extraParams
        │         └─ price rule: provider.reportsCost  ─────────────> admitted (OpenRouter's usage.cost)
        │                        params has both per-token prices ──> admitted
        │                        otherwise ──> price-check.py: packaged map or the build fails
        │
        └──> jailed-agents.nix piGatewayConfig ──> pi models.json   only models with `pi` (DEC-066)
```

At run time one check is new. A request body may set only allow-listed
fields (DEC-073, sec Request body guard). Without it a client could name
an allowed model and still choose another upstream model, turn off
OpenRouter's cost report, or drop its key from the ledger. The model gate
is still an exact match (DEC-065). The Ledger still records
`response_cost`, which LiteLLM fills from OpenRouter's `usage.cost`
(research T3, Q2). A cost of 0 or None stays warn-and-count-0 (DEC-068);
the guard keeps clients from causing one. One new admin verb, `models`,
replaces a key's model list (DEC-071).

<!-- doctrine:section sec-2 -->
## Served models (`agents/gateway.nix`)

A served model gets one optional field, `params` (DEC-070). It is a plain
attrset that proxy.nix merges into the model's `litellm_params`. `pi`
becomes optional (DEC-066). Names follow DEC-069: `<gateway provider>/<upstream id>`.
`deepseek-flash` keeps its name.

```nix
models = let
  # OpenRouter prices each request itself. reasoning_effort must be allowed
  # explicitly: LiteLLM refuses it (400) for a model its map does not flag
  # as reasoning, and most routes here are unmapped or aliases.
  openrouter = id: {
    model = "openrouter/${id}";
    provider = "openrouter";
    params.allowed_openai_params = ["reasoning_effort"];
  };
  routed = ids: builtins.listToAttrs (map (id: {
    name = "openrouter/${id}";
    value = openrouter id;
  }) ids);
in {
  deepseek-flash = { …unchanged, with pi… };
  "fireworks/nemotron-lightning-3p5-30b-a3b" = {
    model = "fireworks_ai/accounts/fireworks/models/nemotron-lightning-3p5-30b-a3b";
    provider = "fireworks";
  };
} // routed [ … ];
```

`agents/gateway.nix` is imported without `lib` (plain data, DEC-059), hence
`builtins.listToAttrs`. The name is the attribute: Nix allows quoted names
containing `/`, and every consumer reads the names with `attrNames`.

The OpenRouter ids are gptel's list (`~/.config/emacs/apps/dl-gptel.el:121-139`)
with `qwen/qwen3.8-flash` corrected (DEC-072), plus minuet's model:

```
~deepseek/deepseek-flash-latest  ~deepseek/deepseek-pro-latest
deepseek/deepseek-v4.1-flash     deepseek/deepseek-v4-flash
openrouter/auto                  openrouter/free                   openrouter/pareto-code
qwen/qwen3.8-flash               z-ai/glm-5.3-flash                ~z-ai/glm-flash-latest
~z-ai/glm-latest                 google/gemini-3.8-flash           google/gemini-3-flash-preview
xiaomi/mimo-v2.6-pro             xiaomi/mimo-v2.6-flash
```

gptel's `deepseek/deepseek-flash` is not an OpenRouter id (the live
check got 400 "not a valid model ID"), so it is not served; DeepSeek Flash
is served directly as `deepseek-flash`.

That makes 15 OpenRouter models, 1 Fireworks model and 1 DeepSeek model.
`openrouter/auto` becomes the gateway name `openrouter/openrouter/auto`.
That reads oddly, but it follows the rule.

The Fireworks model is in the packaged map with `supports_reasoning`, so
it needs no `params`.

<!-- doctrine:section sec-3 -->
## Proxy: providers, params, price rule (`features/agents/gateway/proxy.nix`)

**Providers.** Add these entries to `defaults.providers`, beside deepseek:

| provider | `env` (LiteLLM reads it) | `ref` (public, POL-001) | `reportsCost` |
|---|---|---|---|
| deepseek | `DEEPSEEK_API_KEY` | `op://API_KEYS/DEEPSEEK_API_KEY/credential` | false |
| openrouter | `OPENROUTER_API_KEY` | `op://API_KEYS/OPENROUTER_API_KEY/credential` | true |
| fireworks | `FIREWORKS_API_KEY` | `op://API_KEYS/FIREWORKS_API_KEY/credential` | false |

`reportsCost` is a new optional provider field, default false. It means the
provider returns each request's billed cost, and LiteLLM captures it
(`litellm/llms/openrouter/chat/transformation.py:168-171,212-226`). It lives
on the provider because it is a property of the provider.
`features/agents/gateway.nix` declares `providers` as an option of
`{env; ref}`, so its submodule gains `reportsCost` (bool, default false).
The credential plumbing is derived from `providers` (research T2).
`proxy.serve providers values` bakes the launcher's PROVIDERS from it
through `bake.nix`. The service and `checks.llm-gateway` share that one
projection, so `CredentialTest` reads the production set (PHASE-02 D1).

**Models.** `defaults.models` stops projecting to `{model, provider}`. It
also keeps `params` and drops only `pi`:
`lib.mapAttrs (_: m: removeAttrs m ["pi"])`.

**Entry.** The order puts the generated keys above `params`:

```nix
litellm_params = (m.params or {}) // { inherit (m) model; api_key = "os.environ/…"; } // extraParams;
```

A `params.api_key` or `params.model` therefore cannot redirect a model.
`extraParams` stays last, because it is the check's `mock_response`.

**Price rule** (DEC-064). Nix decides which ids still need the packaged
map. `price-check.py` is unchanged:

```nix
prices = m: filter (f: (m.params or {}) ? ${f}) ["input_cost_per_token" "output_cost_per_token"];
# both or neither, for every served model, whatever its cost source
checkPrices = name: m: assert lib.assertMsg (length (prices m) != 1)
  "llm-gateway: model ${name} sets only one of input_cost_per_token, output_cost_per_token"; m;
needsMap = m: !(providers.${m.provider}.reportsCost or false) && length (prices m) != 2;
… price-check.py ${escapeShellArgs (map (m: m.model) (filter needsMap (attrValues models)))}
```

`checkPrices` wraps each model where its config.yaml entry is built.
Every model has an entry, so the check runs for all of them: a mapped
model, an unmapped one, and one whose provider reports cost. `needsMap`
alone would skip it for the last two. A half-priced model is an evaluation
error naming it. `price-check.py` with no arguments exits 0.

<!-- doctrine:section sec-4 -->
## pi block optional (`agents/jailed-agents.nix`)

SL-013 has landed the rule as required: README:1006-1007, "a served model
without `pi` fails evaluation". `piGatewayConfig` keeps only the models
that have a `pi` block:

```nix
models = lib.mapAttrsToList (id: m: {inherit id;} // m.pi)
  (lib.filterAttrs (_: m: m ? pi) models);
```

The throw goes. `agents/jailed-agents-test.nix`'s `noPiEntryFails` becomes
`noPiEntryOmitted`, with a twin that differs only in the pi block: a model
without `pi` is absent from the generated `models.json`, and one with `pi`
is present. pi now sees only `deepseek-flash`, as before.

Amend DEC-063: its choice clause ends "a served model without a pi block is
not offered to pi (DEC-066)". Its consequences drop the evaluation error.
`agents/README.md` § pi in gateway mode and README § LLM gateway "Adding a
client" say the same.

<!-- doctrine:section sec-5 -->
## Key model list (`keystore.py`, `llm-gateway`)

DEC-071 adds one keystore function and one verb.

```python
def set_models(db, alias, models):
    """Replace the model list of `alias`'s key. The key itself is unchanged."""
```

It refuses an empty list, as `issue` does. It refuses a revoked key with
`f"{alias}: revoked"`: a revoked key stays dead, and editing it would
suggest otherwise. It refuses an unknown alias, through `_update`'s
existing error. It stores the list as JSON, like `issue`.

CLI: `llm-gateway models ALIAS M,…`. The models are parsed by `model_list`,
like `issue --models`. The unknown-model refusal in `main` is now shared by
`issue` and `models`: a helper that takes `args.models` and names the
served set. It runs as the service user through `as_service` / `administer`,
like `budget`. The help line reads: "replace a key's model list (the key
is unchanged)".

The change is live at once: `authenticate` reads the row on every request,
and hooks are stateless (memory `mem.fact.litellm.proxy-hook-behaviours`).
No restart is needed.

README § Rotation: "a key is never re-keyed in place" stays. A new line
adds that its model list can be replaced with `llm-gateway models`. Adding a
served model is then: edit `agents/gateway.nix`, `system-switch`, then
`llm-gateway models <alias> …` for each key that should get it.

<!-- doctrine:section sec-6 -->
## Verification

### VT: `checks.llm-gateway` (`perSystem.nix`, `gateway-test`)

- **Price rule twins** (build-failure tests, beside `LLM_GATEWAY_UNPRICED`):
  - Admitted, building a config with `extraModels` emptied:
    - an unpriced id under a `reportsCost` provider;
    - an unpriced direct id with both `params` prices.
  - Refused:
    - an unpriced direct id with no prices; the log names it ("not in the
      packaged price map");
    - only `input_cost_per_token`, an evaluation error naming the model,
      three times: on a mapped direct id (the map check would pass it), an
      unmapped direct id, and a `reportsCost` id (no map check runs).
- **Production mapping**: every served model passes the rule (the existing
  PriceMapTest, now through `needsMap`). Every OpenRouter entry carries
  `allowed_openai_params`.
- **OpenRouter cost reaches the ledger** (DEC-068): a fake OpenRouter on
  loopback answers with `usage.cost`. The test points a config entry at it
  through `params.api_base`, test-only via `extraModels`. One key, then one
  streamed and one non-streamed request; the key's spend increases by
  exactly the reported cost each time. No real provider is contacted.
- **Pass-through**: the same fake records the upstream body. A request with
  `provider: {sort: "throughput"}` and `reasoning_effort: "none"` on an
  unmapped OpenRouter model reaches it with both fields and no 400.
- **params cannot override**: a model whose `params.api_key` is a literal
  still gets `os.environ/<env>` in the generated config.
- **Body guard, unit** (`RouteGateUnitTest`, recording app): a body with
  each refused field gets a 400 naming it and never reaches the app; a
  body of only listed fields reaches it byte for byte, also when sent in
  several `http.request` chunks; a non-object body gets a 400; `GET
  /models` passes without a body read.
- **Body guard, end to end** (fake OpenRouter): each RV-029 bypass body
  gets a 400, the fake receives nothing, and spend is unchanged:
  `extra_body.model`, `models` + `route`, `extra_body.usage`, streamed
  `extra_body.stream_options`, `litellm_params: {}`, `custom_llm_provider`.
  Control: top-level `stream_options: {include_usage: false}` on a streamed
  request is served and charged the reported cost.
- **Client bodies**: one recorded body each from eca, pi, gptel and minuet
  passes the guard.
- `ClientOverrideTest` changes: client `mock_response` and `metadata` now
  get the guard's 400 instead of being stripped or overridden by LiteLLM.
  The `api_base` case stays a refusal.
- The fallback test (RV-026 F-4) splits: over HTTP each fallback form now
  gets the guard's 400; ModelGate's own fallback refusal is tested by
  calling `async_pre_call_hook` directly, since no HTTP request reaches it
  with a fallback any more.
- `CredentialTest` takes its provider from the baked `PROVIDERS` instead of
  hard-coding deepseek.

### VT: `keystore-test`, CLI tests

- `set_models` replaces the list. Afterwards `allows_model` follows the new
  list and the key authenticates unchanged.
- It refuses an empty list, a revoked key and an unknown alias.
- The CLI `models` verb refuses names that are not served (same message as
  `issue`), and runs `set_models` as the service user.

### VT: `checks.jailed-agents`

- `noPiEntryOmitted` and its twin (sec pi block optional).
- The bound file for gateway.nix's models still holds exactly
  `deepseek-flash`.

### VH: live, after rollout

- `llm-gateway issue sl014-probe --models openrouter/deepseek/deepseek-v4-flash,fireworks/nemotron-lightning-3p5-30b-a3b,openrouter/openrouter/auto --budget 1`.
  Then one request each with curl, and `llm-gateway list` shows non-zero
  spend after each. No bring-your-own-key
  route is served, so A2 is void. Then `revoke sl014-probe`.
- minuet's body (`provider`, `reasoning_effort: "none"`, `max_tokens: 56`,
  `top_p`) gets a 200 on `openrouter/deepseek/deepseek-v4-flash`.
- `llm-gateway models eca deepseek-flash` succeeds, and eca still works.

`just test` green; `ruff`/`nixfmt`/`statix` (whatever `just lint` runs)
clean.

<!-- doctrine:section sec-7 -->
## Rollout (DEC-067)

A provider whose credential is missing makes systemd refuse the whole unit
(DEC-048). The installed `llm-gateway credentials` refuses providers it
does not know. So the order is:

```
1. just system-build                                  # new config, nothing switched
2. ./result/sw/bin/llm-gateway credentials openrouter fireworks
                                                      # the NEW build's CLI knows them;
                                                      # writes /etc/credstore.encrypted/llm-gateway.<p>
3. just system-switch                                 # unit starts with all three credentials
4. VH probes (sec Verification)
```

`credentials` always restarts the service after encrypting
(`llm-gateway`, `restart`), so step 2 restarts the old unit, still on the
old config. LiteLLM takes about 25 s to start, so the gateway is down that
long, and again at step 3. Requests in those windows fail, and in-flight
ones are cut off. Run the rollout when no client is mid-request. A
no-restart staging mode would avoid one window; it is not worth a new
CLI path for a one-off rollout. The README's adding-a-provider line gets
this order and the two restarts.

<!-- doctrine:section sec-8 -->
## Code impact and docs

### This repo (`~/flakes`), design-target selectors

| path | change |
|---|---|
| `agents/gateway.nix` | `params`; OpenRouter and Fireworks models; comment on optional `pi` |
| `agents/jailed-agents.nix` | `piGatewayConfig` filters |
| `agents/jailed-agents-test.nix` | `noPiEntryOmitted` + twin |
| `agents/README.md` | § pi in gateway mode: `pi` optional |
| `features/agents/gateway/proxy.nix` | providers + `reportsCost`; keep `params`; entry merge order; `needsMap`; `serve` |
| `features/agents/gateway.nix` | `providers` submodule gains `reportsCost` |
| `features/agents/gateway/bake.nix` | the `script` helper moves here, as `{pkgs, lib}: name: python: values:` |
| `features/agents/gateway/llm-gateway-serve` | baked through `proxy.serve`; run unbaked, it still defaults to deepseek only |
| `features/agents/gateway/keystore.py` | `set_models` |
| `features/agents/gateway/keystore-test` | `set_models` cases |
| `features/agents/gateway/llm-gateway` | `models` verb; shared unknown-model check |
| `features/agents/gateway/gateway_hooks.py` | `route_gate` reads and checks the body; `ALLOWED_FIELDS` (DEC-073) |
| `features/agents/gateway/gateway-test` | fake OpenRouter: cost, pass-through, bypass bodies; params override; body guard unit tests; `ClientOverrideTest` changes; CredentialTest |
| `perSystem.nix` | price-rule twins |
| `README.md` | § LLM gateway: providers, adding a model or provider, `models` verb, rollout order, "What it does not cover" (OpenRouter line goes; OpenAI subscription → IMP-035) |

`price-check.py` is unchanged. In `gateway_hooks.py`, ModelGate and the
Ledger are unchanged.

### Outside this repo

None. emacs:SL-015 consumes the names and fixes gptel's qwen id.

### Records at reconcile

- DEC-063 amended (choice and consequences: pi optional).
- DEC-051 amended: the build-time clause becomes DEC-064's rule.
- DEC-050: the verb set gains `models` (DEC-071).
- SL-011 and SL-013 design text that says "packaged map only" or "pi
  required" is historical, so it is not edited.
- IMP-029 resolved (partial: OpenAI → IMP-035).

<!-- doctrine:section sec-9 -->
## Request body guard (`gateway_hooks.py`)

DEC-073. `route_gate` already decides which routes reach LiteLLM. It now
also reads the body of each `POST` chat-completions request, before
LiteLLM sees it, and passes only bodies whose top-level fields are all on
an allow-list:

```
client ──POST /v1/chat/completions──> route_gate
                                       ├─ route not allowed            ──> 404 (unchanged)
                                       ├─ body over 16 MiB             ──> 413
                                       ├─ body not a JSON object       ──> 400
                                       ├─ a field off ALLOWED_FIELDS   ──> 400 "llm-gateway: field 'x' not allowed"
                                       └─ otherwise: replay the body ──> LiteLLM (auth, ModelGate, Router)
```

```python
ALLOWED_FIELDS = frozenset({
    # OpenAI chat completions
    "model", "messages", "stream", "stream_options", "temperature", "top_p",
    "max_tokens", "max_completion_tokens", "stop", "n", "seed",
    "presence_penalty", "frequency_penalty", "logit_bias", "logprobs",
    "top_logprobs", "tools", "tool_choice", "parallel_tool_calls",
    "response_format", "user", "reasoning_effort",
    # DeepSeek thinking switch (pi)
    "thinking",
    # OpenRouter reasoning effort (gptel)
    "reasoning",
    # OpenRouter: provider routing preferences (sort, order, only, …)
    "provider",
})
```

Why these are out, with what each one did when sent (RV-029 probes, fake
upstream):

| field | effect if admitted |
|---|---|
| `extra_body` | LiteLLM merges it over the generated OpenRouter body: `model` replaces the checked model; `usage`, `stream_options` stop the cost report |
| `models`, `route` | OpenRouter's own model fallbacks, unseen by ModelGate |
| `usage` | turns off OpenRouter's cost report |
| `litellm_params` | replaces LiteLLM's internal params in the success payload: the Ledger finds no key hash and charges nothing |
| `custom_llm_provider` | swaps the provider adapter: an OpenRouter model loses its cost report |
| `fallbacks` and the other fallback forms, `metadata`, `mock_response` | not needed by any client; ModelGate and LiteLLM handle them today, but nothing is lost by refusing them |

`stream_options` is listed: LiteLLM sets `include_usage` true over the
client's top-level value (probed). Nested objects (`provider`,
`messages`, `tools`, `thinking`, `reasoning`) are not inspected: none of them is merged into
LiteLLM's own parameters.

A refusal is a 400 with a JSON error naming every unlisted field. It is
sent before authentication, which reveals nothing: the list is in this
public repo. The body is read in full, then replayed to LiteLLM as one
`http.request` message. Other routes (`GET /models`) pass unread.

The body is capped at 16 MiB (`MAX_BODY_BYTES`): the guard reads before
authentication, so the cap bounds memory for any caller. A `content-length`
over the cap is refused up front, and a chunked body is refused as soon as
the bytes read exceed it; both answer 413.
 Phase planning checks the list against the bodies
eca, pi, gptel and minuet send; a field a client needs is added here, with
its reason.

Scope: the guard covers every served model, so it also closes the
`litellm_params` and `custom_llm_provider` gaps that `deepseek-flash` has
had since SL-011. ModelGate is unchanged and still checks fallbacks: a
second line behind the guard (RV-026 F-4).

