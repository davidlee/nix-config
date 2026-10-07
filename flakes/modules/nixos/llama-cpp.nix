# llama.cpp server, serving Bonsai 2 27B on the GPU via ROCm.
# Model files are downloaded by hand into /srv/models (see README).
{pkgs, ...}: let
  package = pkgs.llama-cpp-prism-rocm;
in {
  environment.systemPackages = [package]; # llama-cli, llama-bench, etc.

  systemd.tmpfiles.rules = ["d /srv/models 0755 david users -"];

  services.llama-cpp = {
    enable = true;
    inherit package;
    settings = {
      host = "127.0.0.1";
      port = 8080;

      model = "/srv/models/Ternary-Bonsai-2-27B-PQ2_0.gguf";
      alias = "bonsai-2-27b";
      jinja = true;
      ctx-size = 65536; # room for the thinking trace
      flash-attn = "on";
      n-gpu-layers = 99;
      # Single user: one slot, and a prompt cache big enough to stop
      # re-processing long conversations.
      parallel = 1;
      cache-ram = 24576;

      # Model card, thinking mode.
      temp = 1.0;
      top-p = 0.95;
      top-k = 20;
      min-p = 0.05;
    };
  };
}
