_: {
  flake.homeModules.sway = {
    pkgs,
    username,
    lib,
    ...
  }: let
    wpmPython = pkgs.python3.withPackages (ps: [ps.evdev]);
    wpmScript = "/home/${username}/.config/waybar/wpm-status.py";
    wpmArchiveYesterday = pkgs.writeShellScript "wpm-archive-yesterday" ''
      set -euo pipefail
      yesterday=$(${pkgs.coreutils}/bin/date -d yesterday +%F)
      file=/home/${username}/notes/satan/log/wpm/"$yesterday".tsv
      if [ ! -f "$file" ]; then
        echo "no log for $yesterday at $file; nothing to archive"
        exit 0
      fi
      exec ${wpmPython}/bin/python3 ${wpmScript} --archive-hourly "$file"
    '';
  in {
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
      systemd.enable = true;

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

    home.packages = [wpmPython];
    systemd.user.services.wpm-daemon = {
      Unit = {
        Description = "Keypress counter for Waybar WPM";
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${wpmPython}/bin/python3 ${wpmScript} --daemon";
        Restart = "always";
        RestartSec = "2s";
      };
      Install = {WantedBy = ["graphical-session.target"];};
    };

    systemd.user.services.wpm-archive = {
      Unit.Description = "Roll yesterday's WPM log into hourly buckets";
      Service = {
        Type = "oneshot";
        ExecStart = "${wpmArchiveYesterday}";
      };
    };
    systemd.user.timers.wpm-archive = {
      Unit.Description = "Daily WPM log archival (yesterday at 04:00)";
      Timer = {
        OnCalendar = "*-*-* 04:00:00";
        Persistent = true;
        RandomizedDelaySec = "5m";
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
