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

  systemd.user = {
    # Headless Spotify Connect device — always on
    services.spotifyd = {
      Unit = {
        Description = "Spotify daemon (Connect device)";
        After = ["network-online.target"];
      };
      Service = {
        ExecStart = "${pkgs.spotifyd}/bin/spotifyd --no-daemon";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = ["default.target"];
    };

    # spotify_player daemon — Web API client for playback control
    services.spotify-player = {
      Unit = {
        Description = "spotify_player daemon";
        After = ["network-online.target"];
      };
      Service = {
        Type = "forking";
        ExecStart = "${sp} --daemon";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = ["default.target"];
    };

    # Health check: restart spotifyd when its websocket has gone stale.
    services.spotifyd-watchdog = {
      Unit = {
        Description = "spotifyd health check";
        After = ["spotifyd.service"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "%h/.local/bin/spotifyd-watchdog";
      };
    };

    timers.spotifyd-watchdog = {
      Unit.Description = "spotifyd health check (periodic)";
      Install.WantedBy = ["timers.target"];
      Timer = {
        Unit = "spotifyd-watchdog.service";
        OnBootSec = "5min";
        OnUnitActiveSec = "5min";
      };
    };

    # Alarm: switch to speakers and start playback
    services.spotify-alarm = {
      Unit = {
        Description = "Spotify alarm";
        After = ["spotifyd.service" "spotify-player.service"];
        Wants = ["spotifyd.service" "spotify-player.service"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "%h/.local/bin/spotify-alarm";
      };
    };

    timers.spotify-alarm = {
      Unit.Description = "Spotify alarm (weekdays)";
      Install.WantedBy = ["timers.target"];
      Timer = {
        Unit = "spotify-alarm.service";
        OnCalendar = "Mon..Fri 07:30";
        Persistent = true;
        AccuracySec = "1s";
      };
    };

    timers.spotify-alarm-weekend = {
      Unit.Description = "Spotify alarm (weekends)";
      Install.WantedBy = ["timers.target"];
      Timer = {
        Unit = "spotify-alarm.service";
        OnCalendar = "Sat,Sun 08:30";
        Persistent = true;
        AccuracySec = "1s";
      };
    };
  };
}
