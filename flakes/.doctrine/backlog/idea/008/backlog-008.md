# IDE-008: Publish the LLM gateway and jailed agents as a standalone project

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Raised by the user during SL-014 design (2026-10-17), out of that slice's
scope: is the LLM gateway (SL-011, `features/agents/gateway*`) plus the
jailed-agents sub-flake (`agents/`, already published as a flake template)
valuable enough to others to be one coherent published project, rather than
living in this dotfiles repo? And would that make the dotfiles harder to
work on?

Starting points for an assessment:

- `agents/` is already a published sub-flake. DEC-059 and DEC-063 keep it
  free of root imports and of LiteLLM.
- The gateway is a NixOS record that reads `agents/gateway.nix`. Its
  Python (`gateway_hooks.py`, `keystore.py`, the `llm-gateway` CLI) is
  generic, but its 1Password refs, TPM credentials (DEC-048) and loopback
  relay (DEC-047) are opinionated.
- Cost to the dotfiles: another input to lock and bump, and the dev-checkout
  override (`bin/dev-checkouts`) for edits without a push. That pattern
  already exists for the satan-*, goad and fleet inputs.
