{
  pkgs,
  username,
  inputs,
  ...
}: let
  screen = "DP-3";
in {
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;

  security = {
    polkit.enable = true;
  };

  services = {
    gnome = {
      gnome-keyring.enable = true;
    };

    blueman.enable = true;
    sysprof.enable = true;
  };

  environment.systemPackages = with pkgs; [
    hyprlock
    hypridle
    swayosd
    waybar
    inputs.raise.defaultPackage.${system}
  ];

  environment.sessionVariables = {
    HYPRCURSOR_SIZE = "24";
    XDG_SCREENSHOTS_DIR = "/home/${username}/Pictures/Screenshots";
  };

  home-manager.users.${username} = {
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = null;
      portalPackage = null;

      plugins = [
        pkgs.hyprlandPlugins.hy3
        pkgs.hyprlandPlugins.hyprexpo
        pkgs.hyprlandPlugins.hyprspace
        # pkgs.hyprlandPlugins.hypr-dynamic-cursors
        # pkgs.hyprlandPlugins.hyprwinwrap
        # pkgs.hyprlandPlugins.hyprbars
        # pkgs.hyprlandPlugins.borders-plus-plus
      ];

      settings = {
      };
      # keep this out of nix / home manager for lower friction iteration
      extraConfig = ''
        source = /home/david/.config/hypr/custom.conf
      '';
    }; # hyprland

    services = {
      swayosd.enable = true;
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          # after_sleep_cmd = "hyprctl dispatch dpms on";
          after_sleep_cmd = "wlopm --off ${screen}";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };

        listener = [
          {
            timeout = 1200;
            on-timeout = "hyprlock";
          }
          {
            timeout = 1500;
            # on-timeout = "hyprctl dispatch dpms off";
            # on-resume = "hyprctl dispatch dpms on";
            on-timeout = "wlopm --off ${screen}";
            on-resume = "wlopm --on ${screen}";
          }
        ];
      };
    }; # hypridle
  }; # home manager
}
