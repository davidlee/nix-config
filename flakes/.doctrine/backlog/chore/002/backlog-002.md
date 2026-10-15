# CHR-002: emacs sub-flake lacks aarch64-linux

MULTIHOST follow-up, before nixosvm (S8). `emacs/flake.nix` `systems` lacks `aarch64-linux`; `home/shared/emacs.nix` and `eca.nix` read `inputs.emacs.packages.${system}`, so a VM home won't evaluate. Add it (+ push/relock, or rely on home_override).
