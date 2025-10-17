{...}: {
  flake.nixosModules.ai = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      cursor-cli
    ];
  };
}
# services = {
#   open-webui.enable = true; # 8080
#   ollama = {
#     enable = true;
#     # loadModels = [""];
#     acceleration = "rocm";
#     rocmOverrideGfx = "gfx1036";
#     package = pkgs.ollama-rocm;
#   };
# };
## LLM / AI
# ollama
# cursor-cli
# mods
# mistral-rs
# oterm # BROKEN
# aichat
# aider-chat-full
# llama-cpp
# vllm
# llm
# llm-ls
# ## ai
# local-ai
# lmstudio
#
# ## CLI - use npx instead for latest

