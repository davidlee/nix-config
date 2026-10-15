_: {
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

    # drop to a rescue shell when stage 1 fails
    kernelParams = ["boot.shell_on_fail"];

    # plymouth = {
    #   enable = true;
    # };
  }; # /boot
}
