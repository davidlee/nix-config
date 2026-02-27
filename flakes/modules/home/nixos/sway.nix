_: {
  flake.homeModules.sway = {pkgs, ...}: {
    services = {
      swayosd.enable = true;

      swayidle = let
        display = status: "${pkgs.sway}/bin/swaymsg 'output * dpms ${status}'";
        lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
      in {
        enable = true;
        timeouts = [
          {
            timeout = 1790;
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
        ];
      };
    };

    wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;

      config = null; # clobber defaults
      extraConfig = ''
        include $HOME/.config/sway/sway.conf

        # give Sway a little time to startup before starting kanshi.
        exec sleep 5; systemctl --user start kanshi.service
      '';
    };

    programs = {
      waybar = {
        enable = true;
        systemd.enable = true;
      };
    };
  };
}
