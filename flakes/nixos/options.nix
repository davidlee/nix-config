{ lib, ... }: {

  options = with lib; {
    # TODO actually apply these to config

    sleipnir = {

      # TODO refactor with mkEnableOption
      amdvlk.enable = mkOption {
        type = types.bool;
        default = false;
        description = "whether to use amdvlk graphic drivers, which can conflict with mesa";
      };
      
      microcode_updates.enable = mkOption {
        type = types.bool;
        default = false;
        description = "whether to apply AMD microcode updates from upstream repos. Otherwise rey on manual BIOS updates. Requires disabling SHA verification, so use with caution.";
      };


      kmscon.enable = mkOption {
        type = types.bool;
        default = false;
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
