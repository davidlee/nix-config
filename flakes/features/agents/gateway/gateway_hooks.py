"""LiteLLM adapter for llm-gateway (design SL-011 sec-3): the route gate in
front of the proxy app, and the hooks config.yaml names, which turn LiteLLM
calls into `keystore` calls.

  route_gate(app)    ASGI wrapper: only ALLOWED_ROUTES reach LiteLLM
  authenticate       general_settings.custom_auth: the key must be live
  model_gate         callback, pre-call: the model must be on the key's list
  ledger             callback, success: spent += response_cost

LiteLLM loads each hook reference from this file afresh, without sys.modules
(litellm/proxy/types_utils/utils.py:42-50, 1.102.1), so the hooks hold no
state: each call reads the key store at $STATE_DIRECTORY/keys.db.
Messages name the alias, never the key or its hash (POL-001).
"""

import logging
import os
from pathlib import Path

import keystore
from fastapi import HTTPException
from litellm.integrations.custom_logger import CustomLogger
from litellm.proxy._types import UserAPIKeyAuth

log = logging.getLogger("llm-gateway.hooks")

ALLOWED_ROUTES = frozenset(
    {
        ("POST", "/chat/completions"),
        ("POST", "/v1/chat/completions"),
        ("GET", "/models"),
        ("GET", "/v1/models"),
    }
)
GATE_REFUSAL = b'{"error": "llm-gateway: no such route"}'
GATE_HEADER = (b"x-llm-gateway", b"no such route")  # marks the gate's 404, HEAD too


def route_gate(app):
    """Pass lifespan events and ALLOWED_ROUTES to `app`; answer every other
    request 404 (GATE_REFUSAL, GATE_HEADER) and close every websocket,
    without reaching it. Some LiteLLM routes never call custom_auth (RV-024
    F-1), so routes are filtered here rather than in a hook. A route matches
    only verbatim: method, decoded path and, when given, raw path, so
    encodings, case, slashes and other methods all miss."""

    async def gated(scope, receive, send):
        if scope["type"] == "lifespan" or _allowed(scope):
            await app(scope, receive, send)
        elif scope["type"] == "websocket":
            await send({"type": "websocket.close", "code": 1008})
        else:
            await send(
                {
                    "type": "http.response.start",
                    "status": 404,
                    "headers": [(b"content-type", b"application/json"), GATE_HEADER],
                }
            )
            await send({"type": "http.response.body", "body": GATE_REFUSAL})

    return gated


def _allowed(scope):
    if scope["type"] != "http":
        return False
    route = (scope["method"], scope["path"])
    raw = scope.get("raw_path")
    return route in ALLOWED_ROUTES and (raw is None or raw == scope["path"].encode())


async def authenticate(request, api_key):
    """custom_auth, called by keyword (proxy/auth/user_api_key_auth.py:1347),
    so the parameter names are fixed. LiteLLM has already removed the
    `Bearer ` prefix (same file, :485); `api_key` is None when no key was
    sent, refused as unknown. A refusal is a 401 naming the alias. `api_key`
    on the result is the hash, which LiteLLM hands the ledger as
    user_api_key_hash."""
    try:
        row = keystore.authenticate(_db(), api_key or "")
    except keystore.Refused as refused:
        raise HTTPException(status_code=401, detail=str(refused)) from None
    return UserAPIKeyAuth(
        api_key=row["hash"], key_alias=row["alias"], models=row["models"]
    )


class ModelGate(CustomLogger):
    """Refuses a model off the key's list: LiteLLM does not enforce
    UserAPIKeyAuth.models for custom auth (DEC-046)."""

    async def async_pre_call_hook(self, user_api_key_dict, cache, data, call_type):
        model = data.get("model")
        if not keystore.allows_model({"models": user_api_key_dict.models or []}, model):
            raise HTTPException(
                status_code=403,
                detail=f"{user_api_key_dict.key_alias}: model {model!r} not allowed",
            )
        return data


class Ledger(CustomLogger):
    """Adds each served request's cost to its key's spend. Never raises: a
    failure here must not fail a request already answered."""

    # called by keyword (litellm_core_utils/litellm_logging.py:3208)
    async def async_log_success_event(self, kwargs, response_obj, start_time, end_time):
        # Set server-side from our UserAPIKeyAuth.api_key, over any client
        # metadata (proxy/litellm_pre_call_utils.py:1569-1570, 1607).
        metadata = (kwargs.get("litellm_params") or {}).get("metadata") or {}
        digest = metadata.get("user_api_key_hash")
        if not digest:
            log.warning("spend not recorded: no key hash in the success payload")
            return
        cost = kwargs.get("response_cost")
        if cost == 0:
            # LiteLLM prices a model missing from its price map at 0.0,
            # silently; served free is worth a line.
            alias = metadata.get("user_api_key_alias")
            log.warning(
                "%s: served request priced at 0 (model not in the price map?)", alias
            )
        try:
            keystore.record_spend(_db(), digest, cost)
        except Exception:
            log.exception("spend not recorded")


model_gate = ModelGate()
ledger = Ledger()


def _db():
    return Path(os.environ.get("STATE_DIRECTORY", "/var/lib/llm-gateway")) / "keys.db"
