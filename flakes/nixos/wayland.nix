{
  pkgs,
  username,
  ... 
}: {

  programs.labwc.enable = true; # lightweight wm

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gnome
      xdg-desktop-portal-cosmic
      xdg-desktop-portal-termfilechooser
      xdg-desktop-portal-xapp
      kdePackages.xdg-desktop-portal-kde
    ];
    config = {
      common = {
        default = [ "cosmic" ];
      };
      cosmic = {
       "org.freedesktop.impl.portal.Secret" = [
        "gnome-keyring"
        ];
      };
    };
  };

  # packages which are more about providing a foundational
  # window system & desktopn environment, than e.g. standalone GUI apps
  home-manager.users.${username} = {
    home.packages = with pkgs; [

      adwaita-icon-theme
      bibata-cursors
      clipman
      copyq
      clipse
      cliphist
      
      dconf
      dmenu
      flameshot
      fuzzel
      gammastep
      gnomeExtensions.appindicator
      grim
      grim
      i3status
      imv
      kando
      kanshi
      kmonad
      mako
      nemo
      phinger-cursors
      protontricks
      river
      rofi-wayland
      shotman
      showmethekey
      sirula
      slurp
      spatial-shell
      swww
      tuba
      ulauncher
      waypipe
      wbg
      wev
      wine
      winePackages.full
      winetricks
      wine-wayland
      wl-clipboard-rs
      wldash
      wlroots
      wmenu
      wob
      wofi
      wshowkeys
      wtype
      xfce.thunar
      xwayland
      zathura
      slurp
      wayland-scanner

    ];

    home.pointerCursor = {
      name = "phinger-cursors-light";
      package = pkgs.phinger-cursors;
      size = 32;
      gtk.enable = true;
      x11 = {
        enable = true;
        defaultCursor = "phinger-cursors-light";
      };
    };

    # services.copyq.enable = true;
    services.cliphist.enable = true;
  }; # home-manager
}
