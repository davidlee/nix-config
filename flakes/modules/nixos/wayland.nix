_: {
  flake.nixosModules.wayland = {
    pkgs,
    username,
    ...
  }: {
    ## Env
    environment = {
      # globals set on init
      variables = {
        XCURSOR_SIZE = 24;
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        MOZ_ENABLE_WAYLAND = 1;
        GTK_USE_PORTAL = 1;

        ## try for zoom:
        XDG_SESSION_TYPE = "wayland";
        XDG_SESSION_DESKTOP = "sway";
        XDG_CURRENT_DESKTOP = "sway";
        SDL_VIDEODRIVER = "wayland";
      };

      # initialized through PAM
      sessionVariables = {
        # HYPRCURSOR_SIZE = "24";
        XDG_SCREENSHOTS_DIR = "/home/${username}/Pictures/Screenshots";
      };
    };
  };
}
