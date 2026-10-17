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
