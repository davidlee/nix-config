`~/flakes` is a git flake, so untracked files don't exist to Nix ("path does
not exist"). Run `git add -N <file>` (intent-to-add) before any eval: it makes
the file visible without staging its content. Committing in the `~` worktree:
[[mem_01a13eae028b76f19bf987845bb45fc5]].
