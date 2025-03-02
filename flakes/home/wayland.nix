{
  config,
  pkgs,
  hy3,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./sway.nix
    # ./hyprland.nix
    ./cursors.nix
  ];


  # home.packages = with inputs.nixpkgs-stable; [
  # ];
   
  # packages which are more about providing a foundational
  # window system, WMs, etc, than e.g. standalone GUI apps
  

    # nixpkgs.overlays = [
    #   inputs.nixpkgs-wayland.overlay
      
    #   (final: prev: {
    #     dwl = prev.dwl.override { conf = ./overlays/patches/dwl/config.h; };
    #   })

    #   # # pin packages to nixpkgs-stable
    #   # (final: prev: {
    #   #   # lldb = nixpkgs-stable.lldb;
    #   # })
    # ];

  home.packages = with pkgs; [
    espanso-wayland
    lutris
    swayr
    discord
    gammastep
    adwaita-icon-theme
    gnomeExtensions.appindicator
  
    bibata-cursors
    clipman
    clipse
    copyq
    dmenu
    dwl
    dwlb
    flameshot
    fuzzel
    gamehub
    gdm
    grim
    imv
    kanshi
    kmonad
    limo    
    nemo
    protontricks
    # river
    rootbar
    shotman
    shotman
    showmethekey
    signal-desktop
    sirula
    spatial-shell
    # swaybg
    sway-contrib.grimshot
    # swayidle
    # swayimg
    # swaylock
    # swaymux
    tuba
    # waybar
    # waypipe
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

  # programs = {
  #   dconf.enable = true;

  #   sway = {
  #     enable = true;
  #   };

  #   steam = {
  #     enable = true;
  #     gamescopeSession.enable = true;
  #     remotePlay.openFirewall = true;
  #     dedicatedServer.openFirewall = true;
  #     localNetworkGameTransfers.openFirewall = true; 
  #     protontricks.enable = true;
  #   };

  #   gamemode.enable = true;
  #   gamescope.enable = true;
    
  #   thunar = {
  #     enable = true;
  #     plugins = with pkgs.xfce; [thunar-archive-plugin thunar-volman];
  #   };
  #   walker = {
  #     enable = true;
  #     runAsService = true;
  #   };
  
  #   waybar =  {
  #     enable = true;
  #     systemd.enable = true; 
  #   };
  # };
}
