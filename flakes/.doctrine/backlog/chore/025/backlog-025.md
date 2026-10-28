# CHR-025: Gateway: drop allowed_openai_params for OpenRouter models (redundant since LiteLLM 1.106.2)

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

LiteLLM 1.106.2's `OpenrouterConfig.get_supported_openai_params` adds
`reasoning_effort` (and `thinking`) for every OpenRouter model
(`litellm/llms/openrouter/chat/transformation.py:41-46`). The
`params.allowed_openai_params = ["reasoning_effort"]` on each OpenRouter
entry in `agents/gateway.nix` (SL-014 EX-4) is therefore redundant.

`gateway-test` `PassThroughTest.test_twin_without_allowed_openai_params_also_reaches_it`
now asserts the twin without the param is served (inverted 2026-10-28 while
restoring the gateway after the LiteLLM bump; ISS-020 work).

To do: remove the param from `agents/gateway.nix` and its comment, the
`unallowed` fake model (`perSystem.nix`) with `UNALLOWED` and the twin test,
and `test_every_openrouter_entry_allows_reasoning_effort`. Re-check pi/gptel/
minuet reasoning requests still reach OpenRouter.
