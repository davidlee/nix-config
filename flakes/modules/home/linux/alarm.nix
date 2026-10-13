{pkgs, ...}: let
  # Name must match device_name in spotifyd.conf
  spotifydDevice = "Sleipnir";
  sp = "${pkgs.spotify-player}/bin/spotify_player";
in {
  # spotifyd config
  xdg.configFile."spotifyd/spotifyd.conf".text = ''
    [global]
    device_name = "${spotifydDevice}"
    device_type = "computer"
    bitrate = 320
    backend = "pulseaudio"
    volume_normalisation = true
  '';

  # Watchdog + alarm logic live as plain shell scripts in ~/.local/bin
  # so they can be read, edited, and dry-run without going through nix.
  home.file = {
    ".local/bin/spotifyd-watchdog" = {
      source = ./bin/spotifyd-watchdog;
      executable = true;
    };
    ".local/bin/spotify-alarm" = {
      source = ./bin/spotify-alarm;
      executable = true;
    };
  };

  systemd = {
    user = {
      services = {
        # Alarm: switch to speakers and start playback
        spotify-alarm = {
          Service = {
            ExecStart = "%h/.local/bin/spotify-alarm";
            Type = "oneshot";
          };
          Unit = {
            After = ["spotifyd.service" "spotify-player.service"];
            Description = "Spotify alarm";
            Wants = ["spotifyd.service" "spotify-player.service"];
          };
        };
        # spotify_player daemon — Web API client for playback control
        spotify-player = {
          Install.WantedBy = ["default.target"];
          Service = {
            ExecStart = "${sp} --daemon";
            Restart = "on-failure";
            RestartSec = 5;
            Type = "forking";
          };
          Unit = {
            After = ["network-online.target"];
            Description = "spotify_player daemon";
          };
        };
        # Headless Spotify Connect device — always on
        spotifyd = {
          Install.WantedBy = ["default.target"];
          Service = {
            ExecStart = "${pkgs.spotifyd}/bin/spotifyd --no-daemon";
            Restart = "on-failure";
            RestartSec = 5;
          };
          Unit = {
            After = ["network-online.target"];
            Description = "Spotify daemon (Connect device)";
          };
        };
        spotifyd-watchdog = {
          Service = {
            ExecStart = "%h/.local/bin/spotifyd-watchdog";
            Type = "oneshot";
          };
          Unit = {
            After = ["spotifyd.service"];
            Description = "spotifyd health check";
          };
        };
      };
      timers = {
        spotify-alarm = {
          Install.WantedBy = ["timers.target"];
          Timer = {
            AccuracySec = "1s";
            OnCalendar = "Mon..Fri 07:30";
            Persistent = true;
            Unit = "spotify-alarm.service";
          };
          Unit = {Description = "Spotify alarm (weekdays)";};
        };
        spotify-alarm-weekend = {
          Install.WantedBy = ["timers.target"];
          Timer = {
            AccuracySec = "1s";
            OnCalendar = "Sat,Sun 08:30";
            Persistent = true;
            Unit = "spotify-alarm.service";
          };
          Unit.Description = "Spotify alarm (weekends)";
        };
        # Health check: restart spotifyd when its websocket has gone stale.
        spotifyd-watchdog = {
          Install.WantedBy = ["timers.target"];
          Timer = {
            OnBootSec = "5min";
            OnUnitActiveSec = "5min";
            Unit = "spotifyd-watchdog.service";
          };
          Unit.Description = "spotifyd health check (periodic)";
        };
      };
    };
  };
}
