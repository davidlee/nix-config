# IMP-035: OpenAI subscription (Codex OAuth) behind the LLM gateway

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Split from IMP-029 by SL-014 (DEC-072, 2026-10-17). The user wants OpenAI
behind the gateway through the ChatGPT subscription, not API billing.
gptel's `openai-sub` backend (`gpt-5.6-terra`) and agent-shell/codex sign in
with OAuth today. An API-key `providers.openai` is not the goal.

Work out how LiteLLM can serve OpenAI models on a subscription OAuth login.
Candidate: a custom LiteLLM provider such as
https://github.com/jslorrma/litellm-codex-oauth-provider (unreviewed).

Questions for the spike:

- Token custody. Where do the OAuth refresh and access tokens live, and who
  refreshes them? The service user under DEC-048-style credentials, or a
  token file? Refresh means the gateway writes a secret back, which
  DEC-048's read-only credential model does not cover.
- Packaging. Can the provider be packaged into `proxy.nix`'s Python env, and
  does it load with no network at build time?
- Cost. The ledger records LiteLLM's `response_cost`. A subscription call has
  no per-request price, so it is probably 0, which DEC-068 logs as a
  warning. Decide whether subscription models are exempt or carry a nominal
  price through `params` (DEC-070).
- Terms. Is serving a personal subscription to local jails acceptable under
  OpenAI's terms for that product?

Once it works: add the provider, name models `openai/<id>` (DEC-069), create
credentials before the switch (DEC-067), and extend keys with
`llm-gateway models` (DEC-071). Then emacs:SL-015 can move gptel's
`openai-sub` onto the gateway.
