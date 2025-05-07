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
  
  environment = {
    variables = {
      XCURSOR_SIZE = 24;
      # NIXOS_OZONE_WL = 1;
      # ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      ELECTRON_OZONE_PLATFORM_HINT = "x11";
      MOZ_ENABLE_WAYLAND = 1;
    };
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

  # # app launcher & mime type metadata
  # # https://github.com/nix-community/home-manager/blob/master/modules/misc/xdg-desktop-entries.nix
  # xdg.desktopEntries = {
  #   # "name".mimeType = [ "" ];
  #   # "Slack".settings .. icon
  #   # "Helix".terminal = true;
  # };

  # xdg.mimeApps = {
  #   enable = false;    
  #   associations = {
  #     added = {};
  #     removed = {};
  #   };
  # };

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
    wlroots
    xwayland
    dconf
    waypipe

    # util
    gammastep
    kanshi
    wtype
    wlclock
    wlock
    wlinhibit
    wleave
    wlprop
    wl-screenrec
    wl-clicker
    wl-crosshair
    wl-gammactl
    wl-gammarelay-rs
    wl-color-picker
    wl-kbptr
    wl-restart
    wl-mirror
    wlopm
    wlr-layout-ui
    gnome-secrets
    gnome-system-monitor
    gnome-calendar
    gnome-nettool
    gnomeExtensions.appindicator

    # wine
    wine
    wineWowPackages.stagingFull
    winetricks
    wine-wayland
    wine-staging

    # compositors
    river

    # notifications
    mako

    # file managers
    nemo
    xfce.thunar
    xfce.tumbler

    # themes & cursors
    phinger-cursors
    adwaita-icon-theme
    bibata-cursors
    marble-shell-theme

    # bars & widgets
    waybar
    wob
    i3status
    wttrbar
    gnome-weather

    # wallpapers
    swww
    swaybg
    wbg

    # keyboard / input
    wev
    wshowkeys
    showmethekey
    kmonad
    
    # viewers
    swayimg
    zathura
    imv
    cava
    tuba
    gnome-logs

    # screenshots
    (flameshot.override { enableWlrSupport = true; })
    grim
    shotman
    slurp
    sway-contrib.grimshot

    # img editor
    swappy

    # bluetooth
    blueman
    bluez-tools
    bluez-experimental

    # clipboard managers
    cliphist
    clipman
    clipse
    wl-clip-persist
    wl-clipboard-rs
    stable.copyq

    # launchers
    anyrun
    wofi
    wmenu
    ulauncher
    rofi-wayland
    wofi-emoji
    kando
    wofi-power-menu
    wldash
    fuzzel
    dmenu
    sirula
      
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
    # services.cliphist.enable = true;

  }; # home-manager
}
