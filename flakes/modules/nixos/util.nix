_: {
  services = {
    udisks2.enable = true;
    sysprof.enable = true;
  };

  hardware = {
    logitech.wireless.enable = true;
    opentabletdriver.enable = true;
  };
  # Required by OpenTabletDriver
  hardware.uinput.enable = true;
  boot.kernelModules = ["uinput"];
}
