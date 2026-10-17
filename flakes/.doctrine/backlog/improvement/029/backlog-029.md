# IMP-029: Add OpenRouter, Fireworks and OpenAI providers to the LLM gateway

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Context: SL-011's gateway configures DeepSeek only, so the jailed eca lost its
OpenRouter models (accepted by the user 2026-10-17; listed in README § LLM
gateway, "What it does not cover"). The user wants OpenRouter, Fireworks
(fireworks.ai) and OpenAI behind the gateway eventually; no urgency.

Per provider: an entry in `services.llm-gateway.providers` (1Password ref,
`just gateway-credentials`), its models in the `models` of `agents/gateway.nix` (with a `pi` block)
(each must be in LiteLLM's packaged price map — a flake check enforces it;
OpenRouter's per-model pricing may need checking), then reissue or extend
the eca key's model list. Related: IMP-028.

**Price-map lag (added 2026-10-17, from SL-013 design).** The gateway prices
models from LiteLLM's packaged map (`LITELLM_LOCAL_MODEL_COST_MAP=True`,
`features/agents/gateway.nix:123`; nixpkgs litellm 1.102.1). DEC-051's check
refuses a model the map lacks, so a new model waits for LiteLLM → nixpkgs →
our lock. SL-013 also derives pi's model metadata from that map (DEC-060). Options: (c, preferred) pin the map JSON as its own flake
input from LiteLLM's repo, bumped with `nix flake update` — needs a spike:
can LiteLLM load a local map (`LITELLM_MODEL_COST_MAP_URL` accepting a file
path is unverified)?; (a, fallback) hand-entered per-model costs in the
config, with the check accepting "packaged or explicitly priced"; (b,
rejected for now) fetch the live map at start.
