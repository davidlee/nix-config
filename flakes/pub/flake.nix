{
  description = "Public flakes — stable exports for external consumers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
    emacs-overlay.url = "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    jail-nix,
    emacs-overlay,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [emacs-overlay.overlays.default];
      };

      mkJailedAgents = args @ {llm-agents, ...}:
        import ./jailed-agents.nix (
          {
            inherit pkgs jail-nix llm-agents;
          }
          // builtins.removeAttrs args ["llm-agents"]
        );

      # Ready-made nixpkgs overlay injecting the unjailed agent CLIs under
      # their short names (codex, claude, gemini, ...). Consumers apply it
      # to their own nixpkgs so `pkgs.codex` is the llm-agents build:
      #   overlays = [ (pub.lib.${system}.agentsOverlay {inherit (inputs) llm-agents;}) ];
      # `agents` narrows which names to inject; pass their own llm-agents so
      # each consumer keeps control of the pin (numtide cache stays warm).
      agentsOverlay = {
        llm-agents,
        agents ? null, # null => every agentsByName entry
      }: _final: _prev: let
        byName = (mkJailedAgents {inherit llm-agents;}).agentsByName;
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

      packages.emacs = import ./emacs.nix {inherit pkgs;};
      # packages.helium = pkgs.callPackage ./helium.nix {};
      packages.zerostack = pkgs.callPackage ./zerostack.nix {};
      packages.dirge = pkgs.callPackage ./dirge.nix {};
    });
}
