# IMP-066: Decide how jails delegate: relay scope, opt-in, and in-jail quotient

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->
The quotient relay (`agents/quotient-relay.nix`) is on in every networked jail,
and nothing records why. `agents/README.md` § quotient relay gives its mechanics
and, since this item, a summary of the delegation routes. SPEC-003 does not
mention it, no DEC covers it, and its history is one unrelated commit
(`17991b29`). ISS-026 showed the cost: fixing a shim defect needed a judgement
about what the relay is for, and that was not written down.

This item settles that. **ISS-026 needs it**: no code changes until it is
decided (operator, 2026-11-05).

## Routes from a jail today

| route | runs | permissions | ceilings, evidence |
|---|---|---|---|
| pi subagent extension (jailed pi) | in the jail | the jail's | none of quotient's |
| `subagents` (e.g. jailed claude runs pi) | in the jail, depth-guarded | the jail's | none of quotient's |
| quotient relay, `pi_agent` | host, in a form | the form's; root is the launch dir | yes, out of the jail's reach |
| real quotient in the jail | not available | - | - |

## Established (observed 2026-11-05, satan's `jailed-shell`, host quotient 0.6.1)

- The jail has no real quotient. `quotient` is the shim, and `initialize`
  through it is answered by the host's 0.6.1.
- The relay adds control, not reach. The narrowed policy's roots were
  `["/home/david/dev/satan"]`, from 20 host roots. `cwd=/home/david/dev/quotient`
  was refused `root-not-allowlisted`. This is deliberate: "The jail gets no more
  reach through quotient than it has itself."
- The relay can exceed the jail in one way: delegates run in host forms with
  their own network, which is why offline jails default it off.
- A `/workspace/<name>` cwd works where the host has that symlink and it
  resolves to the root. Not every entry is a symlink (`feel`, `logos`).
- satan is the only repo here with a `quotient` entry in `.mcp.json`. Per-home
  registrations (`pi mcp add`, `claude mcp add`) were not surveyed.
- Real quotient 0.6.0 in a bare `bwrap` sandbox (not a real jail):
  no policy refuses `policy-unavailable`; policy without a profile refuses
  `profile-unknown`; home inside the root refuses `view-overlaps-protected`;
  home outside the root passes every check and fails at spawn, on a stub form.
  So the evidence check compares paths and is no general barrier. A
  self-configured in-jail quotient is contained by the jail, but its controls do
  not bind the agent, which can rewrite them.
- quotient has no inherited-confinement mode: `unconfined` is write-only and
  protects nothing (quotient:IDE-008).

## Operator's position (2026-11-05), not yet tested

- The relay's value is control, plus cross-harness delegation without running
  the top-level harness unjailed.
- For already-jailed delegation, the best route about 95% of the time is
  probably quotient in the jail with no relay, inheriting the jail's permissions,
  with evidence protected from its own agents.
- Without a cross-harness need, pi subagents are usually more ergonomic: they
  get doctrine's MCP tools, extensions and the project's roles.
- The relay should be an optional capability defined in dev-envs, included per
  project. Candidates: satan, emacs, flakes.
- Safe access to other host repos would be the most compelling use. Today's
  relay forbids it, so this needs a decision, not a config change.

## Survey for question 1 (2026-11-05)

Measured from run records (`~/.local/state/quotient/runs`), transcripts and jail
homes. `policy_digest` is the SHA-256 of the policy file, so a narrowed policy's
digest can be recomputed; narrowing drops the host's root list, so the digest
depends only on the root and the other fields.

| route | measured use |
|---|---|
| host quotient, unjailed harness | 199 Claude transcripts with real `pi_agent` calls; about 930 runs since 2026-10-22 |
| jailed pi subagents | 299 of 454 session files since 2026-11-01 call `subagent` (child runs probably inflate both) |
| relay | 1 run and 1 refusal (this item's probe, 2026-11-05); 2 read runs on 2026-10-30, while it was being built |
| jailed claude or codex calling quotient | 0 transcripts |

- No jail home registers quotient, and none records a project MCP approval, so
  satan's `.mcp.json` entry has no recorded approval there.
- Unattributed: 74 runs on 2026-10-23..26 under single-directory digests. No jail
  transcript shows a matching call; host use is likelier.
- A pi subagent returns its final text (about 2 KB in samples) and usage. Its full
  transcript is under `subagent-artifacts/`, inside the jail, in the agent's reach.

Origin (host Claude session in deck_of_dwarf, 2026-10-30): the operator asked for
quotient in the pi jail, chose the host-side option over in-jail quotient, and
asked for "an option I can turn on / off ... By default on for all jails". In-jail
was set aside for nested sandboxing, the `/workspace` path mismatch and the LLM
key. The socket design copied `satanMcpOptions`; satan did not ask for the relay.
Its `.mcp.json` entry predates it (2026-10-23, satan:SL-031) and is a host
registration.

Operator's stated priorities for quotient (2026-11-05): 1. secure confinement for
unjailed orchestrators; 2. cross-harness calls with observability; 3. parallel and
serial orchestration; 4. a root per call, to dispatch to other projects; 5. limits
for tightly bounded work. quotient was built so Claude could drive pi subagents.
Cross-root writes: IDE-010.

**Settled by DEC-122 (2026-11-05).** The relay is off in every jail; the capability
is a declared jail for cross-repo delegation (IDE-010, needs quotient:IDE-009).

## Questions to settle

1. **Need.** What does the relay give that `subagents` and the pi subagent
   extension do not? jailed claude can already run pi as a `subagents` entry, so
   "cross-harness" alone may not separate them. Survey real use, including
   per-home registrations.
2. **Default.** Opt-in or on? Which jails?
3. **Home of the opt-in.** A `passthru.devEnv` key has `outerGitDir` as precedent,
   but needs a SPEC-003 revision (REQ-026 refuses other keys), and the README says
   a project "knows nothing about agents". A capability grant may belong
   host-side, beside the policy's roots.
4. **Cross-repo roots.** Reverse the narrowing rule, for read only or for write?
   A jail's real write reach would become the union of its roots, because the
   agent writes the delegate's prompt. satan:IDE-016 is the multi-root neighbour.
5. **In-jail quotient.** Adopt it once quotient:IDE-008 lands? Then what remains
   of the relay?
6. **`quotient <args>` in a jail.** Refuse, run `reduce` locally, or also `help`?
   This fixes ISS-026's shape. Options and costs are in ISS-026.
7. **Contract.** SPEC-003, or the agents spec CHR-020 proposes? IMP-064 (uniform
   forms) moves form ownership into dev-envs and should stay consistent.

## Done means

A DEC (ADR if it proves project-global) answers the questions, `agents/README.md`
and the chosen spec state the result, and ISS-026 has one agreed fix.
