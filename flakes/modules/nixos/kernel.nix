{pkgs, ...}: {
  boot = {
    #
    # initrd
    #
    initrd = {
      kernelModules = [];
      verbose = true;
    };

    #
    # Kernel
    #
    kernelPackages = pkgs.linuxPackages_latest;
  }; # /boot
}
