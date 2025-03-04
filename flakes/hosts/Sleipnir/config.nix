{inputs, pkgs, ...}: {
  imports = [
    inputs.lix-module.nixosModules.default
    ./hardware-configuration.nix

    ../../nixos/boot.nix
    ../../nixos/nvidia-drivers.nix
    ../../nixos/accounts.nix
    ../../nixos/network.nix
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
      substituters = [ "https://cosmic.cachix.org/" ];
      extra-substituters = [
        "https://walker.cachix.org"
        "https://walker-git.cachix.org"
        "https://cache.nixos.org"
      ];
    
      trusted-public-keys = [
        "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
        "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
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

    caddy = {
      enable = true;
      acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
    };
  };
}
