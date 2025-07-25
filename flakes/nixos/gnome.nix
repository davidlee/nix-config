{pkgs, ...}: {
  services = {
    displayManager.gdm = {
      enable = false;
      wayland = true;
    };

    desktopManager = {
      gnome.enable = false;
    };

    # for systray icons in gnome
    udev.packages = with pkgs; [gnome-settings-daemon];
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
    # gnome-keysign # BROKEN
    gnome-logs
    gnome-menus
    gnome-nettool
    gnome-notes
    gnome-panel
    gnome-podcasts
    gnome-power-manager
    gnome-robots
    gnome-screenshot
    # gnome-secrets BROKEN
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
