# Audio features, in projection order. Shape: README § Feature tree.
{lib, ...}: [
  {
    name = "pipewire";
    nixos = {
      pkgs,
      username,
      ...
    }: {
      environment.systemPackages = with pkgs; [
        ## audio / music
        pavucontrol
        alsa-utils
        pipewire
        wireplumber
        ncpamixer
      ];
      security = {
        # rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
        rtkit.enable = true;
        pam.loginLimits = [
          # allow any user prog to request realtime priority
          {
            domain = "@users";
            item = "rtprio";
            type = "-";
            value = 1;
          }
        ];
      };
      boot.kernelModules = ["snd-seq" "snd-rawmidi" "snd-aloop"];
      users.users.${username}.extraGroups = ["jackaudio" "audio"];
      services = {
        pipewire = {
          enable = true; # if not already enabled
          audio.enable = true;
          alsa = {
            enable = true;
            support32Bit = true;
          };
          pulse = {
            enable = true;
          };

          # Airplay compat
          raopOpenFirewall = true;
          extraConfig.pipewire = {
            "10-airplay" = {
              "context.modules" = [
                {
                  name = "libpipewire-module-raop-discover";
                  # increase the buffer size if you get dropouts/glitches
                  # args = {
                  #   "raop.latency.ms" = 500;
                  # };
                }
              ];
            };
          };

          # extra bt protocols
          wireplumber.extraConfig."10-bluez" = {
            "monitor.bluez.properties" = {
              "bluez5.enable-sbc-xq" = true;
              "bluez5.enable-msbc" = true;
              "bluez5.enable-hw-volume" = true;
              "bluez5.roles" = [
                "hsp_hs"
                "hsp_ag"
                "hfp_hf"
                "hfp_ag"
              ];
            };
          };
          #jack.enable = true;
        };

        pulseaudio = {
          support32Bit = true;
          package = pkgs.pulseaudioFull;
          extraConfig = "load-module module-combine-sink";
          configFile = pkgs.writeText "default.pa" ''
            load-module module-bluetooth-policy
            load-module module-bluetooth-discover
            ## module fails to load with
            ##   module-bluez5-device.c: Failed to get device path from module arguments
            ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
            # load-module module-bluez5-device
            # load-module module-bluez5-discover
          '';
        };
      }; # services
    };
  }

  {
    name = "mpd";
    nixos = {username, ...}: {
      systemd.services.mpd.environment = {
        # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
        XDG_RUNTIME_DIR = "/run/user/${toString 1000}"; # User-id must match above user. MPD will look inside this directory for the PipeWire socket.
      };
      services = {
        mpd = {
          user = username;
          enable = true;
          musicDirectory = "/media/music";
          # `extraConfig` was removed upstream in favour of RFC42-style settings.
          settings = {
            audio_output = [
              {
                type = "pipewire";
                name = "My PipeWire Output";
              }
            ];
          };
        };
      };
    };
  }

  {
    name = "speech";
    nixos = {
      pkgs,
      # username,
      ...
    }: {
      environment.systemPackages = with pkgs; [
        ## text to speech
        espeak-ng
        # withTrain=false drops the torch(-rocm)+aotriton+lightning/tensorboard
        # closure; piper inference runs on onnxruntime. Re-enable only to train.
        (piper-tts.override {withTrain = false;})

        # BROKEN - transient python dep issue
        # python313Packages.kokoro

        ## speech to text — ROCm/gfx1201 build (overlays/whisper-rocm.nix)
        whisper-cpp-rocm
      ];
    };
  }

  # Streaming dictation: Nemotron 3.5 ASR on the CPU, typed at the cursor.
  #
  # The daemon loads the model at login and keeps the mic closed; a keybind
  # runs `dictate toggle` to start or stop. How it streams, and why typing as
  # you speak is safe, are in the script; `dictate-test` alongside it holds
  # that behaviour without a mic or display.
  #
  # Smoke:
  #   systemctl --user status dictate
  #   journalctl --user -u dictate -f
  #   dictate toggle
  {
    name = "dictate";
    homeManager = {
      lib,
      pkgs,
      ...
    }: let
      # sherpa-onnx's int8 export. The chunk size is baked into the export: 560ms
      # beat 320ms on both accuracy and CPU (DICTATE.md), for text arriving in
      # bigger bursts. 1120ms needs a longer tail pad in the script's `finish`.
      model = pkgs.fetchzip {
        name = "nemotron-3.5-asr-streaming-0.6b-560ms-int8";
        url = "https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-nemotron-3.5-asr-streaming-0.6b-560ms-int8-2026-06-11.tar.bz2";
        hash = "sha256-BLk8afX1okpEHMoV2oAmyQw53eJ6zNqLutjM2Tqb6qk=";
      };
      python = pkgs.python3.withPackages (p: [p.sherpa-onnx p.numpy]);
    in {
      # A plain script in ~/.local/bin, as snooze-nag is. `dictate toggle` needs
      # only the standard library, so any python3 will run it from a keybind.
      home.file.".local/bin/dictate" = {
        source = ./audio/dictate;
        executable = true;
      };

      systemd.user.services.dictate = {
        Unit = {
          Description = "Streaming dictation";
          # wtype types into the compositor; with no session there is nowhere
          # to type.
          After = ["graphical-session.target"];
          PartOf = ["graphical-session.target"];
        };
        Install.WantedBy = ["graphical-session.target"];
        Service = {
          # The store path, not ~/.local/bin: a changed script then changes the
          # unit, so home-manager restarts the daemon on switch.
          ExecStart = "${python}/bin/python3 ${./audio/dictate}";
          Environment = [
            "DICTATE_MODEL=${model}"
            "DICTATE_LANG=en"
            "PATH=${lib.makeBinPath [pkgs.wtype pkgs.pipewire pkgs.libnotify]}"
          ];
          Restart = "on-failure";
        };
      };
    };
  }

  # Spotify alarm: spotifyd as a Connect device, spotify_player to drive it,
  # and timers that start playback. Bound to this machine's speakers and its
  # Connect name, so a host selects it, not personal-linux. The alarm script
  # calls spotify_player from PATH, hence the requirement. See ALARM.md.
  {
    name = "alarm";
    platforms = lib.platforms.linux;
    requires = ["media.spotify"];
    homeManager = {pkgs, ...}: let
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
          source = ./audio/alarm/spotifyd-watchdog;
          executable = true;
        };
        ".local/bin/spotify-alarm" = {
          source = ./audio/alarm/spotify-alarm;
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
    };
  }
]
