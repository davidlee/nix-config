{inputs, ...}: {
  flake.overlays = {
    llama-edge = import ./overlays/llama-edge.nix {inherit inputs;};
    whisper-rocm = import ./overlays/whisper-rocm.nix;
    click-threading-fix = import ./overlays/click-threading-fix.nix;
  };
}
