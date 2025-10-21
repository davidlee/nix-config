{inputs, ...}: {
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

      # extraModulePackages = with config.boot.kernelPackages; [xpadneo];

      blacklistedKernelModules = [
        "ucsi_ccg"
        "vc032x"
        "gspca_vc032x"
      ];
    }; # /boot
  };
}
