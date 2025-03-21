{
  pkgs,
  inputs,
  ...
}:
let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
in {
  imports = [ inputs.ucodenix.nixosModules.default ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        configurationLimit = 10;
        consoleMode = "auto";
      };
    };

    kernelPackages = pkgs.linuxPackages_latest;
    
    # plymouth = {
    #   enable = false;
    # };
    
    consoleLogLevel = 5;
    initrd.verbose = true;
    kernelParams = [
      # "quiet"
      # "splash"
      "boot.shell_on_fail"
      # "loglevel=3"
      # "rd.systemd.show_status=false"
      # "rd.udev.log_level=3"
      # "udev.log_priority=3"
      "video=3840x2160"
    ];
  };

  services.ucodenix = {
    enable = true;
    cpuModelId = "00B40F40"; # 9950x ;  Current revision: 0x0b404023
  };

  console.font = "${pkgs.kbd}/share/consolefonts/Lat2-Terminus16.psfu.gz";

  # systemd.services.greetd.serviceConfig = {
  #   Type = "idle";
  #   StandardInput = "tty";
  #   StandardOutput = "tty";
  #   # StandardError = "journal"; # Without this errors will spam on screen
  #   # Without these bootlogs will spam on screen
  #   TTYReset = true;
  #   TTYVHangup = true;
  #   TTYVTDisallocate = true;
  # };

  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreet} --time --remember --remember-session";
        };
      };
    };
  };

}
