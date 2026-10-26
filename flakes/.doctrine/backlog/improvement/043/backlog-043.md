# IMP-043: Agents lib exports the rendered pi gateway models.json (and gateway data) so consumers stop importing gateway.nix

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Raised from screwtape:CHR-001 (its last open item, 2026-10-27).

**Problem.** The agents flake's lib exports `piGatewayConfig` (the renderer,
`agents/pi-gateway.nix`) but not the data it renders, so consumers import an
internal file of the flake:

- `~/dev/screwtape/flake.nix:67`:
  `gatewayModels = (import "${agents}/gateway.nix").models;`, then renders
  `models.json` itself for its quotient forms' `piFiles`
  (`flake.nix:81-83`), duplicating `agents/jailed-agents.nix:502-504`
  (`piGatewayModels`).
- `~/dev/satan/flake.nix:258`:
  `gatewayClientSocket = (import "${inputs.agents}/gateway.nix").clientSocket;`.

Any change to `gateway.nix`'s shape breaks both silently at their next
re-lock.

**Proposal.** Export from the agents lib what consumers need, for example:

- the rendered pi `models.json` (the derivation `jailed-agents.nix` already
  builds as `piGatewayModels`), and
- the gateway's public facts (`url`, `clientSocket`, `relayPort`, `models`)
  as a stable attrset.

Then move screwtape and satan onto the export.

Done when:

1. the agents lib exports the rendered `models.json` and the gateway facts,
   with a check covering the export;
2. no flake outside `~/flakes/agents` imports `gateway.nix`: screwtape
   (`flake.nix:67`, `:81-83`) and satan (`flake.nix:258`) use the export,
   each with its own `nix flake check` green;
3. screwtape's forms are rebuilt (`just quotient-forms`), and the operator
   re-runs `quotient allow ~/dev/screwtape` if their identities changed.

**Progress (2026-10-27).**

- Done 1: `jailed-agents.nix` exports `piGatewayModels` (one renderer,
  `piGatewayModelsFor url`, which `makeJailedAgent` also uses) and
  `gatewayFacts` (`url clientSocket relayPort models`);
  `checks.jailed-agents` asserts the export is the file a gateway jail binds
  (and matches the literal oracle) and the facts' names.
- Done 2, against `--override-input agents path:~/flakes/agents`:
  screwtape and satan use the exports; no `.nix` under `~/dev` imports
  `gateway.nix`; each `nix flake check` green; every package drvPath of both
  is unchanged.
- 3 needs nothing: screwtape's form drvPaths are unchanged, so their
  identities are too.
- Re-locked from the pushed `73516b60`: screwtape `19ae504` (`nix flake
  check` green); satan `dfa115e`, verified by `nix flake check --no-build` of
  its HEAD (a full build was running there under another agent).
- Out of scope: `features/satan/runner.nix` renders the same catalog
  in-tree (relative import, no `jailLib` in that home module).
