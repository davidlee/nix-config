{ pkgs, host, options, hy3, config, outputs, ...}:
let
  inherit (import ./variables.nix) keyboardLayout;
in {
  imports = [
    ./hardware-configuration.nix
    ../../system/default.nix
    ../../system/nvidia-drivers.nix
  ];

  nix.settings = {
    trusted-users = [ "root" "david" "@wheel" ];
    experimental-features = [ "nix-command" "flakes" ];
    download-buffer-size = 500000000;
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  users.enable = true;
  
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
