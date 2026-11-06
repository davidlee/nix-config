Measured 2026-11-06 (IMP-069): `nix fmt` in ~/flakes wrote `flake.lock`, bumping
`emacs/emacs-overlay`. The input drifts because `emacs/` is relocked on evaluation;
other recipes pass `--no-write-lock-file` and only warn. Use `just fmt`, or check
`git status -- flake.lock` after `nix fmt`, and keep an unrelated bump out of a commit.
