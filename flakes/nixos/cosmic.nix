{
  # config,
  pkgs,
  # username,
  # lib,
  ...
}:
{

  environment.systemPackages = with pkgs; [
    cosmic-settings
    cosmic-files
    cosmic-comp
    cosmic-ext-tweaks
    cosmic-edit
    cosmic-applets
    cosmic-bg
    cosmic-icons
    cosmic-idle
    cosmic-term
    cosmic-tasks
    cosmic-settings
    cosmic-session
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
}
