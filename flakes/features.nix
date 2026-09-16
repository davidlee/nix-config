# Resolves this host's feature flags to a plain attrset.
#
# Options are declared in modules/features.nix and evaluated here, once, by
# lib.evalModules — outside the NixOS, darwin and home-manager module systems.
# Those three evaluate independently (separate nixpkgs, separate `switch`), so
# an option declared in one is invisible to the others; flake.nix threads this
# result through `specialArgs` / `extraSpecialArgs` instead.
#
# Being a specialArg rather than an option is what lets `features` gate
# `imports` — imports are resolved before `config` exists, so a real option
# could not.
#
# A host overrides what it likes in hosts/<hostname>/features.nix; a missing
# file means it takes the defaults unchanged.
lib: hostname: let
  host = ./hosts/${hostname}/features.nix;
in
  (lib.evalModules {
    modules =
      [./modules/features.nix]
      ++ lib.optional (builtins.pathExists host) host;
  })
  .config
