{
  pkgs,
  username,
  ...
}: {

  # packages which are more about providing a foundational
  # window system, WMs, etc, than e.g. standalone GUI apps
  home-manager.users.${username} = {
    home.packages = with pkgs; [

      adwaita-icon-theme
      bibata-cursors
      clipman
      clipse
      copyq
      discord
      dmenu
      # dwl
      # dwlb
      espanso-wayland
      flameshot
      fuzzel
      gamehub
      gammastep
      gdm
      gnomeExtensions.appindicator
      grim
      imv
      kanshi
      kmonad
      limo    
      lutris
      nemo
      protontricks
      # river
      rootbar
      shotman
      showmethekey
      signal-desktop
      sirula
      spatial-shell
      tuba
      waybar
      waypipe
      wev
      wine
      winePackages.full
      winetricks
      wine-wayland
      wl-clipboard-rs
      wldash
      wlroots
      wmenu
      wofi
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
  };

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
    # xdg-desktop-portal-cosmic
    xdg-desktop-portal
  ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      # xdg-desktop-portal-cosmic
      xdg-desktop-portal
      ];
    configPackages = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      # xdg-desktop-portal-cosmic
      xdg-desktop-portal
    ];
  };
}
