<!-- doctrine:section sec-1 -->
## Shape

Serve TypeSafe's Jev through LiteLLM 1.106.2's native TypeSafe provider
(research.md Thread 2), so a new consumer needs only a gateway key
(DEC-084). Three gateway changes and one CLI change; no new hook, no
pass-through, no LiteLLM bump.

```
client ──Bearer <gateway key>──> route_gate ─────────────────────> LiteLLM 1.106.2
  POST /v1/systemone             1. route on ROUTES?        404     user_api_key_auth ─> authenticate (keystore)
  [Content-Encoding: zstd]       2. size ≤ 16 MiB?          413     pre_call_hook ─> model_gate (key's list)
                                 3. decode zstd (bounded)   415/413/400   asystemone ─> api.typesafe.ai/v1/systemone
                                 4. fields ⊆ ROUTES[route]? 400       Bearer TYPESAFE_API_KEY
                                 5. replay JSON, canonical headers  success ─> ledger (usage.input_tokens × 4.2e-8)
```

| change | where | decision |
|---|---|---|
| `typesafe` provider | `features/agents/gateway/proxy.nix` | — |
| four Jev models | `agents/gateway.nix` | DEC-085 |
| per-route fields; `/v1/systemone` | `gateway_hooks.py` | DEC-087, DEC-092 |
| zstd decode; canonical replay headers | `gateway_hooks.py` | DEC-088 |
| refuse root | `llm-gateway` | DEC-091 |

DEC-092 supersedes DEC-086: `/v1/decisions` is not served, because LiteLLM
fetches remote image URLs on it. DEC-084 holds for `/v1/systemone`.

<!-- doctrine:section sec-2 -->
## Provider and served models

**Provider** (`proxy.nix`, `defaults.providers`), beside the others:

```nix
typesafe = {
  env = "TYPESAFE_API_KEY";
  ref = "op://API_KEYS/TYPESAFE_API_KEY/credential";  # convention; confirm at rollout
};
```

No `reportsCost`: the packaged map prices Jev (DEC-064). The launcher, the
credential CLI and `LoadCredentialEncrypted` pick the provider up from this
set unchanged.

**Models** (`agents/gateway.nix`, DEC-085, DEC-069 names), built by one
helper like `openrouter`:

```nix
typesafe = id: { model = "typesafe/${id}"; provider = "typesafe"; };
# typesafe/jev-latest, typesafe/jev-preview, typesafe/jev-1.14.0, typesafe/jev-1.13.0
```

No `pi` block, so pi is not offered them (DEC-066); no `params`. The build's
price check (`price-check.py`) finds all four in the packaged map
(research.md ✓). LiteLLM strips the `typesafe/` prefix, so the upstream body
names `jev-1.14.0` (asserted by test).

<!-- doctrine:section sec-3 -->
## Route gate: per-route fields and `/v1/systemone` (`gateway_hooks.py`)

`ALLOWED_ROUTES` and the one global `ALLOWED_FIELDS` become one map from
route to the fields its body may carry (DEC-087); a GET has no body:

```python
CHAT_FIELDS = frozenset({...})                  # today's ALLOWED_FIELDS, unchanged
SYSTEMONE_FIELDS = frozenset({"model", "state", "questions", "assets"})
ROUTES = {
    ("POST", "/chat/completions"): CHAT_FIELDS,
    ("POST", "/v1/chat/completions"): CHAT_FIELDS,
    ("POST", "/v1/systemone"): SYSTEMONE_FIELDS,
    ("GET", "/models"): None,
    ("GET", "/v1/models"): None,
}
```

`_allowed` reads `ROUTES`; `route_gate` passes `ROUTES[route]` to
`_guard_body`, and `_body_refusal(body, fields)` checks against it. Matching
stays verbatim (method, decoded path, raw path), so `/systemone`,
`/v1/decisions`, `/decisions` stay 404 (DEC-092).

Why per route: LiteLLM's systemone body is `extra="allow"` at the top level
(`types/decisions.py:180` ✓), so an unlisted `api_base`, `fallbacks` or
`metadata` would reach it, which is DEC-073's threat. A union set would
admit chat fields on systemone and the reverse.

Not inspected, as DEC-073: nested objects. On systemone `state` is the
client's JSON and `assets` are `data_base64` images; neither makes the
gateway fetch anything. `images`, the field LiteLLM inlines by URL, is off
the list. `typesafe-danger-zone-*` headers pass through (DEC-090); that is
how a client opts in to images.

<!-- doctrine:section sec-4 -->
## Route gate: decoding and replay (`gateway_hooks.py`, DEC-088)

The TypeSafe SDK sends bodies over 1 KiB as `Content-Encoding: zstd` by
default (`typesafe-sdk-js/src/compression.ts:5, 37-38`), through Node's
one-shot `zlib.zstdCompress` at default parameters. LiteLLM's decisions
route parses JSON only (`endpoints.py:102-104` ✓). `_guard_body` decodes
before the field check, on every POST route:

```
read body (≤ MAX_BODY_BYTES, as today)               over → 413
content-encoding: every occurrence, split on commas, trimmed, lowercased, as one list
  [] | [identity]  ──> body
  [zstd]           ──> ZstdDecompressor(options={window_log_max: 24})
                         .decompress(body, max_length=MAX+1)
                           decoded > MAX           → 413  (output bound)
                           not .eof / unused_data  → 400  (one complete frame)
                           ZstdError               → 400  (incl. a window over 16 MiB)
  any other list   ──> 415  (other codings, chains, repeats)
field check on the decoded body                       → 400
replay the decoded body with canonical headers
```

Empty elements are kept, so `zstd,` and an empty header value fall to
"any other list": 415.

**Two decode bounds.** `max_length` bounds the output. The decoder sizes
its window from the frame header, before any output: an 11-byte frame can
ask for 128 MiB, and `max_length` does not limit that. `window_log_max = 24`
caps the window at 16 MiB, equal to `MAX_BODY_BYTES`. A body of at most
16 MiB never needs a larger window from a one-shot encoder, whose window is
bounded by the input size.

**Canonical replay headers.** The guard's reading of the body must be the
only one. LiteLLM picks its parser from the content type
(`proxy/common_utils/http_parsing_utils.py:234-262` ✓): a form type goes to
`request.form()`. Then a JSON string value holding `&api_base=…` would
reach LiteLLM as an `api_base` field the guard never saw. So every POST the
guard admits is replayed with these scope headers changed, and every other
header kept:

| header | replayed as |
|---|---|
| `content-type` | exactly one: `application/json` |
| `content-length` | exactly one: `len(body)`, decoded |
| `content-encoding` | removed |
| `transfer-encoding` | removed |

All occurrences of each are removed first. The client's content type is
replaced, not refused: the guard has already parsed the bytes as a JSON
object, and refusing would break clients that omit the header.
LiteLLM's JSON branch (`orjson`, then `json`) sees the same set of
top-level keys as the guard's `json.loads`, whichever duplicate it keeps;
a body only one of them parses fails closed (400 at one or the other).

Every refusal is `_refuse` with `GUARD_HEADER`, as today. `compression.zstd`
is in the gateway's Python 3.14 standard library (PEP 784; the proxy's
`pkgs.python3` is 3.14.8).

<!-- doctrine:section sec-5 -->
## CLI: refuse root (`llm-gateway`, DEC-091, ISS-015)

`Host` gains `is_root: Callable[[], bool]` (production:
`os.geteuid() == 0`). `main` checks it first and fails with exit 2:

```
llm-gateway: run as your user, not root: llm-gateway runs sudo itself
```

Nothing runs it as root today: `just gateway-credentials` calls it plainly
(`Justfile:120-121` ✓), and the service-user path is `sudo -u llm-gateway`,
not root. So a key from `llm-gateway issue … --out FILE` is always the
invoking user's, mode 0600.

<!-- doctrine:section sec-6 -->
## Verification

### VT: `checks.llm-gateway` (`perSystem.nix`, `gateway-test`)

The fake upstream on loopback (SL-014's `FakeOpenRouter`) becomes one fake
serving both `/v1/chat/completions` and `/v1/systemone`, recording each
request's headers and body. The fake config adds `typesafe/jev-1.14.0` on
`onFake` (`get_complete_url` strips a trailing `/v1`,
`llms/base_llm/decisions/transformation.py:512-513` ✓, so the same
`api_base` works). Its answer carries `usage.input_tokens`.

Route gate in isolation (recording app):
- `POST /v1/systemone` reaches the app; `/systemone`, `/v1/decisions`,
  `/decisions` are 404 with the gate marker.
- systemone admits `{model, state, questions, assets}`; refuses `messages`
  and `api_base` (400); chat refuses `state` (400).
- every admitted POST reaches the app with exactly the canonical headers
  (sec-4), whatever content type the client sent; a chunked zstd request
  reaches it decoded, with no `transfer-encoding`.
- `gzip`, `zstd, identity` and two `content-encoding` headers are 415; a
  zstd bomb (decodes past the bound) is 413; a frame asking for a 128 MiB
  window that decodes to `{}` is 400; a truncated frame and two frames
  are 400.

Through the proxy, against the fake:
- no key → 401; a key without Jev → 403; a key with Jev → 200, and the
  fake saw `Authorization: Bearer <provider secret>`, `model: jev-1.14.0`,
  and the client's `state` and `questions`;
- spend rose by `input_tokens × 4.2e-8` (the packaged price);
- a zstd-encoded systemone request is served the same;
- cross-route: a Jev model on `/v1/chat/completions` is non-200.
- parser agreement: a chat body whose `messages` string holds
  `&api_base=<second loopback listener>&custom_llm_provider=…`, sent as
  `application/x-www-form-urlencoded`, plain and zstd, on both chat
  aliases: the second listener receives nothing.

The existing credential test covers the new provider through
`LLM_GATEWAY_MODELS`.

### VT: `keystore-test`

`FakeHost` gets `is_root`. Run as root, every command exits 2 with the
message, and nothing reaches `privileged` or `spawn`.

### VH: live, after rollout

One `/v1/systemone` call through the relay with a screwtape key on
`typesafe/jev-1.14.0`: 200, spend recorded; the same zstd-encoded (e.g. via
the SDK) is 200.

<!-- doctrine:section sec-7 -->
## Rollout (DEC-067)

```bash
# 1Password item TYPESAFE_API_KEY in API_KEYS (operator)
just system-build
./result/sw/bin/llm-gateway credentials typesafe   # the new build's CLI
just system-switch
llm-gateway issue screwtape --models typesafe/jev-1.14.0 --budget <USD> \
  --out ~/.config/llm-gateway/keys/screwtape        # no sudo (DEC-091)
```

Then the VH call. Close IMP-054, ISS-015 and ISS-020.

<!-- doctrine:section sec-8 -->
## Code impact and docs

### This repo (`~/flakes`), design-target selectors

| path | change |
|---|---|
| `features/agents/gateway/proxy.nix` | `typesafe` provider |
| `agents/gateway.nix` | `typesafe` helper, four models |
| `features/agents/gateway/gateway_hooks.py` | `ROUTES`, per-route fields, zstd decode, canonical replay headers |
| `features/agents/gateway/gateway-test` | fake upstream generalised; gate and proxy tests |
| `perSystem.nix` | fake config gains the Jev model |
| `features/agents/gateway/llm-gateway` | `is_root`, refusal |
| `features/agents/gateway/keystore-test` | root refusal test |
| `README.md` | § LLM gateway: provider row, route, zstd, SDK limits, issue without sudo |
| `.doctrine/spec/tech/001/**` | SPEC-001 via revision |

### Outside this repo

screwtape:SL-004 consumes `/v1/systemone` on `127.0.0.1:<relayPort>`, key
on `typesafe/jev-1.14.0`; no IPv6 listener.

### Records at reconcile

SPEC-001 revision: § Client contract gains `/v1/systemone`, its field list,
zstd (and 415), the body replayed as `application/json` whatever the
client's content type, the Jev names, and the TypeSafe SDK's unsupported
`models.list()` and multipart images (DEC-089); § Providers gains
`typesafe`; § Admin CLI: refuses root. Close IMP-054, ISS-015, ISS-020.

