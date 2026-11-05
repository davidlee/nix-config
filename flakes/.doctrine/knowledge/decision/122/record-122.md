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
