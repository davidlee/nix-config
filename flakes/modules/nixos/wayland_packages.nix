_: {
  flake.nixosModules.wayland-packages = {
    pkgs,
    username,
    ...
  }: {
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
      wl-kbptr
      wl-restart
      wl-mirror
      wlopm
      wlr-layout-ui

      ## color pickers
      wl-color-picker
      hyprpicker
      oklch-color-picker

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
      # stable.copyq
      copyq

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
  };
}
