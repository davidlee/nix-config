# Hardware features, in projection order. Shape: README § Feature tree.
[
  {
    name = "openrgb";
    nixos = {pkgs, ...}: {
      services = {
        hardware.openrgb.enable = true;
        udev.packages = [pkgs.openrgb-with-all-plugins];
      };
    };
  }
]
