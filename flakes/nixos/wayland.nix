{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gnome
    # kdePackages.xdg-desktop-portal-kde
    xdg-desktop-portal-cosmic
  ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gnome
    # kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-cosmic
    ];
    # TODO .config 
  };

  # packages which are more about providing a foundational
  # window system, WMs, etc, than e.g. standalone GUI apps
  home-manager.users.${username} = {
    home.packages = with pkgs; [

      adwaita-icon-theme
      bibata-cursors
      clipman
      copyq
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

    services.copyq.enable = true;
  }; # home-manager
}
