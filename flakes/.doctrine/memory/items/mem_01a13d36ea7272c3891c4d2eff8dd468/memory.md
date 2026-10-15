`~/flakes` is a git flake, so untracked files don't exist to Nix ("path does
not exist"). Run `git add -N <file>` (intent-to-add) before any eval: it makes
the file visible without staging its content. The `~` worktree hides untracked
files (`status.showUntrackedFiles = no`) and is dirty outside flakes/: commit
explicit paths only, never `git add -A` / `commit -a`.
