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
          configurationLimit = 7;
          consoleMode = "auto";
        };
      };

      plymouth = {
        enable = true;
      };
    }; # /boot
  };
}
