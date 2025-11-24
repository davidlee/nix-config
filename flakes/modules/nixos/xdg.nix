_: {
  flake.nixosModules.xdg = {pkgs, ...}: {
    xdg.portal = {
      enable = true;

      wlr = {
        enable = true;
        # FIXME
        settings.screencast = {
          output_name = "DP-3";
          chooser_type = "simple";
          chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
          # chooser_type = "dmenu";
          # chooser_cmd = "${pkgs.wofi}/bin/wofi";
        };
      };

      xdgOpenUsePortal = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gnome
        kdePackages.xdg-desktop-portal-kde
      ];

      config = {
        common = {
          default = ["wlr" "gtk" "gnome" "hyprland"];
          "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          "org.freedesktop.impl.portal.FileChooser" = ["kde"];
        };
        kde = {
          "org.freedesktop.impl.portal.Secret" = ["kwalletd6"];
        };
      };
    }; # XDG portal
  };
}
