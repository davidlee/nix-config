_: {
  flake.nixosModules.openrgb = {pkgs, ...}: {
    services = {
      hardware.openrgb.enable = true;
      udev.packages = [pkgs.openrgb-with-all-plugins];
    };
  };
}
