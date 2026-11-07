In the pinned nixpkgs, `whisper-cpp` builds against the ggml backend that
`llama-cpp` provides and passes `rocmSupport` through to it. It no longer
takes `rocmGpuTargets`: `whisper-cpp.override { rocmGpuTargets = …; }`
fails evaluation with "called with unexpected argument 'rocmGpuTargets'".

Pin the GPU targets on the llama-cpp input instead:

    prev.whisper-cpp.override {
      rocmSupport = true;
      vulkanSupport = false;
      llama-cpp = prev.llama-cpp.override { rocmGpuTargets = ["gfx1201"]; };
    }

Check it took: the whisper-cpp drv's llama-cpp input names gfx1201.
Sleipnir selects `audio.speech`, so its own evaluation covers this path.
Found by RV-013 F-1, fixed in SL-006 PHASE-03.
