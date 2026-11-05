# IMP-068: Ship the zmx wrapper in every jail

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Handoff from zmux: `zmux:IMP-001`, `tk-pi-install`. Operator chose `commonPkgs`
on 2026-11-06. Agreed sketch, no slice.

`pi-zmx` loads from the shared jail home, so every jail needs `zmx` on PATH, and it
must be the wrapper for sessions to conform. Only zmux's own `dev-tools` carries it now.

## Sketch

- `agents/flake.nix`: input `zmux` at `v0.1.1`, following `nixpkgs`.
- `mkJailedAgents` passes `zmux.packages.${system}.zmx` to `jailed-agents.nix` as
  `zmx`, and `commonPkgs` lists it. A package argument, not an overlay: `dev-envs`
  hands in its own `pkgs`, which an overlay inside this flake would not reach.
- A check builds an env from the real `commonPkgs` and fails unless `bin/zmx` is
  the wrapper.
- Root `flake.nix`: bump `zmux` to `v0.1.1`.

Afterwards: relink forms, `quotient allow` (operator), switch (operator).

## Outcome, 2026-11-06

f86c78a4. `just gate` and `just coverage` pass. In the `dev-envs` stub project's jail,
which has no `zmx` of its own, `zmx` is the wrapper; `jailed-pi` made a labelled session.
