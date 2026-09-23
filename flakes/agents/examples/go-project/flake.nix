{
  description = "Example: jailed LLM agents in a Go project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    agents.url = "github:davidlee/nix-config?dir=flakes/agents";
  };

  outputs = inputs @ {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      agents = inputs.agents.lib.${system}.mkJailedAgents {};
      goPkgs = with pkgs; [go gopls golangci-lint];
    in {
      devShells.default = pkgs.mkShell {
        packages =
          goPkgs
          ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
            # Jailed agents with project-specific tools injected
            (agents.makeJailedClaude {extraPkgs = goPkgs;})
            (agents.makeJailedCodex {extraPkgs = goPkgs;})
            (agents.makeJailedGemini {extraPkgs = goPkgs;})
            (agents.makeJailedPi {extraPkgs = goPkgs;})
          ];
      };
    });
}
