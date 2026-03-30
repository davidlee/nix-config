{...}: {
  flake.nixosModules.kernel = {pkgs, ...}: {
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
        "v4l2loopback"
      ];

      kernelPatches = [
        {
          name = "Rust Support";
          patch = null;
          features = {
            rust = true;
          };
        }
      ];

      extraModulePackages = [pkgs.linuxPackages_latest.v4l2loopback];

      blacklistedKernelModules = [
        "ucsi_ccg"
        "vc032x"
        "gspca_vc032x"
      ];
    }; # /boot
  };
}
