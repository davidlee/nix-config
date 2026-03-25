{
  description = "Public flakes — stable exports for external consumers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    jail-nix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      lib.mkJailedAgents = {llm-agents}:
        import ./jailed-agents.nix {
          inherit pkgs jail-nix llm-agents;
        };

      packages.helium = pkgs.callPackage ./helium.nix {};
    });
}
