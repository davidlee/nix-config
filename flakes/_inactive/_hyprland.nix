{
  pkgs,
  username,
  inputs,
  ...
}: {
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;

  services = {
    gnome = {
      gnome-keyring.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
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

      settings = {};
      # keep this out of nix / home manager for lower friction iteration
      extraConfig = ''
        source = /home/david/.config/hypr/custom.conf
      '';
    }; # hyprland

    services = {
      swayosd.enable = true;
    };
  }; # home manager
}
