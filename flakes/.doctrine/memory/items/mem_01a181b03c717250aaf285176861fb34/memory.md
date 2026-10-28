LiteLLM 1.106.2 (the gateway's pin, system `nixpkgs`) ships TypeSafe Jev
natively: provider `llms/typesafe/decisions/transformation.py`
(`TYPESAFE_API_KEY`, base `https://api.typesafe.ai`), routes in
`proxy/decisions_endpoints/endpoints.py` (`/v1/systemone`, `/systemone`,
`/v1/decisions`, `/decisions`), each behind `user_api_key_auth` (so
`custom_auth`) and the common pre-call path (so `model_gate`), and
`@client`-wrapped (so `ledger`), priced from `usage.input_tokens` by the
packaged map (`typesafe/jev-*`, 4.2e-8/input token). No pass-through needed.

Sharp edges:
- Decisions bodies are `extra="allow"` at the top level
  (`types/decisions.py`): an unlisted `api_base` or `fallbacks` reaches
  LiteLLM unless `route_gate`'s per-route field list stops it.
- On `/v1/decisions` (and `images` on systemone) LiteLLM downloads remote
  image URLs itself (`decisions/call.py` `_async_with_remote_images_inlined`;
  TypeSafe sets `inlines_remote_images = True`). A key holder could make the
  gateway GET arbitrary URLs, an exfiltration path for offline jails
  (DEC-077). Hence DEC-092: `/v1/systemone` only, `images` off its list.
- Any client header prefixed `typesafe-danger-zone-` is forwarded to TypeSafe
  (`proxy/litellm_pre_call_utils.py`), DEC-090.
- The upstream URL is `api_base` minus a trailing `/v1`, plus `/v1/systemone`.
Line numbers drift with the pin; grep the names.

Observed live through the gateway (SL-019 VH-1, 2026-10-28): the reply's
`model` is TypeSafe's bare id: a request for `typesafe/jev-1.14.0` answers
`"model": "jev-1.14.0"`. A client that exact-matches the reply against the
gateway name must strip `typesafe/` first. Only jev-1.14.0 was checked; an
alias (`jev-latest`) may answer with the version served.
