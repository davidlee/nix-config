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
  ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gnome
      ];
    configPackages = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gnome
    ];
  };

  # packages which are more about providing a foundational
  # window system, WMs, etc, than e.g. standalone GUI apps
  home-manager.users.${username} = {
    home.packages = with pkgs; [

      adwaita-icon-theme
      bibata-cursors
      clipman
      clipse
      copyq
      dmenu
      flameshot
      fuzzel
      gammastep
      gdm
      gnomeExtensions.appindicator
      grim
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
      spatial-shell
      swww
      tuba
      # rootbar
      # somebar
      waybar
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
      dconf
      i3status
      wmenu
      wob
      wofi
      wtype
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
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
