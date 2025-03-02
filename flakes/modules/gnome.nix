{pkgs, username, lib, config, ... }: {
  
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      gnomeExtensions.appindicator

    gnome-shell
    gnome-logs
    gnome-usage
    gnome-panel
    gnome-notes
    gnome-menus
    gnome-feeds
    gnome-chess
    gnome-tweaks
    gnome-robots
    gnome-graphs
    gnome-common
    gnome-weather
    gnome-session
    gnome-secrets
    gnome-keysign
    gnome-keyring
    gnome-desktop
    gnome-builder
    gnome-applets
    gnome-podcasts
    gnome-firmware
    gnome-contacts
    gnome-calendar
    gnome-gnome-user-docs
    gnome-commander
    gnome-doc-utils
    gnome-bluetooth
    gnome-screenshot
    gnome-solanum
    gnome-icon-theme
    gnome-characters
    gnome-text-editor
    gnome-session-ctl
    gnome-font-viewer
    gnome-connections
    gnome-disk-utility
    gnome-power-manager
    gnome-system-monitor
    gnome-control-center
    gnome-shell-extensions
    gnome-settings-daemon
    gnome-extension-manager
    gnome-browser-connectorp 
    gnome-nettool

    adwaita-icon-theme
    ];
  };

  programs = {
    dconf.enable = true;
    gnome-terminal.enable = true;
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
      evolution-data-server.enable = true;
      gnome-settings-daemon.enable = true;
      gnome-keyring.enable = true;
      gnome-browser-connector.enable = true;
      gnome-online-accounts.enable = true;
    };
    # for systray icons in gnome
    udev.packages = with pkgs; [ gnome-settings-daemon ];

    sysprof.enable = true;
  };

}
