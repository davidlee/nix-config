`nix fmt` (treefmt: alejandra + statix) re-locks `emacs/emacs-overlay`
because the committed lock is stale against flake.nix's emacs-overlay
override. Don't commit that drift in an unrelated slice: restore with
`git show HEAD:flakes/flake.lock > flake.lock` (from ~/flakes), or pass
`--no-write-lock-file`. Settled permanently by CHR-008 (a deliberate
`nix flake update emacs`).

Also: `just -n` doesn't run backticks (prints `` `hostname` `` literally);
use `just --evaluate host`.
