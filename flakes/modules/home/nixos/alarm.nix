_: {
  flake.homeModules.alarm = {pkgs, ...}: let
    speakers = "alsa_output.usb-ZhuHai-JieLi-Technology_USB_AUDIO_20180105-01.analog-stereo";
    # Name must match device_name in spotifyd.conf
    spotifydDevice = "Sleipnir";

    sp = "${pkgs.spotify-player}/bin/spotify_player";

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

      # Route audio to speakers
      ${pkgs.pulseaudio}/bin/pactl set-default-sink "$SPEAKERS"
      ${pkgs.pulseaudio}/bin/pactl list short sink-inputs \
        | awk '{print $1}' \
        | while read -r id; do
            ${pkgs.pulseaudio}/bin/pactl move-sink-input "$id" "$SPEAKERS"
          done

      # Start playback then move it to spotifyd
      retry ${sp} playback start context \
        --id "2gs3W3XLA36fK0z3mL7MtJ" playlist --shuffle
      retry ${sp} connect --name "${spotifydDevice}"
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

      # Alarm: switch to speakers and start playback
      services.spotify-alarm = {
        Unit = {
          Description = "Spotify alarm";
          After = ["spotifyd.service"];
          Wants = ["spotifyd.service"];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${alarmScript}";
        };
      };

      timers.spotify-alarm-test = {
        Unit.Description = "Spotify alarm (test — remove me)";
        Install.WantedBy = ["timers.target"];
        Timer = {
          Unit = "spotify-alarm.service";
          OnCalendar = "*:0/5";
          Persistent = true;
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
