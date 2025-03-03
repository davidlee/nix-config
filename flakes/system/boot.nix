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
      systemd-boot.consoleMode = "auto";
    };

    kernelPackages = pkgs.linuxPackages_latest;
    
    plymouth = {
      enable = true;
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
      "video=3840x2160@59.98"
    ];
  };

  services = {
    kmscon = {
      enable = true;
      fonts = [ { name = "Source Code Pro"; package = pkgs.source-code-pro; } ];
      # hwRender = true;
    };
  };
}
