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
