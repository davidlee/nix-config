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
          enable = true;
          wayland = true;
        };
      };
      desktopManager = {
        gnome = {
          enable = true;
        };
      };
    };

    gnome = {
      gnome-settings-daemon.enable = true;
      gnome-keyring.enable = true;
      gnome-browser-connector.enable = true;
      gnome-online-accounts.enable = true;
    };

    greetd = {
      enable = false; # let gdm run
      settings = {
        default_session = {
          command = "${tuigreet} --time --remember --remember-session";
        };
      };
    };
      
    kmonad.enable = true;

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

  };
}
