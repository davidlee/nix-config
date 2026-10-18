# Template: jailed LLM agents
#
# Copy into project, then:
#   1. Adjust projectPkgs for the language/toolchain
#   2. Set workspaceDeps to sibling repos the agents need to see
#   3. Tune jailEnvOptions: forward host env vars into the jail
#   4. Trim jailPkgs to the agents actually wanted
#   5. Jails use the LLM gateway; see `gateway` below to opt out
#
# Jails reach models through the local LLM gateway (`gateway` below).
#
# Usage:
#   mv _envrc .envrc && direnv allow   # live agents: agent bumps need no lock update
#   nix develop
#   jailed-claude   # or jailed-pi, jailed-pi-research, jailed-codex
#   jcl             # shorthand: jailed-claude --dangerously-skip-permissions
{
  description = "Dev shell with jailed LLM agents";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
    agents.url = "github:davidlee/nix-config?dir=flakes/agents";
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
          then inputs.agents.lib.${system}.mkJailedAgents {}
          else {};

        # Unjailed agent CLIs (llm-agents builds) under short names. Linux
        # only; on Darwin fall back to nixpkgs. To get them on `pkgs`
        # directly instead, apply the overlay at the top of perSystem:
        #   _module.args.pkgs = import inputs.nixpkgs {
        #     inherit system; config.allowUnfree = true;
        #     overlays = [ (inputs.agents.lib.${system}.agentsOverlay {}) ];
        #   };
        agents = lib.optionalAttrs isLinux jailLib.agentsByName;

        # -- Customise these for the project --

        projectPkgs = with pkgs; [
          # Toolchain + dev deps available inside every jail.
          # e.g. go, gopls, rust-bin.stable.latest.default, uv, python3, nodejs_latest
          uv
          python3
          (agents.codex or codex) # mcp server slave — llm-agents build on linux
        ];

        # Sibling repos to bind-mount (for editable deps / source inspection).
        # Each path appears at /workspace/<basename> inside the jail; a host
        # symlink like ./some-lib -> ../some-lib resolves correctly.
        workspaceDeps = [
          # "/home/you/dev/some-lib"
        ];

        # bwrap starts with a clean env. Forward / set what agents need.
        # Combinators: set-env, fwd-env (error if unset), try-fwd-env (skip if unset),
        # try-readwrite (bind a host path rw if it exists).
        jailEnvOptions = lib.optionals isLinux (with jailLib.combinators; [
          # pulse # opt-in host audio; uses $XDG_RUNTIME_DIR
          # (try-readonly "/path/on-this-host/notification.wav")
          # (try-fwd-env "DATABASE_URL")
          # (try-fwd-env "DOCKER_HOST")
          # (try-readwrite "/path/to/docker.sock")
          # (set-env "CGO_ENABLED" "0")
        ]);

        # Every jail reaches models through the local LLM gateway with the shared
        # `pi` key (~/.config/llm-gateway/keys/pi); no provider key enters a jail.
        # On a host without the gateway, set `gateway = null` on a jail to fall back
        # to `op run` with provider keys (see agents/README.md § Gateway mode).
        gateway = jailLib.gatewayClient "pi";

        # -- Agents --
        #
        # Profiles:
        #   specDev   — shared persistent home, network on, SSH push blocked, sandboxed identity
        #   research  — separate persistent home, network on, SSH push blocked, host identity
        #   offline   — separate persistent home, no network, no op env injection
        #
        # Extra per-agent knobs (all optional):
        #   exposePostgres       = true;   # bind /run/postgresql into the jail
        #   blockSshGitPush      = false;  # SSH only; HTTPS remains available
        #   allowSelfAsSubagent  = true;   # let agent recursively spawn itself
        #   maxSubagentDepth     = 2;      # cap recursion depth (default 1)
        #   gateway              = null;   # off the gateway: name the provider keys
        #                                  # in apiKeys (none by default), resolved
        #                                  # from 1Password (agents/README.md)
        jailPkgs = lib.optionalAttrs isLinux {
          jailed-pi = jailLib.makeJailedPi {
            profile = "specDev";
            allowSelfAsSubagent = true;
            maxSubagentDepth = 2;
            extraPkgs = projectPkgs;
            extraOptions = jailEnvOptions;
            inherit gateway workspaceDeps;
          };
          jailed-pi-research = jailLib.makeJailedPi {
            name = "pi-research";
            profile = "research";
            extraPkgs = projectPkgs;
            extraOptions = jailEnvOptions;
            inherit gateway workspaceDeps;
          };
          jailed-claude = jailLib.makeJailedClaude {
            profile = "specDev";
            extraPkgs = projectPkgs;
            extraOptions = jailEnvOptions;
            inherit gateway workspaceDeps;
          };
          jailed-codex = jailLib.makeJailedCodex {
            profile = "specDev";
            extraPkgs = projectPkgs;
            extraOptions = jailEnvOptions;
            inherit gateway workspaceDeps;
          };
          # jailed-zero = jailLib.makeJailedZerostack {
          #   profile = "specDev";
          #   extraPkgs = projectPkgs;
          #   extraOptions = jailEnvOptions;
          #   inherit workspaceDeps;
          # };
          # jailed-dirge = jailLib.makeJailedDirge {
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
