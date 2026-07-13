{
  pkgs,
  # username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    ## text to speech
    espeak-ng
    piper-tts

    # BROKEN - transient python dep issue
    # python313Packages.kokoro

    ## speech to text — ROCm/gfx1201 build (overlays/whisper-rocm.nix)
    whisper-cpp-rocm
  ];
}
