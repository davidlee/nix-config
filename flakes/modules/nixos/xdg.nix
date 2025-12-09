_: {
  flake.nixosModules.xdg = {pkgs, ...}: {
    xdg.portal = {
      enable = true;

      wlr = {
        enable = true;
        # FIXME
        # settings.screencast = {
        #   output_name = "DP-3";
        #   chooser_type = "simple";
        #   chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
        #   # chooser_type = "dmenu";
        #   # chooser_cmd = "${pkgs.wofi}/bin/wofi";
        # };
      };

      xdgOpenUsePortal = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        #xdg-desktop-portal-hyprland
        xdg-desktop-portal-gnome
        #kdePackages.xdg-desktop-portal-kde
      ];

      config = {
        common = {
          default = ["wlr" "gtk" "gnome" "hyprland"];
          "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          "org.freedesktop.impl.portal.FileChooser" = ["kde"];
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
        };
        kde = {
          "org.freedesktop.impl.portal.Secret" = ["kwalletd6"];
        };
        sway = {
          default = ["gtk"];
          # wlr interfaces
          # Source: https://gitlab.archlinux.org/archlinux/packaging/packages/sway/-/commit/87acbcfcc8ea6a75e69ba7b0c976108d8e54855b
          "org.freedesktop.impl.portal.Inhibit" = "none";
        };
      };
    }; # XDG portal
  };
}
