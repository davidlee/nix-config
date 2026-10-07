{inputs, ...}: {
  flake.overlays = {
    llama-prism = import ./overlays/llama-prism.nix {inherit inputs;};
    whisper-rocm = import ./overlays/whisper-rocm.nix;
    click-threading-fix = import ./overlays/click-threading-fix.nix;
    agents = import ./overlays/agents.nix {inherit inputs;};
  };
}
