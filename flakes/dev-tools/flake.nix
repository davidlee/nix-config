{
  description = "nix-config's tool set, for the oubliette room's toolsPackage";

  # A subflake, not an output of ../flake.nix: the fleet that builds the room is
  # an input of that flake, so taking it back as the fleet's input would be a
  # cycle. What `just fmt`/`just gate` run, minus `nix` (the guest has its own).
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    doctrine.url = "github:davidlee/doctrine";
  };

  outputs = {
    nixpkgs,
    treefmt-nix,
    doctrine,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    tools = pkgs:
      with pkgs; [
        just
        jq
        nushell # features/attention/nudge/nudge-test.nu
        alejandra
        statix
        deadnix
        (treefmt-nix.lib.mkWrapper pkgs {
          projectRootFile = "flake.nix";
          programs = import ./treefmt.nix;
        })
      ];
  in {
    packages = forAll (pkgs: {
      dev-tools = pkgs.buildEnv {
        name = "nix-config-dev-tools";
        paths = tools pkgs;
        # The dev-envs consumer's contract (SPEC-003): `~/.cfg` holds this repo.
        passthru.devEnv.outerGitDir = ".cfg";
      };
      # What the room takes: `dev-tools` plus Doctrine, as a room has no host install
      # (flakes:DEC-130).
      capsule-tools = pkgs.buildEnv {
        name = "nix-config-capsule-tools";
        paths = tools pkgs ++ [doctrine.packages.${pkgs.stdenv.hostPlatform.system}.default];
        ignoreCollisions = true;
      };
    });
  };
}
