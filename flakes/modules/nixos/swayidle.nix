_: {
  flake.nixosModules.swayidle = {
    pkgs,
    username,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      sway-audio-idle-inhibit
      swayidle
    ];

    home-manager.users.${username} = {
      services = {
        swayidle = let
          # screen = "DP-3";
          display = status: "${pkgs.sway}/bin/swaymsg 'output * dpms ${status}'";
          lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
          DISPLAY = "DP-3";
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
              # command = "wlopm --off ${DISPLAY}";
              # resumeCommand = "wlopm --on ${DISPLAY}";
            }
            # {
            #   timeout = 30;
            #   command = "${pkgs.systemd}/bin/systemctl suspend";
            # }
          ];
          # events = {
          #   # "before-sleep" = (display "off")  + "; " + lock;
          #   "after-resume" = "wlopm --on ${DISPLAY}";
          #   "lock" = "wlopm --off ${DISPLAY}; " + lock;
          #   "unlock" = "wlopm --on ${DISPLAY}";
          # };
        };
      }; # user services
    }; # home-manager
  };
}
