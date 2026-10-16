# VM enablers and agents onto the tree (RFC-001 W6 + W2)

## Context

RFC-001's roadmap ends in W7: `nixosvm`, a headless aarch64-linux guest on the
Mac. W7 needs three things first: W6 (VM enablers), W2 (agents onto the
feature tree) and an answer to QUE-004 (the VM's shape). This slice takes W6
and W2. QUE-004 stays with W7.

```
W6  ISS-003  overrides name Linux-only checkouts ──┐
    IMP-010  meta.nix unvalidated                  ├──> W7 nixosvm
W2  agents smeared across overlay/nix.nix/home ────┘
```

**W6.** The justfile's `system_override` names `~/dev/oubliette`. Overrides
are fetched eagerly, so `system-*`, `drvs`, `update-local` and (until
0c6ddad7) `just probe` fail on any host without that checkout. The same bit
the Mac during SL-008's VH-2. `hosts/<h>/meta.nix` is plain data: a
misspelled `kind` silently drops the host (IMP-010).

**W2.** Jailed agents span four places:

| piece | where today | applies to |
|---|---|---|
| agents overlay (`overlays/agents.nix`, `agentsOverlay system`) | `hosts.nix:79,102,202`, every evaluation | every host, unconditionally |
| `nix.registry.agents` | `modules/nixos/nix.nix:23` (NixOS base) | every NixOS host |
| `eca.nix` (jailed ECA server for Emacs) | `hosts/Sleipnir/home.nix`, direct import | Sleipnir |
| `chatgpt.nix` (`llm-agents.chatgpt`) | `hosts/Sleipnir/home.nix`, direct import | Sleipnir |

RFC-001 W2: "The overlay is chosen before evaluation, so the factories read
the selection (ADR-001 allows this). `registry.agents` splits out of
`nix.nix`. Decide eca and chatgpt: agents or personal. Starts from the
DEC-015 shape." It is the likeliest first ADR-004 selection-dependent
integration, and HYP-001's (the resolver suffices) next real test.

## Scope & Objectives

1. **ISS-003: overrides per host.** No recipe evaluates an override whose
   source is absent on this host. Candidate mechanism IDE-002: each host's
   local-checkout overrides are host data in `meta.nix`, and the justfile
   derives the flags. Design picks the mechanism.
2. **IMP-010: validate `meta.nix`.** A small schema (`kind` enum, `system`,
   `home`, plus any field objective 1 adds), checked by `hosts.nix`, with
   resolver-style tests. A bad meta fails every evaluation, naming the file.
3. **W2: agents as a feature.** An `agents` area (or record) holding the
   registry alias (nixos half), eca and chatgpt (home halves, if they are
   agents and not personal), selected by Sleipnir through a profile or host
   file. The overlay is applied according to the selection rather than
   unconditionally, if design confirms that is wanted (OQ-1).
4. Sleipnir's selection and outputs are unchanged, proved by the drv gate
   (`just drvs`, `drvs-sets`, `probe`, `coverage`), except where a behaviour
   change is named in the design.

## Non-Goals

- W7 itself: the `nixosvm` host, its machine config, DNS (QUE-004).
- The agents flake's own contents (`agents/`: jail, factories, `dirge`,
  templates).
- IDE-003..005 (credential broker, brokered git, transcript scanning).
- IMP-023 (goad on darwin), IMP-011 (username per host, W8).
- W9 tidying (per-host overlays into features, alarm, doctor naming).

## Open questions

- **OQ-1** Does the agents overlay become selection-driven? Today every
  evaluation gets it, including the devshell `legacyPackages` behind
  `registry.agents` and `nix shell agents#…`. Conditional application changes
  `pkgs` for hosts that deselect it; is there such a host before W7?
- **OQ-2** eca and chatgpt: `agents.*` features, or `personal`?
- **OQ-3** ISS-006 (flake.lock pins `agents` and dev inputs as local paths):
  in scope? It is the lock-side twin of ISS-003, and W7's VM cannot fetch a
  path pinned to Sleipnir. Leaning in, if it stays small.
- **OQ-4** Where override data lives: `meta.nix` (IDE-002) or a per-host
  file beside it, and whether `just` reads it by `nix eval` (cost per recipe)
  or something cheaper.

## Risks

- Overlay placement moves `pkgs` for every host: a drv-gate diff that is hard
  to call order-only. Mitigation: gate per phase, overlay change isolated in
  its own phase.
- Recipe changes are easy to break on the Mac without a Mac to test on.
  Mitigation: evaluate the justfile on both OSes (`just --evaluate`), and a
  VH item for a Draupnir run.

## Verification intent

- `just test`: new tests for meta validation and any resolver/factory change.
- `just gate` green; Sleipnir and Draupnir drvs identical except named
  behaviour changes.
- A host without `~/dev/oubliette` (simulated: override target absent)
  evaluates `drvs` and `probe`.
- VH: `just drvs` and `just probe` on Draupnir.

## Follow-Ups
