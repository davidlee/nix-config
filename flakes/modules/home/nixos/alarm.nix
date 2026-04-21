_: {
  flake.homeModules.alarm = {pkgs, ...}: let
    speakers = "alsa_output.usb-ZhuHai-JieLi-Technology_USB_AUDIO_20180105-01.analog-stereo";
    # Name must match device_name in spotifyd.conf
    spotifydDevice = "Sleipnir";

    sp = "${pkgs.spotify-player}/bin/spotify_player";

    watchdogScript = pkgs.writeShellScript "spotifyd-watchdog" ''
      set -eu

      # Don't disturb active playback: if something is streaming, spotifyd is
      # functional enough — let any transient blip recover on its own.
      playback=$(${sp} get key playback 2>/dev/null || echo null)
      case "$playback" in
        *'"is_playing":true'*) exit 0 ;;
      esac

      # Check spotifyd's last log line in the recent window. When the daemon's
      # websocket to Spotify dies it emits WARNs and then goes silent — the
      # last line staying as a WARN is the staleness signal. A healthy recovery
      # leaves an INFO (e.g. "active device is ...") as the most recent line.
      last=$(${pkgs.systemd}/bin/journalctl --user -u spotifyd.service \
               --since "15 minutes ago" -o cat -q | tail -n 1)
      case "$last" in
        *"[WARN] Websocket"*|*"does not respond"*|*"Error while closing websocket"*)
          echo "spotifyd stale (last log: $last); restarting"
          ${pkgs.systemd}/bin/systemctl --user restart spotifyd.service
          ;;
      esac
    '';

    alarmScript = pkgs.writeShellScript "spotify-alarm" ''
      set -euo pipefail

      retry() {
        local max=10 delay=3
        for ((i = 1; i <= max; i++)); do
          if "$@"; then return 0; fi
          echo "Attempt $i/$max failed, retrying in ''${delay}s..."
          sleep "$delay"
        done
        echo "All $max attempts failed: $1"
        return 1
      }

      SPEAKERS="${speakers}"

      # Wait for network after S3 resume — the alarm timer wakes the machine,
      # but the network stack needs a few seconds to come up.
      ${pkgs.networkmanager}/bin/nm-online -q --timeout=30

      # Route audio to speakers
      ${pkgs.pulseaudio}/bin/pactl set-default-sink "$SPEAKERS"
      ${pkgs.pulseaudio}/bin/pactl list short sink-inputs \
        | awk '{print $1}' \
        | while read -r id; do
            ${pkgs.pulseaudio}/bin/pactl move-sink-input "$id" "$SPEAKERS"
          done

      # Refresh spotifyd with a known-good network connection.
      ${pkgs.systemd}/bin/systemctl --user restart spotifyd.service

      # Poll for spotifyd's device ID from its log. After restart, the old
      # device registration lingers as a ghost on Spotify's API — connect by
      # name silently picks the wrong one. Connect by ID is unambiguous.
      DEVICE_ID=""
      for attempt in $(seq 1 15); do
        DEVICE_ID=$(${pkgs.systemd}/bin/journalctl --user -u spotifyd.service \
          --since "30 seconds ago" -o cat -q \
          | ${pkgs.gnugrep}/bin/grep -oP 'active device is <\K[^>]+' | tail -n 1 || true)
        if [ -n "$DEVICE_ID" ]; then break; fi
        sleep 1
      done
      if [ -z "$DEVICE_ID" ]; then
        echo "Failed to get spotifyd device ID after 15s"
        exit 1
      fi
      echo "spotifyd device: $DEVICE_ID"

      # Activate spotifyd as the target device, then start playback.
      retry ${sp} connect --id "$DEVICE_ID"
      retry ${sp} playback start context \
        --id "2gs3W3XLA36fK0z3mL7MtJ" playlist --shuffle
      retry ${sp} playback volume 100
    '';
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
          ExecStart = "${watchdogScript}";
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
          ExecStart = "${alarmScript}";
        };
      };

      timers.spotify-alarm = {
        Unit.Description = "Spotify alarm (weekdays)";
        Install.WantedBy = ["timers.target"];
        Timer = {
          Unit = "spotify-alarm.service";
          OnCalendar = "Mon..Fri 07:00";
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
  };
}
