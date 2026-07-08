_: {
  flake.nixosModules.speech = {
    pkgs,
    # username,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      ## text to speech
      espeak-ng
      piper-tts
      python313Packages.kokoro

      ## speech to text — ROCm/gfx1201 build (overlays/whisper-rocm.nix)
      whisper-cpp-rocm
    ];
  };
}
