# IMP-038: Test flat reasoning_effort through the gateway on every provider

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

DEC-074 makes flat `reasoning_effort` the shape every client sends, on every
model. Verified only on OpenRouter routes (SL-014 VT-3, VH-2). Unverified:

- DeepSeek with `reasoning_effort` alone (no `thinking`): does LiteLLM's
  adapter map it, or drop it?
- Fireworks: does the adapter pass it to the upstream body?

Add a case per provider to `features/agents/gateway/gateway-test` (fake
upstreams, as VT-3 does) that asserts the upstream body carries the
provider's effort field. If a provider drops it, that refutes DEC-074 for
that provider and needs a new decision (allowed_openai_params, or a
narrower contract).
