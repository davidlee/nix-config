{
  pkgs,
  username,
  # lib,
  ...
}: {

  security = {
    polkit.enable = true;
    pam.services.swaylock = {};
  };

  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
  };
  
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
      waybar
      spatial-shell
    ];

    services = {
      swayosd.enable = true;
    };
    
    wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;

      config = null; # clobber defaults
      extraConfig = ''

        include $HOME/.config/sway/sway.conf
       '';
    };
  };
 }
