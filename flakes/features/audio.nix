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

  # Text to speech. `say` renders with piper or kokoro and plays on any
  # PipeWire sink; `say-test` alongside it holds that behaviour without an
  # engine or speakers.
  #
  # Smoke:
  #   say hello
  #   echo hello | say -e kokoro -d <node.name from `pw-cli ls Node`>
  {
    name = "speech";
    homeManager = _: {
      home.file.".local/bin/say" = {
        source = ./audio/say;
        executable = true;
      };
    };
    nixos = {
      lib,
      pkgs,
      # username,
      ...
    }: let
      # piper voices, pinned, in a --data-dir so `piper -m <voice>` finds them
      # by name. More: https://huggingface.co/rhasspy/piper-voices
      piperRev = "c10ece1aade47bb51c153c893d14e5bf8e5b7117";
      # One voice's files as linkFarm entries; en_GB-cori-high lives at
      # en/en_GB/cori/high/ in the repo.
      piperVoiceFiles = voice: hashes: let
        parts = lib.splitString "-" voice;
        lang = lib.elemAt parts 0;
        family = lib.head (lib.splitString "_" lang);
        dir = lib.concatStringsSep "/" [family lang (lib.elemAt parts 1) (lib.elemAt parts 2)];
      in
        lib.mapAttrsToList (ext: hash: {
          name = "${voice}${ext}";
          path = pkgs.fetchurl {
            url = "https://huggingface.co/rhasspy/piper-voices/resolve/${piperRev}/${dir}/${voice}${ext}";
            inherit hash;
          };
        })
        hashes;
      piperVoices = pkgs.linkFarm "piper-voices" (lib.concatLists (lib.mapAttrsToList piperVoiceFiles {
        en_GB-alan-medium = {
          ".onnx" = "sha256-CjCWaJMiBedigB8e/Cc2zUsBIDKWIq32K+CeVjOdMzA=";
          ".onnx.json" = "sha256-wPDRJOWJXADnwDs13MgofzGaaZijZbGC3rXI51LujB4=";
        };
        en_GB-alba-medium = {
          ".onnx" = "sha256-QBNpxKgdCf3YbDLFyGRECBHb3MZkZs3i1k9xM6Zq0Ds=";
          ".onnx.json" = "sha256-qpZaLwLsztYywmlOH8crv/bWXyZfq1Z8qUWRjHPdifQ=";
        };
        en_GB-aru-medium = {
          ".onnx" = "sha256-nnTQiahWP4skRkJtAb7LBGzTw7+6/hog/QOpp5vYJhk=";
          ".onnx.json" = "sha256-AFKfq/DnnympyxD9pbYPm3z4BnH6rCsxbhOvIOeBbV4=";
        };
        en_GB-cori-high = {
          ".onnx" = "sha256-RwtN1jTJj4pIUNdib/w9/JB3Riju72YFpt2PiPMKWQM=";
          ".onnx.json" = "sha256-nn+1tWcWEsIvPIHL5Gwa6HsDGkYyvLUJ5Jna1vHirew=";
        };
        en_GB-vctk-medium = {
          ".onnx" = "sha256-Tp/IWrkAk4Uxn8a65/VVd/ii1+53/ZFZpVAOtlMfQeY=";
          ".onnx.json" = "sha256-f4XmOR7Q9/RuSr0ZNFkpoWvpMaDJlFCG+WaS3OIIf6g=";
        };
      }));
      # withTrain=false drops the torch(-rocm)+aotriton+lightning/tensorboard
      # closure; piper inference runs on onnxruntime. Re-enable only to train.
      # A later --data-dir still wins.
      piper = pkgs.writeShellScriptBin "piper" ''
        exec ${pkgs.piper-tts.override {withTrain = false;}}/bin/piper \
          --data-dir ${piperVoices} "$@"
      '';

      # Kokoro-82M weights and voices, pinned and laid out as a Hugging Face hub
      # cache so kokoro runs offline instead of downloading into ~/.cache.
      kokoroRev = "f3ff3571791e39611d31c381e3a41a3af07b4987";
      kokoroHub = pkgs.runCommand "kokoro-82m-hub" {} ''
        repo=$out/models--hexgrad--Kokoro-82M
        mkdir -p $repo/refs $repo/snapshots
        printf %s ${kokoroRev} > $repo/refs/main
        ln -s ${pkgs.fetchgit {
          url = "https://huggingface.co/hexgrad/Kokoro-82M";
          rev = kokoroRev;
          fetchLFS = true;
          hash = "sha256-eAp8MWJ9ljbfb6yV6FN+rlW3I+LeZYwKQ5v6N5zJzx0=";
        }} $repo/snapshots/${kokoroRev}
      '';
      # misaki (kokoro's G2P) needs spaCy's en_core_web_sm and otherwise tries
      # to `uv pip install` it at runtime. Expose only `kokoro`, not the env's
      # python3.
      kokoro = pkgs.writeShellScriptBin "kokoro" ''
        export HF_HUB_CACHE=${kokoroHub} HF_HUB_OFFLINE=1
        exec ${pkgs.python313.withPackages (ps: [
          ps.kokoro
          ps.spacy-models.en_core_web_sm
        ])}/bin/kokoro "$@"
      '';
    in {
      environment.systemPackages = with pkgs; [
        ## text to speech
        espeak-ng
        piper
        kokoro

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
