# CHR-008: nix fmt re-locks emacs/emacs-overlay

The committed `flake.lock` is stale against flake.nix's `emacs-overlay` override, so `nix fmt` re-locks it. Settle with a deliberate `nix flake update emacs` commit.
