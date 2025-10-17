{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-cosmic.nixosModules.default
  ];

  xdg.portal = {
    extraPortals = with pkgs; [
      xdg-desktop-portal-cosmic
    ];
    config = {
      common = {
        default = ["cosmic"];
      };
      cosmic = {
        "org.freedesktop.impl.portal.Secret" = [
          "gnome-keyring"
        ];
      };
    };
  };

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
  ];

  # fix clipboard, but bad for security?
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
