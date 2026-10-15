# CHR-002: emacs sub-flake lacks aarch64-linux

MULTIHOST follow-up, before nixosvm (S8). `emacs/flake.nix` `systems` lacks `aarch64-linux`; `home/shared/emacs.nix` and `eca.nix` read `inputs.emacs.packages.${system}`, so a VM home won't evaluate. Add it (+ push/relock, or rely on home_override).

## Resolution (2026-10-15)

Added `aarch64-linux` to `systems` in `emacs/flake.nix`; `packages.aarch64-linux.default` evaluates
(`emacs-unstable-pgtk-with-packages-31.1.drv`). Local only: home builds pick it up via
`home_override`. Root `flake.lock` still pins the GitHub `emacs` input — a non-overridden eval
needs a push + `nix flake update emacs`.
