# REV REV-016 — In-jail quotient in SPEC-003's jail set

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

SL-024 put the real quotient in `jailed-claude`, `jailed-codex` and `jailed-shell`
(DEC-123..127). SPEC-003 § The jail set still says `quotient` is not on a jail's
PATH and that a project's `.mcp.json` entry has no server there. Both are now true
only of `jailed-pi` and `jailed-pi-research`. The proof is in SL-024's notes,
§ PHASE-04 proof. Only what that proved is stated below.

### SPEC-003

**§ The jail set, last paragraph.** Before:

> A jail delegates through its subagents. No jail in the set carries the quotient
> relay (DEC-122): `quotient` is not on a jail's PATH, so a project's `.mcp.json`
> entry for it has no server there. The relay is a capability for a jail declared
> for cross-repo delegation (IDE-010), and it is not a `passthru.devEnv` key.

After:

> A jail delegates through its subagents. `jailed-claude`, `jailed-codex` and
> `jailed-shell` also carry the real quotient, declared by `quotientServer`
> (DEC-123): it is on their PATH, claude and codex have it registered as an MCP
> server, and its delegates run in the project's forms, nested in the jail.
> `jailed-pi` and `jailed-pi-research` do not: `quotient` is not on their PATH, so
> a project's `.mcp.json` entry for it has no server there.
>
> That server runs under the jail's own read-only policy, not the host's. Its root
> is `/workspace`, so the jail's mounts are its limit, and it names its forms, so
> nothing needs `quotient allow` in a jail. Profiles are the host's directory,
> bound read-only (DEC-126). Its protection binds delegates, not the agent.
> `agents/README.md` § In-jail quotient has the mechanics.
>
> No jail in the set carries the quotient relay (DEC-122). The relay is a
> capability for a jail declared for cross-repo delegation (IDE-010), and it is
> not a `passthru.devEnv` key.

**§ Forms, "Approval is the operator's act".** Before: "Approval is the operator's
act: `quotient allow`, again after every form rebuild." After: "On the host,
approval is the operator's act: `quotient allow`, again after every form rebuild."

**§ Concerns, "A form rebuild needs approval".** Before: "quotient refuses delegates
until `quotient allow` runs." After: "the host's quotient refuses delegates until
`quotient allow` runs."

**§ Decisions, the `delegation from a jail` row.** Before: `DEC-122`. After:
`DEC-122, DEC-123, DEC-124, DEC-125, DEC-126, DEC-127`.

No requirement changes: none of SPEC-003's requirements names quotient in a jail,
and `quotientServer` is not a `passthru.devEnv` key, so REQ-026 is untouched.
