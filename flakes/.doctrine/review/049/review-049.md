# Review RV-049 — reconciliation of SL-024

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

Mode: conformance. Surface: the primary tree at 7ddea803 (solo run, no dispatch candidate).

Lines of attack:

- Does the code match design.md and DEC-123..127: key source, store binds, policy, config order, registration, the three refusals?
- Is each plan criterion met by evidence, not by the phase's `completed` flag? PHASE-04 EX-8's claude half is known open.
- Does the jail policy really copy the host's, as the design says? Compare the files.
- Do design § Failure modes rows hold where PHASE-04 did not run them? Run them in the proof jails.
- Are "inert on the host" and the docs' statements true as worded?
- Does canon (SPEC-003, DEC-122) match what shipped? Is anything else stale?
- Is the source-delta registry complete, since conformance reads it?
- POL-001: nothing secret-bearing tracked.

## Synthesis

**Outcome.** SL-024 delivers its design. `just gate` and `doctrine check gate` pass. No finding is a blocker, and no code defect was found. One comment changed (F-4). The rest is record work for /reconcile.

**What was checked, and how.**

| claim | evidence | source |
|---|---|---|
| code matches design and DEC-123..127 | read `quotient-in-jail.nix`, the `jailed-agents.nix` and `dev-envs` diffs against the design | this audit |
| jail policy copies the host's | `~/.config/quotient/policy.json` less `forms` and `roots` equals the module's `policy`; the six profile files match the map | this audit |
| key delivery fails loud | quotient's `form-family.nix` refuses an empty secret; the test covers env, file, empty and neither | this audit |
| a planted `/workspace/.quotient/forms` link is refused | real `jailed-shell`: `form-unapproved` | this audit |
| `quotient allow` cannot write in a jail | real `jailed-shell`: `EROFS`, rc 1; host `approvals.json` hash unchanged | this audit |
| delegate at `/workspace/flakes` has `git` but no repository, and no quotient | real delegate call: `not a git repository`, `command -v quotient` rc 1 | this audit |
| EX-1..EX-9, VH-1, VH-2 | notes § PHASE-04 proof, raw output in `.doctrine/state/slice/024/proof` | recorded by the implementing seat; not rerun, except as above |
| tests catch regressions | notes' negative controls; I read the oracles but did not rerun the mutations | recorded |

The proof jails were built before PHASE-05, and `git log` shows PHASE-05 is the only later commit touching `agents/` or `dev-envs/`, and it touches docs alone.

**Tradeoffs accepted.**

- PHASE-04/EX-8's claude half is met by the init line and VH-1, on the operator's ruling (2026-11-05). plan.toml keeps its text, because criteria are immutable, so the plan reads wrong on this one point. F-1's disposition is the record.
- conformance stays unreadable until ISS-005 is fixed. F-5 holds the hand reconciliation.
- Delegates at `/workspace/flakes` get no repository (design § The consumer).

**Standing risks.**

- Until the push and the `agents` re-lock (notes § Post-landing steps), a bare `nix build path:dev-envs#…` fails.
- Each project's host delegates are refused after `home-switch` until `bin/dev-envs-forms` and `quotient allow` run again.
- The policy's maxima and profile map are a hand copy of a dotfile. They match today; nothing keeps them matched.
- quotient:IMP-014 and the note on quotient:DEC-071 exist only uncommitted in `~/dev/quotient`. quotient:IDE-008's docs are still owed.
- Host `LLM_GATEWAY_KEY` overrides the key file for forms (F-4). Nothing sets it today.

## Reconciliation Brief

### Per-slice (direct edit)

- design.md § Verification, registration smoke (F-1): replace the `jailed-claude mcp list` claim with the stream-json init check, `quotient` `connected`, source `dynamic`; say `mcp list` reads stored config only.
- design.md § Forms (F-4): "both are inert on the host" becomes: the binds add nothing on the host, and the key file serves unless the server's environment holds `LLM_GATEWAY_KEY`.
- design.md § The declaration (F-6.1): the file's return set adds `etcStoreBinds`.
- design.md § Verification (F-6.2): replace "starts from a fresh persisted home" with the shipped jail's own home, as plan.md § Notes has it.
- design.md § Verification (F-6.3): "26 PASS" becomes 26 top-level rows, 73 in all.
- design.md § Failure modes (F-6.4): the `quotient allow` row: a bare call only reports; approving fails `EROFS`.
- design.md § Code impact (F-6.5, F-2): the SPEC-003 row names § The jail set, § Forms, § Concerns and § Decisions.

### Governance/spec (REV)

- SPEC-003 (F-2): approve and apply REV-016 as authored → REV modify. It needs the operator's approval.

## Reconciliation Outcome

### Direct edits applied

All on the operator's confirmation, 2026-11-05.

- design.md § Verification: registration smoke names the init-line check (F-1).
- design.md § Forms: "inert on the host" narrowed to the `LLM_GATEWAY_KEY` case (F-4).
- design.md § The declaration: return set adds `etcStoreBinds` (F-6.1).
- design.md § Verification: the shipped jail's own home (F-6.2); 26 top-level PASS rows, 73 in all (F-6.3).
- design.md § Failure modes: the `quotient allow` row (F-6.4).
- design.md § Code impact: REV-016's full scope (F-6.5, F-2).

### REVs completed

- REV-016: done, approved by the operator. SPEC-003 § The jail set, § Forms, § Concerns and § Decisions landed as authored (F-2). Rationale in revision-016.md.

### Withdrawn / tolerated

- F-5: tolerated. ISS-005 owns the cause; the hand match is in the finding.
- F-3, F-7: no write owed here. F-3 was fixed at audit; F-7 is aligned.
- F-1: plan.toml's EX-8 text stands, as criteria are immutable. The operator's ruling is on the finding.

Reconcile pass complete; handoff to /close.
