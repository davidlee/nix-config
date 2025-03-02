{
  config,
  pkgs,
  lib,
  ...
}: {
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 10;
      systemd-boot.consoleMode = "max";
    };

    # apparently advised for beta nvidia drivers
    kernelPackages = pkgs.linuxPackages_latest;
    # kernelPackages = pkgs.linuxPackages_6_12;
    
    plymouth = {
      enable = true;
      # theme = "rings";
      # themePackages = with pkgs; [
          
      # ];
    };
    
    # silencio
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    
    # loader.timeout = 0;  
  };

  
}
