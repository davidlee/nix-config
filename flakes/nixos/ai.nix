{pkgs, ...}: {
  services = {
    open-webui.enable = true; # 8080
    ollama = {
      enable = true;
      # loadModels = [""];
      acceleration = "rocm";
      rocmOverrideGfx = "gfx1036";
      package = pkgs.ollama-rocm;
    };
  };
  environment.systemPackages = with pkgs; [
    ## LLM / AI
    ollama
    cursor-cli
    # mods
    # mistral-rs
    # oterm # BROKEN
    # aichat
    # aider-chat-full
    # llama-cpp
    vllm
    # llm
    # llm-ls

    # ## ai
    # local-ai
    # lmstudio
    #
    # ## CLI - use npx instead for latest
  ];
}
