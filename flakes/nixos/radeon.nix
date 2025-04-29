{ pkgs, ... }: {
  # boot.kernelModules = [ ];
  # boot.kernelParams = [ ];

  services.xserver.videoDrivers = [ "modesetting" ];

  hardware = {
    # opengl.driSupport = true;
    graphics = {
      enable = true;
      enable32Bit = true; 
      extraPackages = with pkgs; [
        mesa
        amdvlk
        rocmPackages.clr.icd
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
    
    amdgpu = {
      initrd.enable = true;
      amdvlk = {
        enable = true;
        supportExperimental.enable = true;
        support32Bit.enable = true;
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      egl-wayland
      libGL
      libglvnd
      libva-utils
      libvdpau-va-gl
      vdpauinfo
      vulkan-tools
      vulkan-validation-layers
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

  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = ["multi-user.target"];

  # # Enable the AMDGPU Control Daemon
  # systemd.services.lact = {
  #   description = "AMDGPU Control Daemon";
  #   after = [ "multi-user.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     ExecStart = "${pkgs.lact}/bin/lact daemon";
  #   };
  #   enable = true;
  # };

}
