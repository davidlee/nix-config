{
  pkgs,
  inputs,
  lib,
  config,
  username,
  ...
}: {
  imports = [inputs.ucodenix.nixosModules.default];

  environment.systemPackages = with pkgs; [
    greetd
    tuigreet
  ];

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

    extraModulePackages = with config.boot.kernelPackages; [xpadneo];
    # TODO resolve or remove:
    # this is supposed to help fix xbox controller bluetooth connectivity
    extraModprobeConfig = ''
      options bluetooth disable_ertm=Y
    '';

    initrd = {
      kernelModules = [];
      verbose = true;
    };

    blacklistedKernelModules = [
      "ucsi_ccg"
      "vc032x"
      "gspca_vc032x"
    ];

    plymouth = {
      enable = false;
    };

    # see https://github.com/e-tho/ucodenix?tab=readme-ov-file#3-apply-changes
    kernelParams =
      if config.sleipnir.microcode_updates.enable
      then [
        "boot.shell_on_fail"
        "microcode.amd_sha_check=off"
      ]
      else [];
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
    ucodenix =
      if config.sleipnir.microcode_updates.enable
      then {
        enable = true;
        cpuModelId = "00B40F40"; # 9950x ;  Current revision: 0x0b404023
      }
      else {};

    kmscon =
      if config.sleipnir.kmscon.enable
      then {
        enable = true;
        hwRender = true;
        fonts = [
          {
            name = "JetBrainsMono Nerd Font";
            package = pkgs.nerd-fonts.jetbrains-mono;
          }
        ];
        autologinUser =
          if config.sleipnir.kmscon.autologin
          then username
          else null;
      }
      else {};

    greetd = {
      enable = true;
      settings = {
        default_session = let
          tuigreet = "${lib.getExe pkgs.tuigreet}";
          baseSessionsDir = "${config.services.displayManager.sessionData.desktops}";
          xSessions = "${baseSessionsDir}/share/xsessions";
          waylandSessions = "${baseSessionsDir}/share/wayland-sessions";
          theme = "'border=magenta;text=cyan;prompt=green;time=red;action=green;button=white;container=black;input=red'";
          tuigreetOptions = [
            "--remember"
            "--remember-session"
            "--sessions ${waylandSessions}:${xSessions}"
            "--xsession-wrapper startx /usr/bin/env"
            "--time"
            "--theme ${theme}"
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

  # for unlocking slack etc in hyprland
  security.pam.services.greetd.enableGnomeKeyring = true;
}
