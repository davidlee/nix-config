{inputs, ...}: let
  # Derive build number from the flake input ref (e.g. "b8660" -> "8660")
  lock = builtins.fromJSON (builtins.readFile ../../flake.lock);
  ref = lock.nodes.llama-cpp-src.original.ref;
  version = builtins.replaceStrings ["b"] [""] ref;

  edgeAttrs = {
    inherit version;
    src = inputs.llama-cpp-src;
    postPatch = ""; # HACK: nixpkgs postPatch assumes files that don't exist in bleeding-edge src. Remove once nixpkgs catches up.
  };
in {
  flake.overlays.llama-edge = _final: prev: {
    llama-cpp-edge-rocm =
      (prev.llama-cpp.override {
        rocmSupport = true;
        vulkanSupport = false;
      })
      .overrideAttrs (_: edgeAttrs);

    llama-cpp-edge-vulkan =
      (prev.llama-cpp.override {
        rocmSupport = false;
        vulkanSupport = true;
      })
      .overrideAttrs (_: edgeAttrs);
  };
}
