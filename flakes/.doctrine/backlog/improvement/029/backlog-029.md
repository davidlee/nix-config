# IMP-029: Add OpenRouter, Fireworks and OpenAI providers to the LLM gateway

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Context: SL-011's gateway configures DeepSeek only, so the jailed eca lost its
OpenRouter models (accepted by the user 2026-10-17; listed in README § LLM
gateway, "What it does not cover"). The user wants OpenRouter, Fireworks
(fireworks.ai) and OpenAI behind the gateway eventually; no urgency.

Per provider: an entry in `services.llm-gateway.providers` (1Password ref,
`just gateway-credentials`), its models in `services.llm-gateway.models`
(each must be in LiteLLM's packaged price map — a flake check enforces it;
OpenRouter's per-model pricing may need checking), then reissue or extend
the eca key's model list. Related: IMP-028.
