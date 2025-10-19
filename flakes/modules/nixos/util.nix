_: {
  flake.nixosModules.util = {pkgs, ...}: {
    programs = {
      dconf.enable = true;
      gnome-disks.enable = true;
    };

    services = {
      devmon.enable = true;
      gvfs.enable = true;
      udisks2.enable = true;
      sysprof.enable = true;
      printing.enable = true;
    };

    hardware = {
      logitech.wireless.enable = true;
      opentabletdriver.enable = true;
      i2c.enable = true;
    };
  };
}
