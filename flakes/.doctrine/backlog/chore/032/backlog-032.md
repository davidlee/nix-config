# CHR-032: Give the rooms that track .doctrine a Doctrine, where the runner works in them

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Eight fleet targets track `.doctrine/` with no Doctrine in the room: deck_of_dwarf,
oubliette, quotient, resume, satan-attrd, screwtape, smut, www. malebolge's runner
calls `doctrine prompt resolve` in such a clone, fails, and reports
`context_degraded`; the job goes on without the boot. Audit: CHR-031.

1. Find which repos the runner is configured to take jobs in. That was not checked.
2. For each, add `capsule-tools` and switch the target (DEC-128, DEC-112's order).
   Have fleet follow its `doctrine`, as CHR-031 did.

deck_of_dwarf and quotient have no `dev-tools`; their targets use `extraTools`.
screwtape has `dev-tools` at HEAD, but fleet's lock predates it (db60994), so its
target's `null` and "no packages.dev-tools output" hold only until the next re-lock.

Related: CHR-031, DEC-128.
