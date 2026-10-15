@.doctrine/state/boot.md
If you have NOT seen `BOOT-SENTINEL: doctrine-governance-snapshot` anywhere in your context (system prompt or preceding messages), you MUST read the file referenced above now. If you HAVE seen it, you MUST NOT — the content is already in context.

no code without an approved plan (in the abstract sense; plan mode is optional)

docs:

@README.md
Justfile - user entrypoint (aliased as j)
~/.config/emacs/ - user emacs config

repo: ~/.git (sparse repo)

**Heads-up: the git worktree is `$HOME`, not `~/flakes`.** `~/.git` points at
`~/.cfg` (`core.worktree = $HOME`, `showUntrackedFiles = no`).
- Any repo-wide git op acts on all of `~`. Scope every command to a path; never
  stash, checkout, clean or reset --hard.
- Untracked files don't show in `git status`; use `-uall -- <path>`. Add new
  files (and doctrine slug symlinks) explicitly; flakes see only tracked files.
- git paths carry a `flakes/` prefix, so doctrine selector / conformance /
  verify-vt attribution misfires (ISS-005). Judge by agent.
- Detail: `doctrine memory show mem.system.flakes.home-worktree`.
git add ~/flakes/ is typically correct, with conventional commits.

