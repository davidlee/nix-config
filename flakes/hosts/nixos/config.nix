{...}: {
  imports = [
    ../../system/nix.nix
    ../../system/mine.nix
    ../../system/default.nix
    ../../system/nvidia-drivers.nix
    ./hardware-configuration.nix
  ];

  mine.something = true;
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
        "https://hyprland.cachix.org"
        "https://walker.cachix.org"
        "https://walker-git.cachix.org"
        "https://cache.nixos.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://cosmic.cachix.org"
        "https://cosmic.cachix.org/"
      ];
    
      trusted-public-keys = [
        "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
        "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
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
}
