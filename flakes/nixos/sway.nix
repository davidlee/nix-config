{
  pkgs,
  username,
  # lib,
  ...
}: {
  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
  }; # programs

  services = {
  }; # services

  home-manager.users.${username} = {
    home.packages = with pkgs; [
      sway-launcher-desktop
      sway-audio-idle-inhibit
      sway-easyfocus
      sway-overfocus
      sway-scratch
      sway-new-workspace
      sway-easyfocus
      swayidle
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
    ]; # user packages

    services = {
      swayosd.enable = true;
    }; # user services

    wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;

      config = null; # clobber defaults
      extraConfig = ''

        include $HOME/.config/sway/sway.conf
      '';
    }; # sway

    programs = {
      waybar = {
        enable = true;
        systemd.enable = true;
      };
    }; # user programs
  }; # home-manager
}
