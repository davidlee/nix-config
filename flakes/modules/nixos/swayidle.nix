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
    }; # home-manager
  };
}
