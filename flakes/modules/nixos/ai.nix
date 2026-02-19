_: {
  flake.nixosModules.ai = {pkgs, ...}: {
    nixpkgs.config.rocmSupport = true;

    environment.systemPackages = with pkgs; [
      # llama-cpp-rocm

      # broken af, let's use distrobox + archlinux for this shit
      # vllm
    ];
  };
}
