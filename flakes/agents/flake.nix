{
  description = "Public flakes — stable exports for external consumers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
    # The one agent pin for every consumer. Deliberately NOT following
    # nixpkgs, so the numtide binary cache (cache.numtide.com) applies.
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    jail-nix,
    llm-agents,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # `llm-agents` defaults to this flake's own pin; pass one only to diverge.
      mkJailedAgents = args:
        import ./jailed-agents.nix ({inherit pkgs jail-nix llm-agents;} // args);

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

      checks = pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
        jailed-agents = import ./jailed-agents-test.nix {
          inherit pkgs jail-nix;
        };
      };

      # packages.helium = pkgs.callPackage ./helium.nix {};
      packages.zerostack = pkgs.callPackage ./zerostack.nix {};
      packages.dirge = pkgs.callPackage ./dirge.nix {};
    });
}
