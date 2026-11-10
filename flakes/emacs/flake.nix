{
  description = "dl's wrapped Emacs — the manual package list, as a flake";

  # Split out of pub so pub (jailed agents) carries no emacs-overlay. Owns its
  # pins: consumers should not `follows` them, so every devshell shares one
  # build. The host imports ./emacs.nix directly with its own pkgs.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    # Nested Wayland compositor for Emacs: its elisp joins the package list
    # and its binary is re-exported, both from this one pin so they match.
    emskin.url = "github:davidlee/emskin";
    # Emacs Wayland Manager: its elisp and compositor module, built for this
    # Emacs (a dynamic module must match the Emacs that loads it).
    ewm = {
      url = "git+https://codeberg.org/ezemtsov/ewm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    emacs-overlay,
    emskin,
    ewm,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    forAll = f:
      nixpkgs.lib.genAttrs systems (system:
        f (import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [emacs-overlay.overlays.default];
        }));
  in {
    packages = forAll (pkgs:
      rec {
        emacs = import ./emacs.nix {inherit pkgs emskin ewm;};
        default = emacs;
      }
      # Linux-only, and absent when `just isolation` stubs the input.
      // pkgs.lib.optionalAttrs (pkgs.stdenv.hostPlatform.isLinux && emskin ? packages) {
        emskin = emskin.packages.${pkgs.stdenv.hostPlatform.system}.default;
      });
  };
}
