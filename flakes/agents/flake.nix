{
  description = "Public flakes — stable exports for external consumers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
    # The one agent pin for every consumer. Deliberately NOT following
    # nixpkgs, so the numtide binary cache (cache.numtide.com) applies.
    llm-agents.url = "github:numtide/llm-agents.nix";
    # The zmx wrapper every jail carries. A package, not an overlay: dev-envs
    # hands mkJailedAgents its own pkgs, which an overlay here would not reach.
    # Tracks main: the lock is the pin, and the host follows it.
    zmux = {
      url = "github:davidlee/zmux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    jail-nix,
    llm-agents,
    zmux,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # `llm-agents` defaults to this flake's own pin; pass one only to diverge.
      mkJailedAgents = args:
        import ./jailed-agents.nix ({
            inherit pkgs jail-nix llm-agents;
            inherit (zmux.packages.${system}) zmx;
          }
          // args);

      # Ready-made nixpkgs overlay injecting the unjailed agent CLIs under
      # their short names (codex, claude, gemini, ...). Consumers apply it
      # to their own nixpkgs so `pkgs.codex` is the llm-agents build:
      #   overlays = [ (agents.lib.${system}.agentsOverlay {}) ];
      # `agents` narrows which names to inject; other args (e.g. a diverging
      # `llm-agents`) pass through to mkJailedAgents.
      agentsOverlay = args @ {
        agents ? null, # null => every agentsByName entry
        ...
      }: _final: _prev: let
        byName = (mkJailedAgents (builtins.removeAttrs args ["agents"])).agentsByName;
        names =
          if agents == null
          then builtins.attrNames byName
          else agents;
      in
        pkgs.lib.genAttrs names (n: byName.${n});
    in {
      lib = {inherit mkJailedAgents agentsOverlay;};

      checks = pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        jailed-agents = import ./jailed-agents-test.nix {
          inherit pkgs jail-nix;
        };
        quotient-relay = import ./quotient-relay-test.nix {
          inherit pkgs jail-nix;
        };
        # pi-zmx loads in every jail, and only conforms through the wrapper.
        jail-zmx-is-wrapper = let
          base = pkgs.buildEnv {
            name = "jail-common-pkgs";
            paths = (mkJailedAgents {}).commonPkgs;
          };
        in
          pkgs.runCommand "jail-zmx-is-wrapper" {} ''
            grep -Fq 'zmx with opinions' ${base}/bin/zmx
            touch "$out"
          '';
      };

      # Not under `checks`: `nix flake check` evaluates purely, where this
      # test refuses to run. `just test` builds it with --impure.
      impureChecks = pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        jailed-agents-env = import ./jailed-agents-env-test.nix {
          inherit pkgs jail-nix;
        };
      };

      # Real jails for script tests to launch: bwrap needs user namespaces, which
      # a check's sandbox lacks. `just test` runs agents/outer-git-test.
      testJails = pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux (let
        jailLib = mkJailedAgents {};
      in {
        outer-git = jailLib.makeJailedAgent {
          name = "outer-git-probe";
          agent = pkgs.bashInteractive;
          profile = "offline";
          sandboxGitIdentity = true; # as the specDev jails
          hostDoctrine = false;
          extraOptions = [
            (jailLib.outerGit jailLib.combinators {
              gitDir = ".cfg";
              parent = "/workspace";
            })
          ];
        };
      });

      # packages.helium = pkgs.callPackage ./helium.nix {};
      packages.zerostack = pkgs.callPackage ./zerostack.nix {};
      packages.dirge = pkgs.callPackage ./dirge.nix {};
    });
}
