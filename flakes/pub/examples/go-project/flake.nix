{
  description = "Example: jailed LLM agents in a Go project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pub.url = "github:davidlee/nix-config?dir=flakes/pub";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = {nixpkgs, flake-utils, pub, llm-agents, ...}:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      agents = pub.lib.${system}.mkJailedAgents {inherit llm-agents;};
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
