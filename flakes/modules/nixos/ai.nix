_: {
  flake.nixosModules.ai = {pkgs, ...}: {
    nixpkgs.config.rocmSupport = true;

    #
    # Create a wrapper for the llama.cpp server
    environment.systemPackages = with pkgs; [
      llama-cpp-rocm
      (
        let
          # Define the correct environment for our main GPU
          llama-cpp-server-wrapper = writeShellScriptBin "llama-cpp-server" ''
            #!${stdenv.shell}
            export HSA_OVERRIDE_GFX_VERSION=10.0.0
            export ROCR_VISIBLE_DEVICES=0
            export HIP_VISIBLE_DEVICES=0

            # Now execute the actual server, passing along all arguments
            exec ${llama-cpp-rocm}/bin/server "$@"
          '';
        in
          llama-cpp-server-wrapper
      )
      # Include the original package so all other binaries are still available
      llama-cpp-rocm
    ];

    #
    # ollama can suck a bag of dicks - this
    # hits the GPU but never delivers
    #
    # services.ollama = {
    #   loadModels = [
    #     "qwen3:14b"
    #     #"nomic-embed-text"
    #   ];
    #   enable = true;
    #   acceleration = "rocm";
    #   rocmOverrideGfx = "12.0.1";
    # };
    # users.users.ollama.extraGroups = ["render" "video"];
    # users.users.ollama.group = "ollama";
    # users.users.ollama.isSystemUser = true;
    # users.groups.ollama = {};
    # systemd.services.ollama.serviceConfig.Environment = [
    #   "ROCR_VISIBLE_DEVICES=0"
    #   "HIP_VISIBLE_DEVICES=0"
    #   # "HSA_OVERRIDE_GFX_VERSION=12.0.1"
    # ];
  };
}
