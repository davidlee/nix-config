{...}: {
  flake.nixosModules.wayland = {
    pkgs,
    username,
    ...
  }: {
    programs = {
      dconf.enable = true;
      gnome-disks.enable = true;
    };

    services = {
      blueman.enable = true;
      sysprof.enable = true;

      dbus.packages = [pkgs.gcr];
    }; # services

    ## Env
    environment = {
      variables = {
        XCURSOR_SIZE = 24;
        ELECTRON_OZONE_PLATFORM_HINT = "x11";
        MOZ_ENABLE_WAYLAND = 1;
        GTK_USE_PORTAL = 1;

        ## try for zoom:
        XDG_SESSION_TYPE = "wayland";
        XDG_SESSION_DESKTOP = "sway";
        XDG_CURRENT_DESKTOP = "sway";
        QT_QPA_PLATFORM = "wayland";
        SDL_VIDEODRIVER = "wayland";
        # _JAVA_AWT_WM_NONREPARENTING = 1;
        # GTK_IM_MODULE = "wayland";
        # QT_IM_MODULE = "wayland";
        # XMODIFIERS = "@im=wayland";
      };
    };
  };
}
