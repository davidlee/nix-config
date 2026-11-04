git checks the owner of a gitfile as well as of the worktree and git dir. A Nix
store file is owned by root, which is `nobody` in a jail's user namespace, so
binding one at `<worktree>/.git` gives `fatal: detected dubious ownership`.
A store file as `.cfg/config` is fine: only the gitfile is checked.

- Do: `exec {fd}<<<'gitdir: .cfg'`, then `--ro-bind-data "$fd" <worktree>/.git`.
  bwrap writes the file itself: user-owned, read-only. See `agents/outer-git.nix`.
- Alternative: `safe.directory` through `GIT_CONFIG_COUNT`/`KEY_0`/`VALUE_0`
  (command scope counts as protected config). Works, but adds env to every git.
- Probing a jail layout: use a real store file. A user-owned fixture hides this.

Observed with git 2.56 (IMP-057).
