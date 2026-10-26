# IMP-045: W2 — Refactor pass over the agents jail library

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Programme W2. `agents/jailed-agents.nix` is 843 lines (test 770). A cohesion
and coupling pass, done alongside or just after W1 (IMP-044) so the ro/rw work
lands in clean code.

Known debris:
- `agents/jailed-agents-refactor.local.md` — a handover that still refers to
  the old `pub/` layout; decide whether any of it is live, then drop it.
- `agents/examples/go-project` — predates the gateway.
- the handover's deferred items: split the module, merge the two profile maps,
  reduce maker boilerplate, rationalise `commonPkgs`.

Related: CHR-020 (tech spec for the jail library), IMP-036 (jail test
helpers), IMP-042 (refuse `$HOME` launch dir).

Followed by IMP-051 (jail-scan checks move upstream from satan; `useOpEnv`
and the op outer wrapper removed), which edits the same module.
