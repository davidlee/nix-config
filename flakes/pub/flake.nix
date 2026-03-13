{
  description = "Public flakes — stable exports for external consumers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = {nixpkgs, flake-utils, jail-nix, llm-agents, ...}:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      lib.jailed-agents = import ./jailed-agents.nix {
        inherit pkgs jail-nix llm-agents;
      };

      packages.helium = pkgs.callPackage ./helium.nix {};
    });
}
