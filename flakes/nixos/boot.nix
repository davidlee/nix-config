{
  pkgs,
  inputs,
  lib,
  config,
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
    kernelModules = [
      "snd-seq"
      "snd-rawmidi"
    ];

    extraModulePackages = with config.boot.kernelPackages; [ xpadneo ];
    extraModprobeConfig = ''
      options bluetooth disable_ertm=Y
    ''; # TODO xbox controller cargo culting, doesn't seem to help bluetooth connectivity
    
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

    kmscon = {
      enable = true;
      hwRender = true;
      fonts = [ { name = "JetBrainsMono Nerd Font"; package = pkgs.nerd-fonts.jetbrains-mono; }];
      autologinUser = "david"; # WARN insecure, but if someone evil and smart enough to figure out how to change TTY on my keyboard has physical access to my machine, I'm dead alreody.
    };

    greetd = {
      enable = true;
      settings = {
        default_session = let
          tuigreet = "${lib.getExe pkgs.greetd.tuigreet}";
          baseSessionsDir = "${config.services.displayManager.sessionData.desktops}";
          xSessions = "${baseSessionsDir}/share/xsessions";
          waylandSessions = "${baseSessionsDir}/share/wayland-sessions";
          tuigreetOptions = [
            "--remember"
            "--remember-session"
            "--sessions ${waylandSessions}:${xSessions}"
            "--time"
            "--theme 'border=magenta;text=cyan;prompt=green;time=red;action=green;button=white;container=black;input=red'"
            # "--cmd sway"
          ];
          flags = lib.concatStringsSep " " tuigreetOptions;
        in {
          command = "${tuigreet} ${flags}";
          user = "greeter";
        };
      };
    };
  };
  
}
