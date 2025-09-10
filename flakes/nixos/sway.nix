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
      swayidle = let
        # screen = "DP-3";
        lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
        display = status: "${pkgs.sway}/bin/swaymsg 'output * dpms ${status}'";
      in {
        enable = true;
        timeouts = [
          {
            timeout = 1790; # in seconds
            command = "${pkgs.libnotify}/bin/notify-send 'Locking in 5 seconds' -t 5000";
          }
          {
            timeout = 1800; # 30m
            command = lock;
          }
          {
            timeout = 2000;
            command = display "off";
            resumeCommand = display "on";
          }
          # {
          #   timeout = 30;
          #   command = "${pkgs.systemd}/bin/systemctl suspend";
          # }
        ];
        events = [
          # {
          #   event = "before-sleep";
          #   # adding duplicated entries for the same event may not work
          #   command = (display "off") + "; " + lock;
          # }
          {
            event = "after-resume";
            command = display "on";
          }
          {
            event = "lock";
            command = (display "off") + "; " + lock;
          }
          {
            event = "unlock";
            command = display "on";
          }
        ];
      };
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
