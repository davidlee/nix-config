# ISS-027: Gateway ends ChatGPT streamed tool calls with finish_reason stop, so clients never run the tool

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

## Symptom

A streamed chat completion on `chatgpt/gpt-6.1-terra` carries a complete tool
call and ends with `finish_reason: "stop"`. A client that runs tools only on
`tool_calls` ends the turn with the call unexecuted and no error. pi-durable
does (generation.js:397), so SATAN went silent and malebolge's VH-1 is blocked.

## Evidence

- Reproduced 2026-11-05 at the gateway: one streaming request, HTTP 200, a
  complete `echo` call across 6 chunks, final chunk `finish_reason: "stop"`.
- Malebolge's session store: terra `tool_calls` x193 (29 Oct - 1 Nov), then
  `stop` x8 with tool calls (5 Nov 16:00 - 19:49). deepseek-flash unaffected.
- LiteLLM's streaming bridge sets `tool_calls` only if `response.completed`
  lists a function call in `output`
  (`completion_extras/litellm_responses_transformation/transformation.py`, about
  line 1826). It ignores tool calls already streamed. The non-streaming ChatGPT
  path rebuilds an empty `output` from streamed items
  (`llms/chatgpt/responses/transformation.py:217`); the streaming path does not.
- LiteLLM moved 1.106.4 -> 1.106.6 in system generation 1158 (2026-11-04 22:07).
  That bridge and the `llms/chatgpt` Python sources are identical in both. Six
  other `.py` files and `rust_bridge/_native.abi3.so` differ.

## Inference (unconfirmed)

The ChatGPT backend began sending an empty `output` in `response.completed`
between 1 and 5 Nov. The raw backend stream was not inspected, and the changed
Rust bridge is not excluded. The other `chatgpt/*` models share the path but are
untested.

## Proposed fix

A sketch, not agreed. A `CustomLogger.async_post_call_streaming_iterator_hook` in
`gateway_hooks.py`: on a `chatgpt/` model, remember whether any chunk carried
`delta.tool_calls`, and rewrite a final `stop` to `tool_calls`. Correct whichever
cause holds. Test with a fake ChatGPT stream holding a tool call and an empty
`output`; the current fixture streams only a text message. Report upstream.

Workaround: use `deepseek-flash` for tool use.

## Fix (2026-11-05)

`ChatGPTToolCalls` in `gateway_hooks.py`, registered in `proxy.nix`, as sketched
and agreed. `gateway-test`'s fake stream with a tool call and an empty `output`
reproduced `stop` before the hook. That shows the mechanism, not that the real
backend sends an empty `output`. Other reasons and other models pass unchanged.

Deployed 2026-11-05; the user tested it live and reports it works.

Remove the hook once LiteLLM counts streamed tool calls. Still to do: report
upstream, then resolve this item.

## Reported upstream (2026-11-08)

https://github.com/BerriAI/litellm/issues/50530. Reproduced on 1.108.0 against the stream
iterator: the same streamed tool call ends `tool_calls` with `output` populated and `stop` with
it empty. `main` has the same logic. Remove `ChatGPTToolCalls` once a LiteLLM release fixes it.
