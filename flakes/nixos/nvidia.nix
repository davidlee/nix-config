{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let

  nverStable = config.boot.kernelPackages.nvidiaPackages.stable.version;
  nverBeta = config.boot.kernelPackages.nvidiaPackages.beta.version;
  nvidiaPackage =
    if (lib.versionOlder nverBeta nverStable)
    then config.boot.kernelPackages.nvidiaPackages.stable
    else config.boot.kernelPackages.nvidiaPackages.beta;

  extraEnv = { WLR_NO_HARDWARE_CURSORS = "1"; };
  
in {

  boot.kernelModules = ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelParams = [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" ];

  # boot.blacklistedKernelModules = [ "i915" ];

  nixpkgs.config.nvidia.acceptLicense = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # nixpkgs.config = {
  #   packageOverrides = _: { inherit (pkgs) linuxPackages_latest nvidia_x11; };
  # };

  hardware = {
    graphics = {
      enable = true;
      extraPackages = [ pkgs.mesa ];
    };
    
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      forceFullCompositionPipeline = true;
      open = false;
      nvidiaSettings = true;
      package = nvidiaPackage;
    };
  };

  environment = {
    variables = extraEnv;
    sessionVariables = extraEnv;
    systemPackages = with pkgs; [
      egl-wayland
      glmark2
      glxinfo
      libGL
      libglvnd
      libva-utils
      libvdpau-va-gl
      mesa
      nvitop
      nvtopPackages.full
      vdpauinfo
      vulkan-tools
      vulkan-validation-layers
      wgpu-utils
    ];
  };

}
