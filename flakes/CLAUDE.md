@.doctrine/state/boot.md
If you have NOT seen `BOOT-SENTINEL: doctrine-governance-snapshot` anywhere in your context (system prompt or preceding messages), you MUST read the file referenced above now. If you HAVE seen it, you MUST NOT — the content is already in context. If that file does not exist, doctrine is not set up in this checkout: tell the user to install doctrine and run `doctrine install`.

no code without an approved plan (in the abstract sense; plan mode is optional)

Doctrine ids from another repo are always written `<repo>:ID` (e.g. `doctrine:IDE-005`); a bare id means this repo's.

docs:

@README.md
Justfile - user entrypoint (aliased as j)
~/.config/emacs/ - user emacs config

repo: ~/.git (sparse repo)
git add ~/flakes/ is typically correct, with conventional commits.

**Heads-up: the git worktree is `$HOME`, not `~/flakes`.** `~/.git` points at
`~/.cfg` (`core.worktree = $HOME`, `showUntrackedFiles = no`).
- Any repo-wide git op acts on all of `~`. Scope every command to a path; never
  stash, checkout, clean or reset --hard. Staging: `git add .` (in ~/flakes)
  and `git add -u` (tracked only) are safe; bare `git add -A` stages every
  untracked file in `~` (~170k) — use `git add -A .`.
- Untracked files don't show in `git status`; use `-uall -- <path>`. Add new
  files (and doctrine slug symlinks) explicitly; flakes see only tracked files.
- git paths carry a `flakes/` prefix, so doctrine selector / conformance /
  verify-vt attribution misfires (ISS-005). Judge by agent.
- Detail: `doctrine memory show mem.system.flakes.home-worktree`.

