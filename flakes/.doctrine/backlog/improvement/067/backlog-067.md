# IMP-067: Wire zmux into the flake: overlay in every evaluation, zp in the terminal feature

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Handoff from zmux (`tk-flakes-wire`, plan-v0-1); agreed sketch, no slice.

## Done

- Input `zmux`, `github:davidlee/zmux/v0.1.0`, nixpkgs follows `nixpkgs-home`.
  The repo went public, so the handoff's `git+ssh` and its root-fetch risk no
  longer apply.
- Overlay in `homeModule` and `platformModule`, so every home and system
  evaluation has it. It merges with `nixpkgs.overlays` in
  `hosts/Sleipnir/config.nix`.
- Factory check: `pkgs ? zmx-unwrapped` on every NixOS, darwin and home
  configuration, and the home base. Seen red before the overlay.
- `zp` in `terminal.utils`, without `ZP_ROOT` (zmux `d-picker-jobs`).
- Not in `bin/dev-checkouts`: `just isolation` stubs those inputs, and every
  home takes this overlay.

## Evidence

`just gate` and `just coverage` pass, isolation included. `pkgs.zmx` and
`pkgs.zp` build on x86_64-linux.

## Open

- Activation: `just system-switch`, `just home-switch` (operator).
- `zp` has not been built on aarch64-darwin. It evaluates in Draupnir's home.
- Follow-up in zmux: `tk-active-projects`.
