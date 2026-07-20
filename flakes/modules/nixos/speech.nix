{
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
}
