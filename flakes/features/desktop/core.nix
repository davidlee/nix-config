# The shared Wayland stack every compositor session here uses (DEC-026), both
# halves: the system stack, and the session's home pieces (cursor, tray,
# wallpaper, notifications). Never toggled in parts; compositors require it.
# Linux-only.
{lib, ...}: {
  name = "core";
  platforms = lib.platforms.linux;
  nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      cosmic-edit
      cosmic-wallpapers
      nautilus
      nautilus-open-any-terminal
      (with pkgs.kdePackages; [
        pkgs.qt6Packages.qt6ct
        breeze
        breeze-icons
        breeze-gtk
        breeze-plymouth

        bluedevil
        bluez-qt

        dolphin
        dolphin-plugins
        drkonqi
      ])
    ];
    security.pam.services.swaylock = {};

    services.gvfs.enable = true; # Enables Trash, network mounts, and storage detection
    services.tumbler.enable = true; # Enables image/video thumbnails in file managers
    programs.firefox.preferences = {
      "widget.gtk.libadwaita-colors.enabled" = false;
    };

    imports = [
      ./core/wayland.nix
      ./core/wayland_packages.nix
      ./core/x11.nix
      ./core/xdg.nix
      ./core/qt.nix
      ./core/keyring.nix # + greetd keyring PAM from security.nix; minus polkit
      ./core/gui.nix # GUI programs and libraries, session glue
      ./core/v4l2loopback.nix # from kernel.nix
    ];
  };
  homeManager = {
    pkgs,
    inputs,
    ...
  }: {
    home.packages = with pkgs; [vicinae];

    imports = [
      inputs.vicinae.homeManagerModules.default
      ./core/home.nix
      # inputs.noctalia.homeModules.default
    ];
  };
}
