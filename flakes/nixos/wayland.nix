{
  pkgs,
  stable,
  username,
  ... 
}: {

  programs.labwc.enable = true;
  
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
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gnome
      xdg-desktop-portal-termfilechooser
      xdg-desktop-portal-hyprland
      # xdg-desktop-portal-xdg-desktop-portal-xapp
      kdePackages.xdg-desktop-portal-kde
    ];
    config = {
      common = {
        default  = [ "wlr" "gtk" "termfilechooser" ];
       "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      kde = {
       "org.freedesktop.impl.portal.Secret" = [ "kwalletd6" ];
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

  # these are about providing a useful common foundation
  environment.systemPackages = with pkgs; [
    wayland-protocols
    wayland-utils
    wayland-logout
    wayland-pipewire-idle-inhibit
    wl-clipboard-rs
    wl-screenrec
    wl-clicker
    wl-crosshair
    wl-clip-persist
    wl-gammactl
    wl-gammarelay-rs
    wl-color-picker
    wl-kbptr
    wl-restart
    wl-mirror
    wlr-layout-ui
    wlclock
    wlock
    wldash
    wlinhibit
    wleave
    wlprop
    wlroots
    xwayland
    wine
    wineWowPackages.stagingFull
    winetricks
    wine-wayland
    wine-staging
    wofi-emoji
    wofi-power-menu
    dconf
    kando
    kanshi
    gnome-secrets
    gnome-system-monitor
    blueman
    bluez-tools
    bluez-experimental
    mako
    adwaita-icon-theme
    bibata-cursors
    cava
    cliphist
    clipman
    clipse
    dmenu
    flameshot
    fuzzel
    gammastep
    gnome-calendar
    gnomeExtensions.appindicator
    gnome-logs
    gnome-nettool
    gnome-weather
    grim
    i3status
    imv
    kmonad
    marble-shell-theme
    nemo
    phinger-cursors
    river
    rofi-wayland
    shotman
    showmethekey
    sirula
    slurp
    spatial-shell
    stable.copyq
    swaybg
    sway-contrib.grimshot
    swayimg
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
    wttrbar
    wtype
    xfce.thunar
    xfce.tumbler
    zathura
      
    ## libs
    libxkbcommon
    directx-headers
    vulkan-headers
    vulkan-loader
    vulkan-tools
    libGL.dev
    xorg.libX11
    xorg.libX11.dev
    xorg.libXcursor
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    libnotify
  ];

  home-manager.users.${username} = {
  
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
