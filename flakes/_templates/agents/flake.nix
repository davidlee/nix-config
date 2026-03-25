# Template: jailed LLM agents
#
# Copy this into your project, then:
#   1. Adjust projectPkgs for your language/toolchain
#   2. Set workspaceDeps to any sibling repos agents need access to
#   3. Pick which agents to enable in jailPkgs
#
# Usage:
#   nix develop
#   jailed-claude   # or jailed-pi, jailed-codex, etc.
{
  description = "Dev shell with jailed LLM agents";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
    pub.url = "github:davidlee/nix-config?dir=/flakes/pub";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devshell.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        inherit (pkgs) lib stdenv;
        inherit (stdenv) isLinux;

        jailLib =
          if isLinux
          then inputs.pub.lib.${system}.mkJailedAgents {inherit (inputs) llm-agents;}
          else {};

        # -- Customise these for your project --

        projectPkgs = with pkgs; [
          uv
          python3
        ];

        # Sibling repos to bind-mount (for editable deps / source inspection).
        # Each path appears at /workspace/<basename> inside the jail.
        workspaceDeps = [
          # "/home/david/dev/some-lib"
        ];

        # -- Agents --

        jailPkgs = lib.optionalAttrs isLinux {
          jailed-pi = jailLib.makeJailedPi {
            profile = "specDev";
            extraPkgs = projectPkgs;
            inherit workspaceDeps;
          };
          jailed-claude = jailLib.makeJailedClaude {
            profile = "specDev";
            extraPkgs = projectPkgs;
            inherit workspaceDeps;
          };
          jailed-codex = jailLib.makeJailedCodex {
            profile = "specDev";
            extraPkgs = projectPkgs;
            inherit workspaceDeps;
          };
          jailed-gemini = jailLib.makeJailedGemini {
            profile = "specDev";
            extraPkgs = projectPkgs;
            inherit workspaceDeps;
          };
        };
      in {
        packages = jailPkgs;

        devshells.default = {
          packages =
            (with pkgs; [
              # your dev tools here
            ])
            ++ lib.optionals isLinux (lib.attrValues jailPkgs);
        };
      };
    };
}
