Verified against the 1.102.1 source while building SL-011. Re-check after any LiteLLM bump; `checks.<system>.llm-gateway` runs the real proxy offline.

- Hook modules are loaded by reference, outside `sys.modules` (`types_utils/utils.py:42-50`), so a hook must be stateless. Read config, such as `STATE_DIRECTORY`, on each call.
- `custom_auth` works with no master key and gets `api_key=None` when no key is sent. A sha256-hex `api_key` returned in `UserAPIKeyAuth` is kept as is, not re-hashed, and reaches callbacks as `kwargs.litellm_params.metadata.user_api_key_hash`.
- A non-HTTPException raised in auth becomes HTTP 500, via a prisma import in `auth_exception_handler.py:62`, but the request is still refused.
- The proxy strips a client's `mock_response` (`litellm_pre_call_utils.py:224-232`). A server-side `mock_response` does take the production pricing path.
- An unpriced model costs 0.0 silently, and the proxy adds empty `model_cost` entries for configured models at startup. To check pricing, read the packaged `model_prices_and_context_window_backup.json` instead.
- Its "hash logged keys" guard (`proxy/_types.py:3153-3176`) hashes only `sk-`-prefixed and JWT keys. Any other key travels raw into `post_call_failure_hook` and OTEL on auth failure (RV-026 F-3).
- The Router honours per-request `fallbacks` (`router.py:2842, 7588, 7695`), so a gate that checks only `data["model"]` can be bypassed once more than one model is configured (RV-026 F-4).
- In the Nix build sandbox only `unset SSL_CERT_FILE` is needed. `LITELLM_LOCAL_MODEL_COST_MAP=True` avoids a ~3 s GitHub fetch.

Unix-socket serving: uvicorn chmods the socket 0666, so the parent directory's mode is the gate.

How the gateway answers the last two (SL-011 reconcile):
- Keys are issued `sk-<token>`, so that guard hashes them. Custom auth is prefix-agnostic: `user_custom_auth` returns before any key-format path (`proxy/auth/user_api_key_auth.py:1346-1357`).
- `proxy/auth/auth_utils.py:iter_request_fallback_targets` is LiteLLM's own enumeration of request fallbacks (top-level and `router_settings_override`, every shape); `model_gate` reuses it. `is_request_body_safe` already refuses `user_config` and `model_list` in a body.
- To read the packaged price map without importing litellm (its import builds an httpx client), locate it with `importlib.util.find_spec("litellm").submodule_search_locations[0]` (`features/agents/gateway/price-check.py`).

Cost and OpenRouter (SL-014 research, 2026-10-17, read and probed on 1.102.1):
- No local whole price map. `LITELLM_MODEL_COST_MAP_URL` and `register_model(str)` are fetched with httpx, and a path or `file://` silently falls back to the packaged map (`litellm_core_utils/get_model_cost_map.py:252-256,636-660`). Per-deployment `input_cost_per_token`/`output_cost_per_token` in `litellm_params` or `model_info` do price an unmapped model (`router.py:8893-8920`).
- OpenRouter: LiteLLM adds `usage:{include:true}` only when the body has no `usage` key, and it applies the client's `extra_body` first (`llms/openrouter/chat/transformation.py:164-171`). The returned `usage.cost` overrides both map and custom prices, streamed too (`cost_calculator.py:1874-1879`). A client can therefore suppress the cost (`extra_body.usage`, or `extra_body.stream_options` when streaming; a top-level `stream_options` is forced to include usage). `models`, `route` and `extra_body.model` reach the upstream body, so a client can re-route past a model gate.
- Two more client body fields reach internals, for every provider: `litellm_params` (even `{}`) overwrites LiteLLM's own in the success payload (`litellm_logging.py:838-853` spreads optional params last), so callbacks lose `metadata.user_api_key_hash`; `custom_llm_provider` is honoured (`router.py:3580-3590` puts client kwargs last), swapping the adapter. LiteLLM's banned-field list (`proxy/auth/auth_utils.py`) refuses `api_base`, `base_url`, prices and `user_config`, not these. SL-014 answers all of them with a body allow-list in `route_gate` (DEC-073; RV-029 F-1, F-2, F-4, F-5).
- `reasoning_effort` on a model the map does not flag `supports_reasoning` is a 400 `UnsupportedParamsError`, unless the deployment sets `allowed_openai_params` or `model_info.supports_reasoning` (`llms/openrouter/chat/transformation.py:42-55`). `drop_params` drops it silently.

SL-014 implementation and live rollout (2026-10-18, 1.102.1):
- Query strings (`?route=`, `?models=`, `?custom_llm_provider=`) do not reach request data; only the body does.
- The DeepSeek adapter supports a top-level `thinking` natively (no `allowed_openai_params`); given both `thinking` and `reasoning_effort`, it drops `reasoning_effort`.
- OpenRouter `reasoning:{effort}` passes through and coexists with the injected `usage:{include:true}`, so the reported cost survives.
- Two proxy apps in one process register callbacks twice and double-charge a ledger; run a second test gateway in a child process (`gateway-test`).
- Live, `x-litellm-response-cost` equals OpenRouter's `usage.cost`; a packaged-map model (Fireworks) returns `usage.cost` none and is priced from the map.

LiteLLM 1.106.2 bump (2026-10-28; this changes two claims above):
- A boot check refuses to start the proxy when no master key is set (`proxy/auth/master_key_boot_check.py`, called at `proxy_server.py:1471`). The service crash-loops with `UnsafeMasterKeyError`, and `checks.llm-gateway` fails before any test runs. The gateway sets `general_settings.dangerously_permit_weak_or_unset_master_key: true` (`proxy.nix`, DEC-050). The pinned package reads that flag only in the boot check, and `custom_auth` still returns before any master-key comparison (`proxy/auth/user_api_key_auth.py:1637`). Do not "fix" this with an ephemeral master key: a non-None `master_key` changes auth branches (`is_no_auth_dev_mode`).
- OpenRouter now supports `reasoning_effort` and `thinking` on every model (`llms/openrouter/chat/transformation.py:41-46`), so `allowed_openai_params` is redundant (CHR-025). This replaces the 400 `UnsupportedParamsError` claim above.
- Cost depends on time of day: a price-map entry with `off_peak_pricing` is charged at that block's rates inside its UTC windows (`litellm_core_utils/llm_cost_calc/utils.py`, `_is_off_peak`). `deepseek/deepseek-flash` is half price on weekdays from 10:00 UTC to midnight, and all weekend. A test that restates the price from the map must apply the same rule (`gateway-test` `price_now`), or it fails at some times of day.
- `read_request_body` parses by `Content-Type`: a form type via `request.form()`, protobuf types via a binary parser, anything else as JSON (`proxy/common_utils/http_parsing_utils.py:229-262`). The route gate therefore replays every admitted body with a canonical `content-type: application/json` (ISS-020).
- Line references above (`:1346-1357`, …) are 1.102.1; CHR-024 tracks the stale ones in code.
