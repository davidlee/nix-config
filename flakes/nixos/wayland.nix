{
  pkgs,
  username,
  ... 
}: {

  # programs.labwc.enable = true; # lightweight wm
  
  programs = {
    dconf.enable = true;
    gnome-disks.enable = true;
  };
  
  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings.screencast = {
        output_name = "DP-2";
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      };
    };
    # xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gnome
      xdg-desktop-portal-termfilechooser
      xdg-desktop-portal-xapp
      kdePackages.xdg-desktop-portal-kde
    ];
    config = {
      common = {
        default  = [ "wlr" "gtk" "kde" "xapp" "termfilechooser" ];
       "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      kde = {
       "org.freedesktop.impl.portal.Secret" = [ "kwalletd6" ];
      };
      sway = {
       "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
    };
  };

  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        vivaldi-bin
        zen
        wavebox
      '';
      mode = "0755";
    };
  };

  environment.systemPackages = with pkgs; [
    dconf
    kando
    kanshi
    wl-clipboard-rs
    wldash
    wlroots
    xwayland
    gnome-secrets
    gnome-system-monitor
    blueman
    bluez-tools
    mako
  ];

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
      river
      dmenu
      flameshot
      fuzzel
      gammastep
      gnomeExtensions.appindicator
      grim
      i3status
      imv
      kmonad
      nemo
      phinger-cursors
      protontricks
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
      wmenu
      wob
      wofi
      wshowkeys
      wtype
      xfce.thunar
      zathura
      slurp
      adwaita-icon-theme
      marble-shell-theme
      swaybg
      swayimg
      sway-contrib.grimshot
      gnome-weather
      gnome-nettool
      gnome-logs
      gnome-calendar
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
