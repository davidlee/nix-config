{
  config,
  pkgs,
  lib,
  ...
}: {
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # apparently advised for beta nvidia drivers
    # kernelPackages = pkgs.linuxPackages_latest
    kernelPackages = pkgs.linuxPackages_6_12;
  };
}
