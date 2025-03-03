{
  config,
  pkgs,
  hy3,
  inputs,
  lib,
  ...
}: {
  imports = [
    # ./sway.nix
    # ./hyprland.nix
    ./cursors.nix
  ];

  # packages which are more about providing a foundational
  # window system, WMs, etc, than e.g. standalone GUI apps
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
    # espanso-wayland
    flameshot
    fuzzel
    gamehub
    gammastep
    gdm
    gnomeExtensions.appindicator
    # grim
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

  # wayland = {
  #   windowManager = {
  #     river = {
  #       enable = true;
  #       systemd.enable = true;
  #     };
  #     wayfire = {
  #       enable = true;
  #     };
  #   };
  # };

}
