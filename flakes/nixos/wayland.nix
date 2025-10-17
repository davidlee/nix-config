{
  pkgs,
  stable,
  username,
  ...
}: {
  security = {
    polkit.enable = true;
    pam.services = {
      greedt = {
        enableGnomeKeyring = true;
      };
      greetd-password = {
        enable = true;
        enableGnomeKeyring = true;
      };
      login = {
        enableGnomeKeyring = true;
      };
    };
  };

  programs = {
    seahorse.enable = true;
    dconf.enable = true;
    gnome-disks.enable = true;
    # fix collision w/ KDE; prefer gnome's secrets manager
    # ssh.askPassword = pkgs.lib.mkForce "${pkgs.seahorse.out}/libexec/seahorse/ssh-askpass";
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
    }; # services

    gnome = {
      gnome-keyring.enable = true;
      # gcr-ssh-agent.enable = true;
    };

    # misc services
    #
    blueman.enable = true;
    sysprof.enable = true;

    # dbus
    #
    dbus.packages = [pkgs.gcr];

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  }; # services

  ## Env
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
        output_name = "DP-3";
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      };
    };

    xdgOpenUsePortal = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      # xdg-desktop-portal-hyprland
      kdePackages.xdg-desktop-portal-kde
      # xdg-desktop-portal-termfilechooser
      # xdg-desktop-portal-xapp
    ];

    config = {
      common = {
        default = ["wlr" "gtk" "kde"];
        # default = ["Hyprland" "gtk" "wlr" "kde"];
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
        "org.freedesktop.impl.portal.FileChooser" = ["kde"];
      };
      kde = {
        "org.freedesktop.impl.portal.Secret" = ["kwalletd6"];
      };
    };
  }; # XDG portal

  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        firefox
        floorp
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

    gnome-system-monitor
    gnome-calendar
    gnomeExtensions.appindicator

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
    # gnome-weather

    # wallpapers
    swww
    swaybg
    wbg

    # keyboard / input
    wev
    wshowkeys
    showmethekey
    # kmonad

    # viewers
    swayimg
    zathura
    imv
    cava
    tuba

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
    wofi
    wmenu
    rofi
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
      # gtk.enable = true;
      x11 = {
        enable = true;
        defaultCursor = "phinger-cursors-light";
      };
    };

    home.packages = with pkgs; [
      # others
      hyprlock
      swayosd
    ];

    services = {
      swayosd.enable = true;
    }; # services
  }; # home-manager
}
