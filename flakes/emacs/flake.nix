{
  description = "dl's wrapped Emacs — the manual package list, as a flake";

  # Split out of pub so pub (jailed agents) carries no emacs-overlay. Owns its
  # pins: consumers should not `follows` them, so every devshell shares one
  # build. The host imports ./emacs.nix directly with its own pkgs.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    emacs-overlay.url = "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
  };

  outputs = {
    nixpkgs,
    emacs-overlay,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-darwin"];
    forAll = f:
      nixpkgs.lib.genAttrs systems (system:
        f (import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [emacs-overlay.overlays.default];
        }));
  in {
    packages = forAll (pkgs: rec {
      emacs = import ./emacs.nix {inherit pkgs;};
      default = emacs;
    });
  };
}
