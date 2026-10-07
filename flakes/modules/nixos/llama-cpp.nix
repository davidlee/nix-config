# llama.cpp server in router mode, serving Bonsai 2 27B on the GPU via ROCm.
# Router mode loads models on demand from a preset file; pi's llama.cpp
# provider requires it. Model files are downloaded by hand into /srv/models
# (see README).
{
  lib,
  pkgs,
  ...
}: let
  package = pkgs.llama-cpp-prism-rocm;

  # Keys are llama-server flags without dashes. Command-line flags override
  # these, so anything a model might change lives here, not in `settings`.
  presets = {
    globalSection.version = 1;
    sections = {
      # Defaults for every model.
      "*" = {
        jinja = true;
        flash-attn = "on";
        n-gpu-layers = 99;
        # Single user: one slot, and a prompt cache big enough to stop
        # re-processing long conversations.
        parallel = 1;
        cache-ram = 24576;
      };

      bonsai-2-27b = {
        model = "/srv/models/Ternary-Bonsai-2-27B-PQ2_0.gguf";
        load-on-startup = true;
        # 128k. Only ~1/4 of layers (full attention) keep a KV cache;
        # q8_0 halves it. Avoid q5_0: several times slower (KNOWN_ISSUES).
        ctx-size = 131072;
        cache-type-k = "q8_0";
        cache-type-v = "q8_0";
        # Hybrid attention can only rewind the cache to a checkpoint. The
        # default 8192-token spacing re-processes up to 8k tokens whenever an
        # agent rewrites recent history.
        checkpoint-min-step = 1024;
        # Model card, thinking mode.
        temp = 1.0;
        top-p = 0.95;
        top-k = 20;
        min-p = 0.05;
      };
    };
  };
in {
  environment.systemPackages = [package]; # llama-cli, llama-bench, etc.

  systemd.tmpfiles.rules = ["d /srv/models 0755 david users -"];

  services.llama-cpp = {
    enable = true;
    inherit package;
    settings = {
      host = "127.0.0.1";
      port = 8080;
      models-preset = pkgs.writeText "llama-models.ini" (lib.generators.toINIWithGlobalSection {} presets);
      models-max = 1; # 16 GB of VRAM holds one model
    };
  };
}
