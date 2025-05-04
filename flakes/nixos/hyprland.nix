{ pkgs, username, inputs, ...} : {

  programs.hyprland.enable = true; 
  programs.hyprland.withUWSM = true;

  environment.systemPackages = with pkgs; [
    hyprlock
    hypridle
    inputs.raise.defaultPackage.${system}

  ];

  environment.sessionVariables.HYPRCURSOR_SIZE = "24";

  home-manager.users.${username} = {

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;

      plugins = [
        pkgs.hyprlandPlugins.hy3
        pkgs.hyprlandPlugins.hyprexpo
        pkgs.hyprlandPlugins.hyprbars
        pkgs.hyprlandPlugins.hyprspace
        pkgs.hyprlandPlugins.borders-plus-plus
        pkgs.hyprlandPlugins.hypr-dynamic-cursors
        pkgs.hyprlandPlugins.hyprwinwrap
      ];

      # keep this out of nix / home manager for lower friction iteration
      extraConfig = ''
      source = /home/david/.config/hypr/custom.conf
      '';

    }; # hyprland

    # https://github.com/hyprwm/hypridle
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };

        listener = [
          {
            timeout = 1200;
            on-timeout = "hyprlock";
          }
          {
            timeout = 1800;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    }; # hypridle
  }; # home manager
}
