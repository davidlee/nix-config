# Text to speech. `say` renders with piper or kokoro and plays on any
# PipeWire sink; `say-test` alongside it holds that behaviour without an
# engine or speakers.
#
# Smoke:
#   say hello
#   echo hello | say -e kokoro -d <node.name from `pw-cli ls Node`>
{
  name = "speech";
  homeManager = {pkgs, ...}: {
    home.file.".local/bin/say" = {
      source = ./say;
      executable = true;
    };
    # say reads piper voice sample rates with it.
    home.packages = [pkgs.jq];
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
    # withJapanese=false drops pyopenjtalk: every pinned voice is English.
    # A later --data-dir still wins.
    piper = pkgs.writeShellScriptBin "piper" ''
      exec ${pkgs.piper-tts.override {
        withTrain = false;
        withJapanese = false;
      }}/bin/piper \
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
    # A fixed path, so say can read a voice's sample rate (to stream piper's
    # raw audio) without an environment variable reaching every shell.
    environment.etc.piper-voices.source = piperVoices;

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
