{
  inputs,
  pkgs,
  ...
}: {
  flake.nixosModules.nix = {pkgs, ...}: {
    system.stateVersion = "24.11";
    nixpkgs.config.allowUnfree = true;

    nix = {
      settings = {
        trusted-users = ["root" "@wheel"];
        experimental-features = ["nix-command" "flakes"];
        max-jobs = 12;
        cores = 12;
        auto-optimise-store = true;
        substituters = [
          "https://cache.nixos.org"
          "https://cosmic.cachix.org/"
          "https://nixpkgs-wayland.cachix.org"
          "https://walker.cachix.org"
          "https://walker-git.cachix.org"
          "https://hyprland.cachix.org"
        ];

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
          "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
          "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
          "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
      };

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 1w";
      };
    };

    environment.systemPackages = with pkgs; [
      inputs.nix-search-tv.packages.x86_64-linux.default
      alejandra
      appimage-run
      flatpak
      cachix
      comma
      devenv
      manix
      nh
      nil
      nix-bash-completions
      nix-bisect
      nix-btm
      nixd
      nix-deploy
      nix-derivation
      nix-diff
      nix-direnv
      nix-du
      nixfmt-rfc-style
      nix-forecast
      nix-health
      nix-index
      nix-inspect
      nix-janitor
      nix-melt
      nix-output-monitor
      nix-search-cli
      nix-search-tv
      nix-top
      nix-tree
      nvd
      pkg-config
      sd-switch
    ];
  };
}
