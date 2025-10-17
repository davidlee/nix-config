_: {
  flake.nixosModules.programs = {
    pkgs,
    username,
    ...
  }: {
    programs = {
      nix-ld.enable = true;
      dconf.enable = true;
      _1password.enable = true;

      appimage.binfmt = true;
      appimage.enable = true;

      _1password-gui = {
        enable = true;
        polkitPolicyOwners = [username];
      };

      rust-motd = {
        enable = true;
        settings = {
        };
      };

      thunar = {
        enable = true;
        plugins = with pkgs.xfce; [thunar-archive-plugin thunar-volman];
      };

      foot = {
        enable = true;
        theme = "gruvbox-dark";
        settings.main = {
          font = "Fira Code:size=11";
        };
      };

      zsh = {
        enable = true;
      };
    };

    environment.pathsToLink = ["/share/zsh"];
  };
}
