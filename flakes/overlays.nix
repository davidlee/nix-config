{inputs, ...}: {
  flake.overlays = {
    llama-prism = import ./overlays/llama-prism.nix {inherit inputs;};
    whisper-rocm = import ./overlays/whisper-rocm.nix;
  };
}
