# IMP-058: Drop the jail library's JAILED_AGENT_DEPTH subagent guard: pi, claude and codex each bound their own depth

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`agents/jailed-agents.nix` wraps each exposed subagent in a `jailed-<name>`
script (`mkSubagentPkg`) that counts `JAILED_AGENT_DEPTH` against
`maxSubagentDepth` before exec'ing the bare agent. The user notes (2026-11-03,
during SL-023's drafting) that pi, claude and codex each bound subagent depth
themselves, so the library's guard is almost certainly surplus.

To settle before removing: whether each harness's own bound applies when one
harness spawns *another* (claude → pi → codex), which is the case the shared
counter was written for; and what `maxSubagentDepth`, `allowSelfAsSubagent` and
the `jailed-<name>` names mean to callers once the counter goes (the makers'
arguments, `dev-envs/flake.nix`, the six project flakes, satan).

Not SL-023's scope: SL-023 keeps the subagent graphs as Doctrine has them.

## Resolution (2026-11-04)

Kept. The operator wants the shared counter for cross-harness chains
(claude → pi → codex): each harness bounds its own depth, but none bounds a
chain that spans harnesses. `maxSubagentDepth` and `allowSelfAsSubagent` stay
as they are. Not verified: how each harness's own bound behaves.
