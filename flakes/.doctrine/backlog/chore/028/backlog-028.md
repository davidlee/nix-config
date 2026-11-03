# CHR-028: Drop root flake's doctrine.inputs.{agents,pub}.follows once satan, screwtape and panopticon re-lock Doctrine

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

SL-023 (DEC-111) removes the `agents` input (and with it what `pub` follows) from
Doctrine's flake. The root `flake.nix` still says
`doctrine.inputs.pub.follows = "agents"` (panopticon, :85) and
`doctrine.inputs.agents.follows = "agents"` (satan :94, screwtape :115).
Each line can go once the project it sits under has re-locked a Doctrine
without those inputs. Before then, removing it changes that project's locked
Doctrine graph. After it, Nix is expected to warn about an override for a
non-existent input (not run).

Done when the three lines are gone and `just coverage` evaluates cleanly.

## Evidence: SL-023 PHASE-06 (2026-11-04)

Doctrine e37ecf2a3 drops `agents` and `quotient`. Evaluating the root flake
with `satan/doctrine` and `screwtape/doctrine` overridden to that checkout
(`--override-input … git+file:$HOME/dev/doctrine`), both
`homeConfigurations."david@Sleipnir"` and `nixosConfigurations.Sleipnir`
evaluate (rc 0) with only warnings:

    warning: input 'satan/doctrine' has an override for a non-existent input 'agents'
    warning: input 'screwtape/doctrine' has an override for a non-existent input 'agents'

So the expectation above holds: a warning, not a refusal. The lines go once
each project re-locks a Doctrine at or after e37ecf2a3 (and Doctrine is pushed).
