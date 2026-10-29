# ISS-021: ChatGPT backend refuses mid-conversation system messages

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Found 2026-10-30 from a SATAN room handoff: `malebolge-room` turns on
`chatgpt/gpt-6.1-terra` failed 400 `{"detail":"System messages are not
allowed"}` (room session.sqlite records 2959, 2963). Part of IMP-035.

## Evidence

Probes through the gateway on `chatgpt/gpt-6.1-terra` (LiteLLM 1.106.2):

| messages | result |
|---|---|
| leading system or developer, string content | 200 |
| system or developer after a user message | 400 |
| system or developer with list content | 400 |
| system only | 400 |

- LiteLLM's chat→responses bridge
  (`completion_extras/litellm_responses_transformation/transformation.py:584-613`)
  lifts only leading string-content system messages into `instructions`; any
  other stays an `input` item, which the backend refuses.
- pi refreshes system prompt sections mid-conversation (after tool calls) as
  developer messages when compat `supportsMidConvoSystemMessages` is true,
  which `agents/gateway.nix` `openaiCompat` sets; malebolge reads that compat
  from the gateway catalog.

## Design (user-approved 2026-10-30)

Rejected: `supportsMidConvoSystemMessages = false`. pi then folds every
update into the leading prompt, which invalidates the prompt cache from the
start at every refresh. Hoisting updates into `instructions` has the same
cost: `instructions` precede `input`.

Chosen: rewrite messages for chatgpt deployments in `gateway_hooks.py`.

```
messages (chat completions)              ChatGPT backend (responses)
system/developer, leading, string  ───>  instructions            unchanged
system/developer, leading, list    ───>  instructions            text parts joined
system/developer, later            ───>  user item, same place   wrapped <system>…</system>
system/developer only              ───>  user item               (nothing follows)
```

- Pure function over messages; called from a CustomLogger
  `async_pre_call_deployment_hook`, scoped to deployments whose LiteLLM
  model is `chatgpt/…` (the deployment, so fallbacks are covered).
- The leading prompt stays fixed and updates are appended in place: the
  prefix, and so the cache, survives a refresh.
- The `<system>` wrapper marks converted text as not the human's; fixed, so
  cache-neutral.
- `supportsMidConvoSystemMessages` stays true: the route now supports it.

Tests: the fake ChatGPT upstream refuses system/developer `input` items as
the backend does; ChatGPTTest sends mid-conversation system and developer
messages and a list-content leading prompt and expects 200 with the shape
above; a unit test of the pure function.

## Implementation (2026-10-30)

- `features/agents/gateway/gateway_hooks.py`: `chatgpt_messages` (pure) and
  the `chatgpt_roles` callback (`ChatGPTRoles.async_pre_call_deployment_hook`),
  registered in `proxy.nix` between `model_gate` and `ledger`.
- `gateway-test`: the fake ChatGPT upstream now refuses system/developer
  `input` items (400, the backend's body). Red reproduced the live error
  verbatim; `ChatGPTTest.test_system_messages_after_the_prompt_reach_it_in_place`
  and `ChatGPTMessagesTest` (3 tests) are green. `just test` green.
- Live check pending a `system-switch`: a room turn on
  `chatgpt/gpt-6.1-terra` with a tool call, no `stopReason: "error"`.
