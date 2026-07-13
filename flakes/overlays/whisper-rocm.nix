# whisper.cpp built for this box's GPU (RDNA4 = gfx1201). rocmSupport is
# already on globally (modules/nixos/rocm.nix), but pinning the single GPU
# target is the real win: the nixpkgs default builds every rocBLAS target
# (~30 min per the derivation's own note), gfx1201-only is minutes. Setting
# rocmSupport here too keeps the package self-describing.
_final: prev: {
  whisper-cpp-rocm = prev.whisper-cpp.override {
    rocmSupport = true;
    vulkanSupport = false;
    rocmGpuTargets = "gfx1201";
  };
}
