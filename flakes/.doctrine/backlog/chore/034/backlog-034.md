# CHR-034: Revise SPEC-003 for devEnv.jails (declared jails)

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

## Intent

SPEC-003, the dev-envs contract, falls behind the code from 6081428b on
(IMP-074, nemesis:SL-026 PHASE-01/02). A project may now declare jails of its
own as `passthru.devEnv.jails`, and dev-envs builds each one as
`jailed-<name>`. The spec does not say so yet. Follows IMP-074's Follow-ups.

## Drift (spec-003.md)

- § Producer contract: the `passthru.devEnv` example has no `jails`. Line 83
  says "It names no jail, agent, form or gateway", which is no longer true for
  jails.
- § `devEnv` schema and refusals: the degrade row is now
  `{env = {}; hostEnv = []; jails = {};}`. The key list lacks `jails`. The
  jail refusals are missing (`dev-envs/dev-env.nix` `jailErrors`).
- § The jail set: "The set is the same for every project" now holds for the
  five built-in jails only. Declared jails differ: offline, no launch
  directory, ephemeral home, host integrations off.
- § Degrade and refuse: a malformed `jails` declaration is an evaluation error
  (`checks.dev-env`), and a declared jail is built and checked by
  `checks.declared-jail`.
- § Mechanism: the diagram lacks the declaredJail path.
- Cross-repo authority: nemesis:DEC-235 (jails declared as data, dev-envs
  builds them), nemesis:DEC-237 (one `hostIntegrations` switch), nemesis:DEC-236
  (`pi --no-builtin-tools`). Decide whether the spec cites them, or whether
  this repo needs a local DEC of its own.

Out of scope: the agents-library options (`ephemeralHome`, `hostIntegrations`,
`forwarderEntry`). They belong to CHR-020's future spec. `agents/README.md`
already documents them.

## Outcome (2026-11-21)

Done by REV-023, with the spec edit in the same commit. The open choice went to
a local decision (user): DEC-131 adopts nemesis:DEC-235/236/237 and amends
DEC-108, DEC-114 and DEC-122, which had kept jail vocabulary out of project
data. REQ-026's statement covers `jails`; NF-003 (REQ-031), "A declared jail
holds only what it declares", is active on `checks.declared-jail`. Every drift
item above is taken.

Left for later: `jailed-<name>-check`, the `-check` name refusal and the
launch-time `runDirectory` in the `gateway` argument (nemesis:SL-026 PHASE-02
EX-5, nemesis C-93). DEC-131 records them. SPEC-003 takes them once the code
lands here, by a small REV of its own.
