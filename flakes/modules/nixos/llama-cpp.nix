_: {
  flake.nixosModules.llama-cpp = {pkgs, ...}: {
    services = {
      llama-cpp = {
        package = pkgs.llama-cpp-rocm;
        host = "127.0.0.1";
        port = 8080;

        modelsPreset = {
          "*" = {
            jinja = "true";
            c = "8192";
            flash-attn = "on";
            n-gpu-layers = "all";
            parallel = "1";
            batch-size = "1024";
            ubatch-size = "512";
          };

          "qwen-coder-14b" = {
            model = "/srv/models/qwen2.5-coder-14b-instruct-q4_k_m.gguf";
            alias = "qwen-coder-14b";
          };
        };
      };
    };
  };
}
