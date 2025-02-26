{
  inputs,
  pkgs,
  ...
}: let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
in {

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

  services = {
    xserver = {
      enable = true;
      displayManager = {
        gdm = {
          # enable = true;
          wayland = true;
        };
      };
      desktopManager = {
        gnome = {
          enable = true;
        };
      };
    };

    desktopManager = {
      cosmic = {
        enable = true;
      };
    };
    
    displayManager = {
      cosmic-greeter = {
        enable = true;
      };
    };
    
    gnome = {
      evolution-data-server.enable = true;
      gnome-settings-daemon.enable = true;
      gnome-keyring.enable = true;
      gnome-browser-connector.enable = true;
      gnome-online-accounts.enable = true;
    };

    # for systray icons in gnome
    udev.packages = with pkgs; [ gnome-settings-daemon ];

    # conflicts with Cosmic greeter
    # 
    # greetd = {
    #   enable = true;
    #   settings = {
    #     default_session = {
    #       command = "${tuigreet} --time --remember --remember-session";
    #     };
    #   };
    # };
      

    kmonad.enable = true;
    espanso.enable = true;
    devmon.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;

    sysprof.enable = true;

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        X11Forwarding = false;
        PermitRootLogin = "prohibit-password";
        UseDns = true;
      };
    };

    printing.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    locate = {
      enable = true;
      package = pkgs.plocate;
      interval = "hourly";
    };

    # proxmox-ve = {
    #   enable = true; 
    #   ipAddress = "";
    # }
  };
}
