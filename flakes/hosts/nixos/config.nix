{ pkgs, config, options, lib, ...}:

with lib;
{
  imports = [
    ./hardware-configuration.nix
    ../../system/default.nix
    ../../system/nvidia-drivers.nix
  ];

  nix.settings = {
    trusted-users = [ "root" "david" "@wheel" ];
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    substituters = [ "https://cosmic.cachix.org/" ];
    trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  users.enable = true;

  # useHyprland = mkEnableOption "use hyprland?";
  # useSway     = mkEnableOption "use sway?";
  
  # enable SSD trim & improve perf
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ]; 

  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      # outputs.overlays.additions
      # outputs.overlays.modifications
      # outputs.overlays.stable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
    ];
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11"; # Non tocas
}
