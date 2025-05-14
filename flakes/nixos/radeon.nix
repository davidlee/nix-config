{ pkgs, ... }: {
  # boot.kernelModules = [ ];
  # boot.kernelParams = [ ];

  services.xserver.videoDrivers = [ "modesetting" ];

  boot.kernelModules = [ "amdgpu" ];

  hardware = {
    # opengl.driSupport = true;
    graphics = {
      enable = true;
      enable32Bit = true; 
      extraPackages = with pkgs; [
        mesa
        # amdvlk
        libvdpau-va-gl
        vaapiVdpau
        rocmPackages.clr.icd
      ];
      extraPackages32 = with pkgs; [
        libvdpau-va-gl
        vaapiVdpau
        # driversi686Linux.amdvlk
      ];
    };
    
    amdgpu = {
      initrd.enable = true;
      amdvlk = {
        enable = false;
        supportExperimental.enable = true;
        support32Bit.enable = true;
      };
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
      vulkan-hdr-layer-kwin6
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

  systemd.tmpfiles.rules = 
  let
    rocmEnv = pkgs.symlinkJoin {
      name = "rocm-combined";
      paths = with pkgs.rocmPackages; [
        rocblas
        hipblas
        clr
      ];
    };
  in [
    "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  ];
  
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = ["multi-user.target"];
}
