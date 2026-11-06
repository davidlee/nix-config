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

SPEC-003 § Producer contract and README § Jailed Agents say "a room that needs Doctrine".
They want a revision to DEC-130. The revision should also add the dev-envs warning to
SPEC-003 § Refusals: a shell whose `dev-tools` holds `bin/doctrine` warns at entry and
still starts (`doctrineWarning`, `dev-envs/dev-env.nix`). A warning, not REV-017's
out-of-scope refusal, by the operator's choice.

Related: CHR-031, DEC-128, DEC-130.
