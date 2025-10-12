{lib, ...}: {
  options = with lib; {
    # TODO actually apply these to config

    sleipnir = {
      # TODO refactor with mkEnableOption
      microcode_updates.enable = mkOption {
        type = types.bool;
        default = false;
        description = "whether to apply AMD microcode updates from upstream repos. Otherwise rey on manual BIOS updates. Requires disabling SHA verification, so use with caution.";
      };

      kmscon.enable = mkOption {
        type = types.bool;
        default = true;
        description = "whether to use kmscon to replace TTY except for the first, for icons and other eye candy.";
      };

      kmscon.autologin = mkOption {
        type = types.bool;
        default = false;
        description = "whether to automatically log in kmscon sessions. WARN obvious security implications.";
      };

      # window managers ...

      # nixarr ...
    };
  };
}
