{ pkgs, username, ...} : {

  programs.hyprland.enable = true; 
  programs.hyprland.withUWSM = true;

  environment.systemPackages = [
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

      extraConfig = ''
      source = /home/david/.config/hypr/custom.conf
      '';
    };
  };
}
