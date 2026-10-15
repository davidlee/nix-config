# CHR-007: zed-editor.nix has an if-false toggle

`modules/home/linux/zed-editor.nix` chooses between the zed flake input and `pkgs.zed-editor` with `if false`. Remove the dead branch or make it a deliberate choice.
