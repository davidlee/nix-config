{
  description = "Example: jailed LLM agents in a Go project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    jailed-agents.url = "github:davidlee/nix-config?dir=flakes/pub";
  };

  outputs = {nixpkgs, flake-utils, jailed-agents, ...}:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      agents = jailed-agents.lib.${system}.jailed-agents;
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs;
          [
            go
            gopls
            golangci-lint
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
            # Jailed agents with project-specific tools injected
            (agents.makeJailedPi {
              extraPkgs = with pkgs; [go gopls golangci-lint];
            })
            (agents.makeJailedOpencode {
              extraPkgs = with pkgs; [go gopls golangci-lint];
            })
          ];
      };
    });
}
