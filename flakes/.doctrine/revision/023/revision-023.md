# REV REV-023 — SPEC-003: declared jails

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

IMP-074 (6081428b, nemesis:SL-026 PHASE-01/02) lets a project declare a jail of
its own as `passthru.devEnv.jails`, which dev-envs builds as `jailed-<name>`.
SPEC-003 said a project names no jail and that the jail set is the same for
every project. CHR-034 lists the drift. DEC-131 records the change here and
amends DEC-108, DEC-114 and DEC-122; it adopts nemesis:DEC-235, DEC-236 and
DEC-237 rather than citing them alone (user, 2026-11-21).

The spec edit is in the same commit; the diff is the before/after. By section:

- **Overview, layer table.** The project knows no agent beyond the harness of a
  jail it declares; its row owns "any jail of its own".
- **Producer contract.** The example gains `jails`. "It names no jail, agent,
  form or gateway" becomes: none of dev-envs' own; it may declare jails.
- **`devEnv` schema and refusals.** The degrade row gains `jails = {}`, the key
  list gains `jails`, and ten rows give `jailErrors`' refusals.
- **What each surface gets.** The jail column is the five built-in jails.
- **The jail set.** "The set is the same for every project" holds for the five.
- **Declared jails (new).** The vocabulary, what a declared jail lacks and
  holds, mount and forward semantics. Library options stay CHR-020's.
- **The shell, Degrade and refuse, Mechanism.** Declared jails on the shell's
  PATH; malformed declarations and an unset mount variable; the declaredJail
  path, `checks.declared-jail`, and IMP-074's live run.
- **Responsibilities, Hypotheses, Decisions.** One responsibility added; the
  first hypothesis restated for declared jails; a DEC-131 row.

Requirements: REQ-026's statement gains "a jails declaration outside its
vocabulary". NF-003 (REQ-031) is new, "A declared jail holds only what it
declares", and is active on `checks.declared-jail`, green 2026-11-21.

Not taken: `jailed-<name>-check`, the `-check` name refusal and the launch-time
`runDirectory` (nemesis:SL-026 PHASE-02 EX-5). DEC-131 records them; SPEC-003
takes them when their code lands here.
