{pkgs, username, lib, config, ... }: {
  
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      gnomeExtensions.appindicator
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
