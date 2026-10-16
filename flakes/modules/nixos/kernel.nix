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
    # Kernel modules
    #
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [
      "snd-seq"
      "snd-rawmidi"
      "snd-aloop"
    ];
  }; # /boot
}
