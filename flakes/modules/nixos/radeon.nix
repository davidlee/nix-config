{...}: {
  flake.nixosModules.radeon = {pkgs, ...}: {
    services.xserver.videoDrivers = ["modesetting"];

    boot.kernelModules = ["amdgpu"];

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          mesa
          libvdpau-va-gl
          vaapiVdpau
          rocmPackages.clr.icd
        ];
        extraPackages32 = with pkgs; [
          libvdpau-va-gl
          vaapiVdpau
        ];
      };

      amdgpu = {
        initrd.enable = true;
        opencl.enable = true;
      };
    };

    environment = {
      systemPackages = with pkgs; [
        egl-wayland
        lact
        libGL
        libglvnd
        libva-utils
        libvdpau-va-gl
        vdpauinfo

        vulkan-tools
        vulkan-validation-layers
        vulkan-extension-layer
        vulkan-headers
        vulkan-helper
        vulkan-loader
        vulkan-tools
        vulkan-tools-lunarg
        vulkan-caps-viewer
        vulkan-cts

        rocmPackages.clr.icd

        glxinfo
        nvtopPackages.amd
        amd-blis
        radeontools
        radeontop
        radeon-profile
        clinfo
        wgpu-utils
        vkmark
        vkd3d
        xrgears
        glmark2
        amdgpu_top
      ];
    };

    systemd.packages = with pkgs; [lact];
    systemd.services.lactd.wantedBy = ["multi-user.target"];
  };
}
