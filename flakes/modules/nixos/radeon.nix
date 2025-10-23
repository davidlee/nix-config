_: {
  flake.nixosModules.radeon = {pkgs, ...}: {
    services.xserver.videoDrivers = ["modesetting"];

    boot.kernelModules = ["amdgpu"];

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          rocmPackages.clr.icd
        ];
      };

      amdgpu = {
        opencl.enable = true;
      };
    };

    environment = {
      systemPackages = with pkgs; [
        ## rocm CLR
        clinfo
        rocmPackages.clr.icd
        rocmPackages.rocminfo
        # rocmPackages.opt-rocm

        ## overclocky
        lact

        ## tools
        radeon-profile
        vulkan-tools

        ## info
        wgpu-utils
      ];
    };

    # create a linked path for rocm libraries that might be hardcoded in
    # various libraries and packages
    systemd.tmpfiles.rules = let
      rocmEnv = pkgs.symlinkJoin {
        name = "opt-rocm";
        paths = with pkgs.rocmPackages; [
          rocblas
          hipblas
          clr
        ];
      };
    in [
      "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
    ];

    systemd.packages = with pkgs; [lact];
    systemd.services.lactd.wantedBy = ["multi-user.target"];
  };
}
