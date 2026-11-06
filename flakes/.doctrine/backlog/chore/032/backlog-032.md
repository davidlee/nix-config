# CHR-032: Move the remaining Doctrine repos in the fleet to capsule-tools

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

DEC-130: a fleet repo that uses Doctrine hands fleet `capsule-tools`, not `dev-tools`; the
default is `capsule-tools = dev-tools ++ [doctrine-pkg]`. That replaces this chore's
first scope, rooms the runner works in.

Targets at 2026-11-06, of 20:

| state | targets | work |
|---|---|---|
| on `capsule-tools` | doctrine, satan, malebolge, panopticon, emacs-config | none |
| `dev-tools`, no `capsule-tools` | nix-config, oubliette, resume, satan-attrd, smut, www | add it, switch the target |
| `dev-tools` at HEAD, fleet's lock predates it (db60994) | screwtape | add it, switch the target and re-lock |
| no `dev-tools`; target uses `extraTools` | deck_of_dwarf, quotient | a tool list first |
| use no Doctrine | goad, goad-walk, notes, pi, retrograde, satan-corpus | none: they pass |

Per repo: add a `doctrine` input and `capsule-tools`, push, then set
`toolsPackage = "capsule-tools"`, add `inputs.doctrine.follows = "doctrine"` in fleet and
re-lock. A repo's `dev-tools` has no Doctrine to drop, so DEC-112's third step falls away.
Fleet locks each repo's remote, so a repo must be pushed first.

malebolge's runner calls `doctrine prompt resolve` in a clone with `.doctrine/`; without
Doctrine it reports `context_degraded` and goes on. Audit: CHR-031. nix-config's
`.doctrine/` is under `flakes/`, so the runner skips it; it is here for agents working
in `flakes/`.

SPEC-003, the README and `_templates/dev-env` carry DEC-130 and the dev-envs warning
(REV-018).

Related: CHR-031, DEC-128, DEC-130.

## Outcome (2026-11-06)

All nine repos export `capsule-tools` and are pushed; fleet 37992dd sets
`toolsPackage = "capsule-tools"`, follows its `doctrine` input, and re-locks them.

| repo | commit | | repo | commit |
|---|---|---|---|---|
| oubliette | 2a2dda4 | | screwtape | 490c33b |
| satan-attrd | d181aea | | quotient | f9bdb7a |
| smut | 1bc023c | | deck_of_dwarf | 0ad20819 |
| www | 514b3ed | | nix-config | 49987f42 |
| resume | 4a639dc | | | |

Verified through fleet's lock (mem.fact.flakes.fleet-closure-check): every `dev-tools` has no
Doctrine; every `capsule-tools` and `image-<target>` has 0.48.1, one derivation across all
`capsule-tools`; only the nine named root inputs moved. `just check` passed in fleet and
oubliette, `just test` in nix-config. quotient and deck_of_dwarf gates passed on `dev-tools`
as run by their delegates, except that quotient's `just build` needs `capsule-tools` (its
`specs` step calls `doctrine`) and deck_of_dwarf's `lint-python` and `check-python` were not run.

- oubliette: `mkFleet`'s devshell no longer carries Doctrine (operator, 2026-11-06), so
  DEC-128 needs no exception. Its `doctrine` input now serves only `capsule-tools`.
- oubliette and satan-attrd were pushed with `git push`, not `just push-local`, which would
  also have pushed satan's 10 unrelated commits.
- `capsule-tools` evaluates only where Doctrine has packages (x86_64-linux, aarch64-darwin),
  so nix-config's and resume's other systems fail if forced. Same as panopticon and the template.
- smut's `alejandra` failure predates this; quotient's flake is nixfmt-styled, not alejandra.
- screwtape's forms keep their Doctrine until CHR-030 cleans the flake.

Not proven in a booted room: CHR-033.
