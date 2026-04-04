# {pkgs, ...}:
# {
#   services.llama-cpp = {
#     enable = true;
#
#     package = pkgs.llama-cpp-edge-rocm;
#
#     host = "127.0.0.1";
#     port = 8013;
#     openFirewall = false;
#
#     model = "/srv/models/gpt-oss-20b-mxfp4.gguf";
#
#     extraFlags = [
#       "--alias"
#       "gpt-oss-20b"
#       "--ctx-size"
#       "32768"
#       "--flash-attn"
#       "--n-gpu-layers"
#       "999"
#     ];
#   };
# }
_: {
  flake.nixosModules.llama-cpp = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.llama-cpp-edge-rocm
    ];

    # services = {
    #   llama-cpp = {
    #     # package = pkgs.llama-cpp-rocm;
    #     package = pkgs.llama-cpp-edge-rocm;
    #     host = "127.0.0.1";
    #     port = 8080;
    #
    #     modelsPreset = {
    #       "*" = {
    #         jinja = "true";
    #         c = "8192";
    #         flash-attn = "on";
    #         n-gpu-layers = "all";
    #         parallel = "1";
    #         batch-size = "1024";
    #         ubatch-size = "512";
    #       };
    #       model = "/srv/models/qwen2.5-coder-14b-instruct-q5_k_m.gguf";
    #       "qwen-coder-14b" = {
    #         model = "/srv/models/qwen2.5-coder-14b-instruct-q4_k_m.gguf";
    #         alias = "qwen-coder-14b";
    #       };
    #     };
    #   };
    # };
  };
}
