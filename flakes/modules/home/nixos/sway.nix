_: {
  flake.homeModules.sway = {
    pkgs,
    lib,
    ...
  }: {
    systemd.user.services.swayosd = {
      Unit = {
        # more forgiving rate limit so transient crashes don't permanently kill the service
        StartLimitBurst = lib.mkForce 10;
        StartLimitIntervalSec = lib.mkForce 60;
      };
      Service.RestartSec = lib.mkForce "5s";
    };
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
