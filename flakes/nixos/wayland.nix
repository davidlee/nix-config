{
  pkgs,
  stable,
  username,
  ...
}: {
  programs = {
    seahorse.enable = true;
    dconf.enable = true;
    gnome-disks.enable = true;
    # fix collision w/ KDE; prefer gnome's secrets manager
    ssh.askPassword = pkgs.lib.mkForce "${pkgs.seahorse.out}/libexec/seahorse/ssh-askpass";

    # labwc.enable = true;
    # river.enable = true;
    # niri.enable = true;
  };

  services = {
    # have X11 available, but not running by default
    xserver = {
      enable = true;
      displayManager = {
        startx.enable = true;
        sessionCommands = ''
          export SSH_AUTH_SOCK
        '';
      };

      desktopManager = {
        # cinnamon.enable = true;
        # mate.enable = true;
      };
    };

    gnome = {
      gnome-online-accounts.enable = true;
      gnome-keyring.enable = true;
      gnome-browser-connector.enable = true; # does this make keyring work? for electron apps like slack?
      # gcr-ssh-agent.enable = true;
    };

    sysprof.enable = true;
    blueman.enable = true;
    dbus.packages = [pkgs.gnome-keyring pkgs.gcr];
  };

  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    greetd-password.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
  };

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
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xdg-desktop-portal-hyprland
      kdePackages.xdg-desktop-portal-kde
      # xdg-desktop-portal-termfilechooser
      # xdg-desktop-portal-xapp
    ];

    config = {
      common = {
        default = ["Hyprland" "gtk" "wlr" "kde"];
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
        "org.freedesktop.impl.portal.FileChooser" = ["kde"];
      };
      kde = {
        "org.freedesktop.impl.portal.Secret" = ["kwalletd6"];
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
    # gnome-secrets BROKEN
    gnome-system-monitor
    gnome-calendar
    gnome-nettool
    gnomeExtensions.appindicator

    # compositors
    river
    niri

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
    (flameshot.override {enableWlrSupport = true;})
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

    # askme
    yad
    zenity

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
