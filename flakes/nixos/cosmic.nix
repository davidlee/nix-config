{
  pkgs,
  ...
}:
{

  environment.systemPackages = with pkgs; [

    cosmic-applets
    cosmic-applibrary
    cosmic-bg
    cosmic-comp
    cosmic-edit
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
    cosmic-tasks
    cosmic-term
    cosmic-wallpapers
    cosmic-workspaces-epoch

    gnome-system-monitor
    gnome-weather
    gnome-podcasts
    gnome-feeds
    gnome-nettool
    gnome-logs
    gnome-calendar

    swaybg
    swayimg
    sway-contrib.grimshot
  ];

  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        vivaldi-bin
        zen
        wavebox
      '';
      mode = "0755";
    };
  };

  # might fix copyq
  environment.variables = {
    COSMIC_DATA_CONTROL_ENABLED = 1;  
  };

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
    };

    sysprof.enable = true;
  };
}
