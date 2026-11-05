# IDE-010: Cross-root delegation jail: a dedicated jail that may write other host repos through quotient

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->
A jailed orchestrator that dispatches delegates into other host repos, through
quotient, with writes. From IMP-066 (operator, 2026-11-05): the use "probably has
legs", and would be a new jail defined for that capability, not a change to
existing jails.

Today's relay forbids it. Each connection's policy is narrowed to the launch dir
(`agents/quotient-relay.nix`), so `cwd` in another repo is refused
`root-not-allowlisted`. That narrowing stays for every other jail.

The cost: the agent writes the delegate's prompt, so this jail's real write reach
is the union of its roots. Granting it is a deliberate act, and the jail's
definition should make that visible.

Settled in IMP-066 (operator, 2026-11-05):

- A new jail declaration carries the capability, defined globally or in a project.
  Other jails have no relay.
- Its roots are a declared list, a named subset of `workspaceDeps` union
  `workspaceDepsRw`, each entry stating `ro` or `rw`. Delegate access is separate
  from the jail's own mount: a dep mounted read-only for the agent may be `rw` for
  its delegates, and other agents in the project get no such grant.
- The dep mount lets the agent inspect what delegates wrote. Path mapping between
  `/workspace/<name>` and the host path remains a minor friction.

**Blocker: quotient cannot express per-root access.** In `quotient-policy/2`,
`roots` is a flat list and `profiles` pins each profile to a capability for the
whole policy (`quotient help policy`, 0.6.1). The relay's `ro` mode works on that
whole policy. Options:

- a quotient change, so a root can state its capability (preferred: the rule
  belongs with the policy, and the server enforces it);
- two relay sockets, one policy each: two MCP registrations, and delegates' `ro`
  and `rw` calls go by different tool names.

Remaining questions:

1. Who grants it: the jail definition alone, or also the host policy, whose roots
   a jail must stay inside as today?
2. One root per call stays (satan:IDE-016 is multi-root); is that enough?

No demand yet: no recorded run has needed it.
