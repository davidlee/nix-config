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
  lib,
  pkgs,
  ...
}: let
  # sherpa-onnx's int8 export. The chunk size is baked into the export: 320ms
  # is about a third of a second from speech to text, at ~1/4 of one core.
  # Other sizes (80, 160, 560, 1120ms) trade latency for accuracy.
  model = pkgs.fetchzip {
    name = "nemotron-3.5-asr-streaming-0.6b-320ms-int8";
    url = "https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-nemotron-3.5-asr-streaming-0.6b-320ms-int8-2026-06-11.tar.bz2";
    hash = "sha256-K4fpLuFQbDLbtGCJk2ya8EKHIo26htKSGSdgknloU1o=";
  };
  python = pkgs.python3.withPackages (p: [p.sherpa-onnx p.numpy]);
in {
  # A plain script in ~/.local/bin, as snooze-nag is. `dictate toggle` needs
  # only the standard library, so any python3 will run it from a keybind.
  home.file.".local/bin/dictate" = {
    source = ./bin/dictate;
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
      ExecStart = "${python}/bin/python3 %h/.local/bin/dictate";
      Environment = [
        "DICTATE_MODEL=${model}"
        "DICTATE_LANG=en"
        "PATH=${lib.makeBinPath [pkgs.wtype pkgs.pipewire pkgs.libnotify]}"
      ];
      Restart = "on-failure";
    };
  };
}
