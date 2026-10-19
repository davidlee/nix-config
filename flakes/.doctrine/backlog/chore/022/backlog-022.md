# CHR-022: Commit ~/notes and ~/satan-corpus on a timer with just commit

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

## Why

Oubliette room `assistant` sees a repo as its host checkout's last commit
(`capsule push` sends `refs/heads/<branch>`), refreshed only when a patch job
runs on that repo. `~/notes` and `~/satan-corpus` are committed by hand
(`just commit`) when remembered, often once a day. `~/satan-corpus` matters
most: it is the base of SATAN's `self-edit-mind` patch jobs. Context:
satan RFC-019 D5.

## Shape

- A home-manager user timer (hourly to start), one service per repo, running
  `just commit` in the repo. Optional later: a debounced path watch.
- Owned here, not by `satan-runner`. The runner may get one generic
  pre-refresh command in its config (satan RFC-019 D5); that knows nothing of
  these repos.

## Edges to handle

- Both recipes are `git reset; git add .; git ci -m <date>`. `git ci` exits
  non-zero on a clean tree: the unit must skip, not fail, when nothing changed
  (`git status --porcelain` empty).
- `git reset` unstages whatever the user has staged. A timer firing during a
  hand-made partial commit would undo it. Skip when the index differs from
  HEAD (`git diff --cached --quiet` fails), or change the recipes.
- `git ci` is an alias from the user's git config; the unit needs `$HOME` and
  git on PATH. Concurrent user git ops can leave `index.lock`: treat that as
  skip-and-retry next tick.
- Push stays manual: the room needs local commits, not GitHub.

## Outcome (2026-10-19)

The `notes.autocommit` feature (`features/notes.nix`), Linux only, is
selected by `personal-linux`, so it is live on Sleipnir at the next
`home-switch`. Two changes from the shape above, at the user's direction:

- It does not call `just commit`. A standalone script,
  `features/notes/autocommit` (`~/.local/bin/autocommit REPO`), runs
  `git add --all; git commit -m <date>` itself, so it needs no `git reset`,
  no `just` and no `git ci` alias.
- No hook runs (`-c core.hooksPath=/dev/null`): a machine commit is not
  activity for SATAN's global post-commit sensor.

Each repo has one oneshot service and an hourly timer
(`autocommit-notes`, `autocommit-satan-corpus`). A unit whose repo has no
`.git` does not start (`ConditionPathExists`). The script skips with exit 0
when `index.lock` is held, when the index differs from HEAD, or when the
tree is clean. A lock taken between the check and the commit fails that
run, and the next tick retries. `features/notes/autocommit-test` (in
`just test`) covers each branch. The debounced path watch is not built.
