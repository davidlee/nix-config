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

## Assessment (2026-10-17)

Evidence, not a decision.

### Fit

```
             model door (gateway)
            ▲                   ▲
  bwrap jail (agents/)    capsule / room (oubliette)
  light, per devshell     strong, per fleet
```

- `agents/` is published already, in practice. About nine `~/dev` repos take
  it, and six still go through the deprecated `flakes/pub` shim (bough,
  panopticon, forgettable, checkout-doctrine, lazyspec, agentdoc). Every
  consumer lock pins a whole nix-config revision, so each dotfiles commit
  looks like an `agents` bump to them.
- What the gateway adds is per-client keys with model allow-lists and
  budgets, the route gate, and the hardened socket relay. nixpkgs'
  `services.litellm` covers only hosting LiteLLM. The gateway is generic
  only after its hardcoded parts become options: port 4000, the 1Password
  refs (`proxy.nix` defaults), the credentials encrypted with the host's
  TPM chip (DEC-048), and a model list fixed by `agents/gateway.nix`.
- Oubliette (`~/dev/oubliette`, firecracker capsules that confine agents) is
  aligned with both:
  - its Plan F §2, "the model door", consumes this gateway from a room
    through a `socat` forwarder;
  - its Plan B describes a light local tier next to the VM, roughly what
    `agents/` is.

### Cost

- SL-011, SL-013 and SL-014 changed the jail and the gateway together, and
  DEC-058 to DEC-066 are all from this month. Splitting now turns each such
  change into two repos, two locks and a `dev-checkouts` override.
- Governance would be split across repos: the DECs, RVs and slices would
  need cross-repo `repo:ID` references. DEC-059's rationale ("root→agents
  within one repo") needs revisiting, though its dependency direction
  survives.
- Generalising the gateway is about one slice: module options, a credential
  source that doesn't need 1Password or a TPM, and docs that don't assume
  pi or eca.
- The dotfiles gain one input, which the `dev-checkouts` pattern already
  handles (goad, satan-*, fleet).

### Coupling to settle first

`agents/gateway.nix` holds three things: the address, the served models,
and pi's per-model blocks (DEC-063). Under DEC-059 both the jails and the
gateway read it, and the gateway record reaches it by a relative path
(`../../../agents/gateway.nix`) that crosses the sub-flake boundary.
Preferred split:

1. The gateway owns the address and the served models.
2. The jail library takes the client value (`url`, `keyFile`) from its
   caller, so it never depends on oubliette.
3. pi's blocks stay with the jails as client-side data.

The reverse (oubliette depending on the jail library) puts the stronger
perimeter downstream of the convenience layer.

### Recommendation

1. Move the gateway's NixOS module and Python into oubliette, exported as
   `nixosModules.llm-gateway`. The module uses the consumer's `pkgs`, so
   LiteLLM is evaluated only when the gateway is enabled, and
   `features/agents.nix` keeps a thin record that sets its options. The room
   is the gateway's second consumer, which is the signal that it is worth
   generalising.
2. Keep `agents/` in this repo for now. Folding it into oubliette would make
   lightweight devshell consumers lock its inputs (microvm.nix,
   doctrine/edge), tie them to a NixOS + KVM project, and stretch
   oubliette's POL-002 (its host knows nothing about each project). Revisit
   if Plan B's light tier is built there.
3. Independent and cheap: migrate the `flakes/pub` consumers, then retire
   the shim.

Timing: after SL-014 closes, or as the first step of oubliette's Plan F
(oubliette IDE-002).

More speculative, and not part of this recommendation: IDE-004 (brokered git)
could take oubliette's host-initiated git channel instead of a broker. That
would make the channel a second piece the jails and oubliette share.

The same day, oubliette's `docs/plan-f-assistant.md` and its IDE-002 were
corrected. They cited IDE-003, not SL-011, and assumed LiteLLM virtual keys
with Postgres and a master key, which DEC-046 and DEC-050 rejected. Both now
cite `flakes:SL-011`.
