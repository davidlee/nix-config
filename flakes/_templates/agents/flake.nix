# Template: jailed LLM agents
#
# Copy into project, then:
#   1. Adjust projectPkgs for the language/toolchain
#   2. Set workspaceDeps to sibling repos the agents need to see
#   3. Tune jailEnvOptions: forward host env vars into the jail
#   4. Trim jailPkgs to the agents actually wanted
#
# Online profiles (specDev, research) auto-wrap with `op run` to inject
# API keys from 1Password. Override the ref map at mkJailedAgents time
# if your vault layout differs (see pub/README.md).
#
# If the caller already holds resolved plaintext (e.g. a long-lived
# broker with a session credential cache), set:
#   useOpEnv = false; passApiKeysFromEnv = true;
# to skip the outer `op run` wrapper while keeping the bwrap
# `--setenv VAR "$VAR"` forwarding. See pub/README.md > "Pre-resolved
# secrets" for the full rationale.
#
# Usage:
#   nix develop
#   jailed-claude   # or jailed-pi, jailed-codex, jailed-gemini, ...
#   jcl             # shorthand: jailed-claude --dangerously-skip-permissions
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

        # jail.nix is Linux-only (bubblewrap). Darwin gets a plain devshell.
        jailLib =
          if isLinux
          then inputs.pub.lib.${system}.mkJailedAgents {inherit (inputs) llm-agents;}
          else {};

        # -- Customise these for the project --

        projectPkgs = with pkgs; [
          # Toolchain + dev deps available inside every jail.
          # e.g. go, gopls, rust-bin.stable.latest.default, uv, python3, nodejs_latest
          uv
          python3
          codex # for mcp server slave
        ];

        # Sibling repos to bind-mount (for editable deps / source inspection).
        # Each path appears at /workspace/<basename> inside the jail; a host
        # symlink like ./some-lib -> ../some-lib resolves correctly.
        workspaceDeps = [
          # "/home/david/dev/some-lib"
        ];

        # bwrap starts with a clean env. Forward / set what agents need.
        # Combinators: set-env, fwd-env (error if unset), try-fwd-env (skip if unset),
        # try-readwrite (bind a host path rw if it exists).
        jailEnvOptions = lib.optionals isLinux (with jailLib.combinators; [
          (try-fwd-env "OPENROUTER_API_KEY")
          # (try-fwd-env "DATABASE_URL")
          # (try-fwd-env "DOCKER_HOST")
          # (try-readwrite "/run/user/1000/docker.sock")
          # (set-env "CGO_ENABLED" "0")
        ]);

        # -- Agents --
        #
        # Profiles:
        #   specDev   — shared persistent home, network on, git push blocked, sandboxed identity
        #   research  — separate persistent home, network on, host git identity
        #   offline   — separate persistent home, no network, no op env injection
        #
        # Extra per-agent knobs (all optional):
        #   exposePostgres       = true;   # bind /run/postgresql into the jail
        #   allowSelfAsSubagent  = true;   # let agent recursively spawn itself
        #   maxSubagentDepth     = 2;      # cap recursion depth (default 1)
        #   useOpEnv             = false;  # opt out of 1Password injection
        #   passApiKeysFromEnv   = true;   # forward pre-resolved API keys from
        #                                  # the caller's env (use with
        #                                  # useOpEnv = false when a broker
        #                                  # already caches plaintext)
        jailPkgs = lib.optionalAttrs isLinux {
          jailed-pi = jailLib.makeJailedPi {
            profile = "specDev";
            allowSelfAsSubagent = true;
            maxSubagentDepth = 2;
            extraPkgs = projectPkgs;
            extraOptions = jailEnvOptions;
            inherit workspaceDeps;
          };
          jailed-pi-research = jailLib.makeJailedPi {
            name = "pi-research";
            profile = "research";
            extraPkgs = projectPkgs;
            extraOptions = jailEnvOptions;
            inherit workspaceDeps;
          };
          jailed-opencode = jailLib.makeJailedOpencode {
            profile = "specDev";
            extraPkgs = projectPkgs;
            extraOptions = jailEnvOptions;
            inherit workspaceDeps;
          };
          jailed-claude = jailLib.makeJailedClaude {
            profile = "specDev";
            extraPkgs = projectPkgs;
            extraOptions = jailEnvOptions;
            inherit workspaceDeps;
          };
          jailed-codex = jailLib.makeJailedCodex {
            profile = "specDev";
            extraPkgs = projectPkgs;
            extraOptions = jailEnvOptions;
            inherit workspaceDeps;
          };
          jailed-gemini = jailLib.makeJailedGemini {
            profile = "specDev";
            extraPkgs = projectPkgs;
            extraOptions = jailEnvOptions;
            inherit workspaceDeps;
          };
          # jailed-zero = jailLib.makeJailedZerostack {
          #   profile = "specDev";
          #   extraPkgs = projectPkgs;
          #   extraOptions = jailEnvOptions;
          #   inherit workspaceDeps;
          # };
          inherit (pkgs) bubblewrap;
        };
      in {
        packages = jailPkgs;

        devshells.default = {
          packages =
            projectPkgs
            ++ lib.optionals isLinux (lib.attrValues jailPkgs);

          commands = [
            {
              name = "jcl";
              help = "jailed-claude --dangerously-skip-permissions";
              command = "jailed-claude --dangerously-skip-permissions $@";
            }
          ];
        };
      };
    };
}
