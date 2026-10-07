# PrismML's llama.cpp fork: adds the ternary weight formats (PQ2_0, PTQ1_0)
# that Bonsai models need. Stock llama.cpp rejects them.
# Built on the nixpkgs recipe, swapping only the source.
{inputs, ...}: let
  # The version is the fork's release tag (e.g. "prism-b10754-2459f68").
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);
  version = lock.nodes.llama-cpp-prism-src.original.ref;
in
  _final: prev: {
    llama-cpp-prism-rocm =
      (prev.llama-cpp.override {
        rocmSupport = true;
        # RX 9070 XT (RDNA4). Building for every target takes hours.
        rocmGpuTargets = ["gfx1201"];
      })
      .overrideAttrs (_: {
        inherit version;
        src = inputs.llama-cpp-prism-src;
        # Web UI npm deps. Re-derive from the mismatch error on each bump.
        npmDepsHash = "sha256-2Q7XhaLAArmviOLdQsNbYTfdyDE5pW9lR26cRHEVl9k=";
      });
  }
