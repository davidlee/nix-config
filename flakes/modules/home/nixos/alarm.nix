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

      # Two failure modes to detect:
      # 1. Websocket died: last recent log line is a WARN
      # 2. Never connected: started after S3 resume with no network, stuck
      #    with no "active device is" line since boot. Only act if it's been
      #    running > 2 min to avoid racing a fresh restart.
      started=$(${pkgs.systemd}/bin/systemctl --user show spotifyd.service \
        -p ActiveEnterTimestamp --value)
      started_epoch=$(${pkgs.coreutils}/bin/date -d "$started" +%s)
      now_epoch=$(${pkgs.coreutils}/bin/date +%s)
      uptime=$((now_epoch - started_epoch))

      has_session=$(${pkgs.systemd}/bin/journalctl --user -u spotifyd.service \
        --since "$started" -o cat -q \
        | ${pkgs.gnugrep}/bin/grep -c "active device is" || true)
      last=$(${pkgs.systemd}/bin/journalctl --user -u spotifyd.service \
               --since "15 minutes ago" -o cat -q | tail -n 1)

      needs_restart=false
      case "$last" in
        *"[WARN] Websocket"*|*"does not respond"*|*"Error while closing websocket"*)
          echo "spotifyd stale (last log: $last)"
          needs_restart=true ;;
      esac
      if [ "$has_session" = "0" ] && [ "$uptime" -gt 120 ]; then
        echo "spotifyd never connected in ''${uptime}s since $started"
        needs_restart=true
      fi

      if [ "$needs_restart" = "true" ]; then
        echo "restarting spotifyd"
        ${pkgs.systemd}/bin/systemctl --user restart spotifyd.service
      fi
    '';

    py = "${pkgs.python3}/bin/python3";

    alarmScript = pkgs.writeShellScript "spotify-alarm" ''
            set -euo pipefail

            SPEAKERS="${speakers}"

            # Set speakers as default so new streams (including spotifyd
            # after restart) land there.
            ${pkgs.pulseaudio}/bin/pactl set-default-sink "$SPEAKERS"

            # --- Phase 1: get spotifyd connected to Spotify ---
            # After S3 resume, the network takes 10-30s to stabilize. We restart
            # spotifyd and poll its log for "active device is" (proof of connection).
            # nm-online is best-effort (can return stale state after resume).
            ${pkgs.networkmanager}/bin/nm-online -q --timeout=30 || true
            for round in 1 2 3; do
              ${pkgs.systemd}/bin/systemctl --user restart spotifyd.service
              connected=false
              for i in $(seq 1 30); do
                if ${pkgs.systemd}/bin/journalctl --user -u spotifyd.service \
                     --since "30 seconds ago" -o cat -q \
                     | ${pkgs.gnugrep}/bin/grep -q "active device is"; then
                  connected=true; break
                fi
                sleep 1
              done
              if [ "$connected" = "true" ]; then break; fi
              echo "Round $round/3: spotifyd didn't connect, retrying..."
            done

            # --- Phase 2: activate the correct device ---
            # Refresh spotify-player first: the long-lived daemon's cached
            # Web API view can miss devices that (re)registered while it was
            # idle across S3 cycles. Cheap, ~2-3s.
            ${pkgs.systemd}/bin/systemctl --user restart spotify-player.service
            for i in $(seq 1 15); do
              ${sp} get key devices >/dev/null 2>&1 && break
              sleep 1
            done

            # After restart, Spotify's API may list ghost device registrations
            # alongside the live one, all named "${spotifydDevice}". Both connect
            # --name and connect --id return exit 0 regardless of success. We must
            # try each ID and verify activation via the API.
            # The API lags behind spotifyd's log by a few seconds, so retry.
            activated=false
            for attempt in $(seq 1 12); do
              RAW=$(${sp} get key devices 2>&1) || {
                echo "Attempt $attempt/12: sp get key devices failed: $RAW"
                sleep 5
                continue
              }
              IDS=$(printf '%s' "$RAW" | ${py} -c "import sys,json
      for d in json.load(sys.stdin):
        if d['name'] == '${spotifydDevice}': print(d['id'])" 2>&1 || true)

              if [ -z "$IDS" ]; then
                echo "Attempt $attempt/12: no ${spotifydDevice} devices in API yet (raw: $RAW)"
                sleep 5
                continue
              fi

              for id in $IDS; do
                ${sp} connect --id "$id" 2>/dev/null || true
                sleep 1
                RAW2=$(${sp} get key devices 2>&1) || {
                  echo "Attempt $attempt/12: sp get key devices (verify) failed: $RAW2"
                  continue
                }
                is_active=$(printf '%s' "$RAW2" | ${py} -c "import sys,json
      print(any(d['id']=='$id' and d['is_active'] for d in json.load(sys.stdin)))" 2>&1 || echo False)
                if [ "$is_active" = "True" ]; then
                  echo "Activated device $id"
                  activated=true; break
                fi
              done
              if [ "$activated" = "true" ]; then break; fi
              echo "Attempt $attempt/12: activation failed, retrying..."
              sleep 5
            done
            if [ "$activated" != "true" ]; then
              echo "Failed to activate any ${spotifydDevice} device"
              exit 1
            fi

            # --- Phase 3: start playback ---
            ${sp} playback start context \
              --id "2gs3W3XLA36fK0z3mL7MtJ" playlist --shuffle 2>/dev/null || true
            ${sp} playback play 2>/dev/null || true
            ${sp} playback volume 100 2>/dev/null || true

            # Move all sink inputs (including spotifyd's new one) to speakers.
            # set-default-sink above covers new streams, but this catches any
            # that were already routed elsewhere.
            sleep 1
            ${pkgs.pulseaudio}/bin/pactl list short sink-inputs \
              | awk '{print $1}' \
              | while read -r id; do
                  ${pkgs.pulseaudio}/bin/pactl move-sink-input "$id" "$SPEAKERS"
                done
            echo "Alarm started"
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
  };
}
