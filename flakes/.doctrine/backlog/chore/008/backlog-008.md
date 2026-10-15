# CHR-008: nix fmt re-locks emacs/emacs-overlay

The committed `flake.lock` is stale against flake.nix's `emacs-overlay` override, so `nix fmt` re-locks it. Settle with a deliberate `nix flake update emacs` commit.

## Resolution (2026-10-15)

`nix flake update emacs` after pushing CHR-002: emacs 666cc6f9 → ee8d509c, no other node changed.
Afterwards `nix flake lock` and `nix fmt` both leave `flake.lock` byte-identical.
