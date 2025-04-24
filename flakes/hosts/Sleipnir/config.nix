{inputs, pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    inputs.lix-module.nixosModules.default 
    inputs.nixarr.nixosModules.default
    # inputs.nixos-cosmic.nixosModules.default

    ../../nixos/boot.nix
    ../../nixos/nvidia.nix
    ../../nixos/network.nix
    ../../nixos/accounts.nix
    ../../nixos/packages.nix
    ../../nixos/comp-lang.nix
    ../../nixos/tui.nix
    ../../nixos/apps.nix
    ../../nixos/wayland.nix
    ../../nixos/gnome.nix
    # ../../nixos/cosmic.nix
    ../../nixos/kde.nix
    ../../nixos/sway.nix
    ../../nixos/serve.nix
    ../../nixos/arr.nix
    ../../nixos/games.nix
    ../../nixos/virtualisation.nix
    ../../nixos/fonts.nix
    ../../nixos/rust.nix
    ../../nixos/zig.nix

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
        "https://cosmic.cachix.org/" 
        "https://nixpkgs-wayland.cachix.org"
        "https://walker.cachix.org"
        "https://walker-git.cachix.org"
      ];
    
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" 
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
    blueman.enable = true;
    printing.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    
    locate = {
      enable = true;
      package = pkgs.plocate;
      interval = "hourly";
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    pulseaudio = {
      package = pkgs.pulseaudioFull; # additional codecs
    };

    jack = {
      jackd.enable = true;
      alsa.enable = false;
      loopback = {
        enable = true;
      };
    };
  };

  hardware = {
    logitech.wireless.enable = true;
    xpadneo.enable = true;
  
    # it's amazing bluetooth _ever_ works
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      
      settings = {
        General = {
          Experimental = true; # battery level
          JustWorksRepairing = "always";
          FastConnectable = true;
          # Class = "0x00100";
          Privacy = "device";
        };
      };
    };

    # printers = {
    #   # ensurePrinters = [{ .. }];
    # };
  };

}
