{
  # config,
  pkgs,
  username,
  # lib,
  ...
}:
{

  environment.systemPackages = with pkgs; [

    cosmic-applets
    cosmic-applibrary
    cosmic-bg
    cosmic-comp
    cosmic-edit
    # cosmic-ext-calculator
    cosmic-ext-ctl
    cosmic-ext-tweaks
    cosmic-files
    cosmic-greeter
    cosmic-icons
    cosmic-idle
    cosmic-launcher
    cosmic-notifications
    cosmic-osd
    cosmic-panel
    cosmic-protocols
    cosmic-randr
    cosmic-screenshot
    cosmic-session
    cosmic-settings
    # cosmic-store
    cosmic-tasks
    cosmic-term
    cosmic-wallpapers
    cosmic-workspaces-epoch

  ];

  programs = {
    dconf.enable = true;
    gnome-disks.enable = true;

  };

  services = {
    desktopManager = {
      cosmic = {
        enable = true;
      };
    };
    gnome = {
      gnome-online-accounts.enable = true;
      gnome-keyring.enable = true;
      # gnome-settings-daemon.enable = true;
      # evolution-data-server.enable = true;
      # gnome-browser-connector.enable = true;
    };

    # for systray icons
    # udev.packages = with pkgs; [ gnome-settings-daemon ];

    sysprof.enable = true;
    # displayManager.cosmic-greeter.enable = true;
  };

  home-manager.users.${username} = {
    programs = {
      walker = {
        enable = true;
        runAsService = true;
      };
    };
  };
}
