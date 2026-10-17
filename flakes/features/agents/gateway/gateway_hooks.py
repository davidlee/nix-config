"""LiteLLM adapter for llm-gateway (design SL-011 sec-3): the route gate in
front of the proxy app, and the hooks config.yaml names, which turn LiteLLM
calls into `keystore` calls.

  route_gate(app)    ASGI wrapper: only ALLOWED_ROUTES reach LiteLLM, and a
                     chat completion only with a body whose fields are all
                     on ALLOWED_FIELDS (SL-014 sec-9)
  authenticate       general_settings.custom_auth: the key must be live
  model_gate         callback, pre-call: every model the request names must
                     be on the key's list
  ledger             callback, success: spent += response_cost

LiteLLM loads each hook reference from this file afresh, without sys.modules
(litellm/proxy/types_utils/utils.py:42-50, 1.102.1), so the hooks hold no
state: each call reads the key store at $STATE_DIRECTORY/keys.db.
Messages name the alias, never the key or its hash (POL-001).
"""

import json
import logging
import os
from pathlib import Path

import keystore
from fastapi import HTTPException
from litellm.integrations.custom_logger import CustomLogger
from litellm.proxy._types import UserAPIKeyAuth
from litellm.proxy.auth.auth_utils import iter_request_fallback_targets

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

# The top-level fields a chat completion may carry (DEC-073, SL-014 sec-9).
# Nested objects are not inspected: none merges into LiteLLM's own params.
ALLOWED_FIELDS = frozenset(
    {
        # OpenAI chat completions
        "model",
        "messages",
        "stream",
        "stream_options",
        "temperature",
        "top_p",
        "max_tokens",
        "max_completion_tokens",
        "stop",
        "n",
        "seed",
        "presence_penalty",
        "frequency_penalty",
        "logit_bias",
        "logprobs",
        "top_logprobs",
        "tools",
        "tool_choice",
        "parallel_tool_calls",
        "response_format",
        "user",
        "reasoning_effort",
        # DeepSeek thinking switch (pi)
        "thinking",
        # OpenRouter reasoning effort (gptel)
        "reasoning",
        # OpenRouter: provider routing preferences (sort, order, only, …)
        "provider",
    }
)
# The guard reads the body before authentication: this bounds its memory.
MAX_BODY_BYTES = 16 * 1024 * 1024
TOO_LARGE = "llm-gateway: request body too large"
GUARD_HEADER = (b"x-llm-gateway", b"body refused")  # marks the guard's 400 and 413


def route_gate(app):
    """Pass lifespan events and ALLOWED_ROUTES to `app`; answer every other
    request 404 (GATE_REFUSAL, GATE_HEADER) and close every websocket,
    without reaching it. Some LiteLLM routes never call custom_auth (RV-024
    F-1), so routes are filtered here rather than in a hook. A route matches
    only verbatim: method, decoded path and, when given, raw path, so
    encodings, case, slashes and other methods all miss. A POST passes only
    through the body guard."""

    async def gated(scope, receive, send):
        if scope["type"] == "lifespan":
            await app(scope, receive, send)
        elif scope["type"] == "websocket":
            await send({"type": "websocket.close", "code": 1008})
        elif not _allowed(scope):
            await _respond(send, 404, GATE_HEADER, GATE_REFUSAL)
        elif scope["method"] == "POST":
            await _guard_body(app, scope, receive, send)
        else:
            await app(scope, receive, send)

    return gated


def _allowed(scope):
    if scope["type"] != "http":
        return False
    route = (scope["method"], scope["path"])
    raw = scope.get("raw_path")
    return route in ALLOWED_ROUTES and (raw is None or raw == scope["path"].encode())


async def _guard_body(app, scope, receive, send):
    """Read the whole body, before LiteLLM, and pass it on only when it is a
    JSON object whose fields are all on ALLOWED_FIELDS: else 400, or 413
    over MAX_BODY_BYTES (declared, or once read). `app` reads the body as
    one http.request message, then `receive` as it was."""
    if _too_large(_declared_length(scope)):
        return await _refuse(send, 413, TOO_LARGE)
    body = await _read_body(receive)
    if body is None:
        return  # the client left
    if _too_large(len(body)):
        return await _refuse(send, 413, TOO_LARGE)
    error = _body_refusal(body)
    if error:
        return await _refuse(send, 400, error)
    replayed = False

    async def replay():
        nonlocal replayed
        if replayed:
            return await receive()
        replayed = True
        return {"type": "http.request", "body": body, "more_body": False}

    await app(scope, replay, send)


def _body_refusal(body):
    """Why a request body is refused, or None: it must be a JSON object
    whose top-level fields are all on ALLOWED_FIELDS. Every unlisted field
    is named, sorted."""
    try:
        data = json.loads(body)
    except (ValueError, RecursionError):
        data = None
    if not isinstance(data, dict):
        return "llm-gateway: body is not a JSON object"
    refused = sorted(data.keys() - ALLOWED_FIELDS)
    if refused:
        return "llm-gateway: " + ", ".join(f"field {f!r} not allowed" for f in refused)
    return None


def _too_large(length):
    return length > MAX_BODY_BYTES


def _declared_length(scope):
    """The content-length header, or 0: absent or unreadable, the bytes read
    are capped instead."""
    for name, value in scope.get("headers", ()):
        if name == b"content-length":
            try:
                return int(value)
            except ValueError:
                return 0
    return 0


async def _read_body(receive):
    """The request body, read no further than past MAX_BODY_BYTES; None if
    the client disconnects first."""
    body = bytearray()
    while True:
        message = await receive()
        if message["type"] == "http.disconnect":
            return None
        body += message.get("body", b"")
        if _too_large(len(body)) or not message.get("more_body", False):
            return bytes(body)


async def _refuse(send, status, error):
    await _respond(send, status, GUARD_HEADER, json.dumps({"error": error}).encode())


async def _respond(send, status, marker, body):
    await send(
        {
            "type": "http.response.start",
            "status": status,
            "headers": [(b"content-type", b"application/json"), marker],
        }
    )
    await send({"type": "http.response.body", "body": body})


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
    """Refuses a request naming a model off the key's list: LiteLLM does not
    enforce UserAPIKeyAuth.models for custom auth (DEC-046). Fallbacks name
    models too, and the Router serves them (RV-026 F-4); LiteLLM's own
    enumeration of them is reused, so it tracks the Router."""

    async def async_pre_call_hook(self, user_api_key_dict, cache, data, call_type):
        row = {"models": user_api_key_dict.models or []}
        for model in _named_models(data):
            if not keystore.allows_model(row, model):
                raise HTTPException(
                    status_code=403,
                    detail=f"{user_api_key_dict.key_alias}: model {model!r} not allowed",
                )
        return data


def _named_models(data):
    """The model the request asks for, then every fallback it names."""
    yield data.get("model")
    for target in iter_request_fallback_targets(data):
        yield target.get("model") if isinstance(target, dict) else target


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
