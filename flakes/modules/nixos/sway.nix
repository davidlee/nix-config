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
      mako
    ];

    programs.uwsm = {
      enable = true;
      waylandCompositors = {
        sway = {
          prettyName = "Sway";
          comment = "Sway compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/sway";
        };
      };
    };

    home-manager.users.${username} = {
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

    # kanshi systemd service - monitor hot-swapping
    systemd.user.services.kanshi = {
      description = "kanshi daemon";
      environment = {
        WAYLAND_DISPLAY = "wayland-1";
        DISPLAY = ":0";
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = ''${pkgs.kanshi}/bin/kanshi -c kanshi_config_file'';
      };
    };
  };
}
