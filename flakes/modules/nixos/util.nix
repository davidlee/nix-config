{pkgs, ...}: {
  programs = {
    dconf.enable = true;
    gnome-disks.enable = true;
  };

  services = {
    # M-x dictionary
    dictd = {
      enable = true;
      DBs = with pkgs.dictdDBs; [
        # gcide # This includes the 1913 Webster's Unabridged
        wordnet # Optional: WordNet
      ];
    };
    devmon.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    sysprof.enable = true;
  };

  hardware = {
    logitech.wireless.enable = true;
    opentabletdriver.enable = true;
    i2c.enable = true;
  };
  # Required by OpenTabletDriver
  hardware.uinput.enable = true;
  boot.kernelModules = ["uinput"];
}
