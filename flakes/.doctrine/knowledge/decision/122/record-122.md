Answers IMP-066's seven questions. Survey and origin of the relay: IMP-066 § Survey for question 1.

| question | answer |
|---|---|
| 1. Need | In a jail, only a root per call for other repos. Ceilings and protected evidence do not justify it alone. |
| 2. Default | Off. |
| 3. Home of the opt-in | A new jail declaration, global or in a project. |
| 4. Cross-repo roots | Yes, in that jail only: a declared subset of its workspace deps, each `ro` or `rw`. |
| 5. In-jail quotient | The intended route for single-repo jailed claude, after quotient:IDE-008. |
| 6. `quotient <args>` | Refused. |
| 7. Contract | This DEC; SPEC-003 for the jail set; `agents/README.md` for mechanics until CHR-020's spec exists. |

ISS-026's fix is neither its option A nor B: the shim refuses arguments, and the default change removes the shim from jails, which is what lets the test pass with its guard unchanged. Its option C failed only because the shim stayed on PATH.


## Note: in-jail quotient shipped (SL-024, 2026-11-05)

SL-024 put the real quotient in `jailed-claude`, `jailed-codex` and `jailed-shell` (DEC-123). The decision stands; three parts of it now read differently. Evidence: SL-024's notes, § PHASE-04 proof.

- **Roots.** In-jail quotient's root is `/workspace`, so its reach is limited by the jail's mounts. Point 4's declared list concerns the relay and IDE-010, and is unaffected.
- **Point 6 is delivered,** through DEC-123 and quotient:DEC-071, for jailed claude and for jailed codex.
- **Point 7 and the consequences.** "No reduce or help in a jail" and the `.mcp.json` consequence hold only for jails without `quotientServer`, as does the raw `pi_report` tail with its skipped test section. In a jail with it, `quotient` is the real binary and `pi-report-test.sh` section 1 runs and passes. The shim's refusal of arguments is unchanged, and no jail in dev-envs carries the shim.
