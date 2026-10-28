{pkgs, ...}: {
  boot = {
    #
    # initrd
    #
    initrd = {
      kernelModules = [];
    };

    #
    # Kernel
    #
    kernelPackages = pkgs.linuxPackages_latest;
  }; # /boot
}
