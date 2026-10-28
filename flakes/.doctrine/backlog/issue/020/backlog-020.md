# ISS-020: Gateway body guard: a form Content-Type lets LiteLLM parse fields the guard never saw

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

The route gate's body guard (`features/agents/gateway/gateway_hooks.py`,
`_guard_body`) checks a POST body's top-level fields with `json.loads`, then
replays the bytes with the client's headers unchanged. LiteLLM 1.106.2's
`read_request_body` parses a form content type with `request.form()`
(`litellm/proxy/common_utils/http_parsing_utils.py:238-262`), and the chat
handler uses that result (`proxy_server.py:12333`). A JSON string value
holding `&api_base=…&custom_llm_provider=…`, sent as
`application/x-www-form-urlencoded`, passes the guard and reaches LiteLLM as
those fields. This is DEC-073's threat: a key holder could point a request,
carrying the gateway's provider credential, at another host.

Live on Sleipnir today; needs a valid gateway key to be served. Found by
Codex on RV-041 F-1 (reproduced in-process against the pinned parser).

Fix: SL-019 sec-4. Every admitted POST is replayed with canonical headers:
one `content-type: application/json`, one `content-length`, no
`content-encoding` or `transfer-encoding`. Close at SL-019's rollout.

Status 2026-10-28: operator hotfix live on Sleipnir, committed 504ebca5
(`gateway_hooks.py` `_guard_body`, the canonical replay). Tests:
`test_scope_headers_are_canonicalized`, `test_form_type_cannot_change_the_guarded_body_interpretation`
and `ParserAgreementTest` (through the real proxy). Verified by `just test` and
a live probe: SL-019 notes, § Roll-forward. Still closes at SL-019's rollout.
