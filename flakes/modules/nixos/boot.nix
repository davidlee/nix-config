{inputs, ...}: {
  flake.nixosModules.boot = {pkgs, ...}: {
    boot = {
      #
      # loader
      #
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;

        systemd-boot = {
          configurationLimit = 10;
          consoleMode = "auto";
        };
      };

      plymouth = {
        enable = true;
      };

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
