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
  hardware.graphics.enable = true;
  
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = nvidiaPackage;
  };

  hardware.graphics.extraPackages = [ pkgs.mesa ];

  environment.variables = extraEnv;
  environment.sessionVariables = extraEnv;
  environment.systemPackages = with pkgs; [
    glxinfo
    vulkan-tools
    glmark2
  ];

  services.xserver = {
    videoDrivers = [ "nvidia" ];
  };
}
