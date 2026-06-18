{
  description = "Public flakes — stable exports for external consumers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
    emacs-overlay.url = "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
    emacs-config = {
      url = "github:davidlee/emacs-config";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    jail-nix,
    emacs-overlay,
    emacs-config,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [emacs-overlay.overlays.default];
      };
    in {
      lib.mkJailedAgents = {llm-agents}:
        import ./jailed-agents.nix {
          inherit pkgs jail-nix llm-agents;
        };

      packages.emacs = import ./emacs.nix {
        inherit pkgs;
        emacsConfig = emacs-config;
      };
      packages.helium = pkgs.callPackage ./helium.nix {};
      packages.zerostack = pkgs.callPackage ./zerostack.nix {};
      packages.dirge = pkgs.callPackage ./dirge.nix {};
    });
}
