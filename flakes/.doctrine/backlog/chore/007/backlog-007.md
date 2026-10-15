# CHR-007: zed-editor.nix has an if-false toggle

`modules/home/linux/zed-editor.nix` chooses between the zed flake input and `pkgs.zed-editor` with `if false`. Remove the dead branch or make it a deliberate choice.

## Resolution (2026-10-15)

Kept `pkgs.zed-editor` (the live branch); dropped the dead `if false` branch and the `zed` flake
input, its only consumer (lock pruned: zed, crane, rust-overlay, …). Every `just drvs` path is
unchanged — a pure removal. `just gate` green.
