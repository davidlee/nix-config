{pkgs, ... }: {
  programs = {
    dconf.enable = true;
    gnome-disks.enable = true;
    
    # fix collision w/ KDE; prefer gnome's secrets manager
    ssh.askPassword = pkgs.lib.mkForce "${pkgs.seahorse.out}/libexec/seahorse/ssh-askpass";
  };

  services = {
    xserver = {
      enable = true;
      displayManager = {
        gdm = {
          wayland = true;
          enable = false;  # greetd please
        };
      };
      desktopManager = {
        gnome = {
          enable = true; # TODO try remove to dedup entries in greetd list
        };
      };
    };

    gnome = {
      gnome-keyring.enable = true;
      # evolution-data-server.enable = true;
      # gnome-settings-daemon.enable = true;
      # gnome-browser-connector.enable = true;
      # gnome-online-accounts.enable = true;
    };

    # for systray icons in gnome
    # udev.packages = with pkgs; [ gnome-settings-daemon ];
  };

  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnome-applets
    gnome-bluetooth
    gnome-browser-connector
    gnome-builder
    gnome-calendar
    gnome-characters
    gnome-chess
    gnome-commander
    gnome-common
    gnome-connections
    gnome-contacts
    gnome-control-center
    gnome-desktop
    gnome-disk-utility
    gnome-doc-utils
    gnome-extension-manager
    gnome-feeds
    gnome-firmware
    gnome-font-viewer
    gnome-graphs
    gnome-icon-theme
    gnome-keyring
    gnome-keysign
    gnome-logs
    gnome-menus
    gnome-nettool
    gnome-notes
    gnome-panel
    gnome-podcasts
    gnome-power-manager
    gnome-robots
    gnome-screenshot
    gnome-secrets
    gnome-session
    gnome-session-ctl
    gnome-settings-daemon
    gnome-shell
    gnome-shell-extensions
    gnome-solanum
    gnome-system-monitor
    gnome-text-editor
    gnome-tweaks
    gnome-usage
    gnome-user-docs
    gnome-weather
    gnome-tweaks
    marble-shell-theme
    adwaita-icon-theme
  ];
}
