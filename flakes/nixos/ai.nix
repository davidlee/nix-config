{pkgs, ...}: {
  services = {
    ollama = {
      enable = true;
      acceleration = "rocm";
      rocmOverrideGfx = "10.3.0";
      package = pkgs.ollama-rocm;
    };
  };
  environment.systemPackages = with pkgs; [
    ## LLM / AI
    # ollama
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
    # vllm
    #
    # ## CLI - use npx instead for latest
    # gpt-cli
    # claude-code
  ];
}
