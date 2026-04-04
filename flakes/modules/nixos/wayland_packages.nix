_: {
  flake.nixosModules.wayland-packages = {pkgs, ...}: {
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
      thunar
      tumbler

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
      awww
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
      libx11
      libx11.dev
      libxcursor
      libxi
      libxinerama
      libxrandr
      libnotify
    ];
  };
}
