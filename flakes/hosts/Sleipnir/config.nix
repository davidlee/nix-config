{inputs, pkgs, ...}: {
  imports = [
    # inputs.lix-module.nixosModules.default
    inputs.nixarr.nixosModules.default
    ./hardware-configuration.nix

    ../../nixos/boot.nix
    ../../nixos/nvidia-drivers.nix
    ../../nixos/network.nix
    ../../nixos/accounts.nix
    ../../nixos/nixos-packages.nix
    ../../nixos/nixos-apps.nix
    ../../nixos/tui.nix
    ../../nixos/wayland.nix
    ../../nixos/gnome.nix
    ../../nixos/sway.nix
    ../../nixos/serve.nix
    ../../nixos/arr.nix
    ../../nixos/games.nix
    ../../nixos/virtualisation.nix
    ../../nixos/fonts.nix
  ];

  users.enable = true;

  system.stateVersion = "24.11"; 
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      trusted-users = [ "root" "@wheel" ];
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org"
        "https://walker.cachix.org"
        "https://walker-git.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
      # ];
      # extra-substituters = [
      ];
    
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
        "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
  };
   
  # enable SSD trim & improve perf
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ]; 

  services = {
    kmonad.enable = true;
    devmon.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    sysprof.enable = true;
    printing.enable = true;

    jack = {
      jackd.enable = true;
      # support ALSA only programs via ALSA JACK PCM plugin
      alsa.enable = false;
      # support ALSA only programs via loopback device (supports programs like Steam)
      loopback = {
        enable = true;
        # buffering parameters for dmix device to work with ALSA only semi-professional sound programs
        #dmixConfig = ''
        #  period_size 2048
        #'';
      };
    };
    
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    locate = {
      enable = true;
      package = pkgs.plocate;
      interval = "hourly";
    };
  };
}
