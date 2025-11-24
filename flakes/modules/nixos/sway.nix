_: {
  flake.nixosModules.sway = {
    pkgs,
    username,
    ...
  }: {
    programs = {
      sway = {
        enable = true;
        wrapperFeatures.gtk = true;
      };
    }; # programs

    environment.systemPackages = with pkgs; [
      sway-launcher-desktop
      sway-easyfocus
      sway-overfocus
      sway-scratch
      sway-new-workspace
      sway-easyfocus
      swaylock
      swaylock-fancy
      swaynotificationcenter
      swaycwd
      swaymux
      swaycons
      swaysettings
      swayr
      swayrbar
      swayosd
      waybar
      mako
      cava
    ];

    home-manager.users.${username} = {
      services = {
        swayosd.enable = true;
      }; # user services

      wayland.windowManager.sway = {
        enable = true;
        wrapperFeatures.gtk = true;

        config = null; # clobber defaults
        extraConfig = ''
          include $HOME/.config/sway/sway.conf

          # give Sway a little time to startup before starting kanshi.
          exec sleep 5; systemctl --user start kanshi.service
        '';
      }; # sway

      programs = {
        waybar = {
          enable = true;
          systemd.enable = true;
        };
      }; # user programs
    }; # home-manager
  };
}
