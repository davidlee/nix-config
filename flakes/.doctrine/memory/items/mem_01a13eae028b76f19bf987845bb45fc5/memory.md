`~/.git` is a one-line pointer (`gitdir: /home/david/.cfg`); `~/.cfg/config`
sets `core.worktree = /home/david` and `status.showUntrackedFiles = no`. The
git root is `~`, not `~/flakes`.

Consequences:
- **Repo-wide git ops act on all of `~`.** Never `git stash`, `checkout`,
  `clean`, `reset --hard`, or anything over "every file in the repo". Scope
  every command to a path (`git add ~/flakes/...`, `git diff -- flakes/`).
- **Staging, verified by dry-run (git 2.55, from ~/flakes):** `git add .` is
  scoped to the cwd (tracked + untracked under it) — safe. `git add -u` spans
  the whole worktree but only tracked files — safe. Bare `git add -A` spans
  the whole worktree *including untracked* — it would stage ~172k files
  (games, docker volumes, …). Use `git add -A .` instead.
- **Untracked files are invisible.** `git status` hides them; use
  `git status --short -uall -- <path>`. New files (including doctrine slug
  symlinks, which *are* tracked by convention) must be added explicitly.
  Flakes see only tracked files: [[mem_01a13d36ea7272c3891c4d2eff8dd468]].
- **Paths are prefixed `flakes/`** in git output. Doctrine selectors and
  `slice conformance` / `verify-vt` compare them against `~/flakes`-relative
  selectors and mis-attribute (ISS-005): [[mem_01a13da6b89772768dfd55c3c5fc352d]].
  Judge conformance by agent, stripping the prefix.
- `doctrine` warns "worktree /home/david/.cfg/flakes/ not scanned"; harmless.
