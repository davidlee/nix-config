{ pkgs, host, options, config, outputs, ...}:
let
  inherit (import ./variables.nix) keyboardLayout;
in {
  imports = [
    ./hardware-generated.nix
    ../../modules/nixosModules/default.nix
    ../../modules/nvidia-drivers.nix
  ];
  # implicit config.*
  users.enable = true;
  drivers.nvidia.enable = true;
  
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };
  nixpkgs = {
    # You can add overlays here
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

  # Network
  networking.networkmanager.enable = true;
  networking.hostName = host;
  networking.timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
  networking.firewall.allowedTCPPorts = [ 22 80 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  # console.keyMap = "${keyboardLayout}";
}
