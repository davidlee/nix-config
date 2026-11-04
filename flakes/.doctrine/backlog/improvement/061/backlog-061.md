# IMP-061: Keep .quotient form links out of project git

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

From RV-047 F-6 (SL-023 audit). `bin/dev-envs-forms` writes machine-local store
symlinks under `.quotient/`. Doctrine shows it untracked and unignored; Smut
tracks all four links, so each form rebuild dirties the repo.

Likely fix: the linker adds `.quotient/` to the checkout's `.git/info/exclude`
(no project file changes, in keeping with "the project knows nothing about
agents"), with a case in `bin/dev-envs-forms-test`. Smut's tracked links need
`git rm --cached`, which is the operator's call. Check first that quotient does
not need them tracked.
