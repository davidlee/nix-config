# CHR-006: nix-search-tv installed twice

`modules/nixos/nix.nix` installs both the flake input's package and `pkgs.nix-search-tv`. Pick one.

## Resolution (2026-10-15)

It was installed three times: `modules/nixos/nix.nix` (flake input + `pkgs.nix-search-tv`) and
`modules/shared/cli/_packages/find.nix` (home, every host). Kept the shared home entry (nixpkgs
2.2.9); dropped both system copies and the `nix-search-tv` flake input (lock pruned). `just drvs`
and `just gate` green.
