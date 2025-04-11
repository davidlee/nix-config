{
  pkgs,
  inputs,
  ...
}:
{
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
    
    initrd = {
      kernelModules = [ ];
      verbose = true;
    };
    
    blacklistedKernelModules = [
      "ucsi_ccg"
      "vc032x"
    ];
    
    plymouth = {
      enable = false;
    };
    
    kernelParams = [
      "boot.shell_on_fail" # for ucodenix
      "microcode.amd_sha_check=off" 
    ];
  }; # /boot

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  console = {
    earlySetup = true;
    enable = true;
  };

  services = {
    ucodenix = {
      enable = true;
      cpuModelId = "00B40F40"; # 9950x ;  Current revision: 0x0b404023
    };

    greetd = let
      tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
    in  {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreet} --time --remember --remember-session";
        };
      };
    };
  };
  
}
