{
  pkgs,
  self,
  ...
}: {
  nix.package = pkgs.lixPackageSets.stable.lix;

  imports = with self; [
    ./hardware-configuration.nix

    nixosModules._1password
    nixosModules.appimage
    nixosModules.avahi
    nixosModules.bluetooth
    nixosModules.boot
    nixosModules.browsers
    nixosModules.cargo
    nixosModules.env
    nixosModules.flatpak
    nixosModules.fonts
    nixosModules.games
    nixosModules.gamescope
    # nixosModules.graphics
    nixosModules.greeter
    nixosModules.kanshi
    nixosModules.kde
    nixosModules.kernel
    nixosModules.keyboard
    nixosModules.keyring
    nixosModules.lib
    nixosModules.locate
    nixosModules.network
    nixosModules.nix
    # nixosModules.openrgb
    nixosModules.pipewire
    nixosModules.podman
    nixosModules.postgresql
    nixosModules.programs
    nixosModules.radeon
    # nixosModules.rocm
    nixosModules.security
    nixosModules.sshd
    nixosModules.sway
    # nixosModules.hyprland
    nixosModules.user
    nixosModules.util
    nixosModules.wayland
    nixosModules.wayland-packages
    nixosModules.webserver
    nixosModules.x11
    nixosModules.xdg
    # nixosModules.kmscon
    # nixosModules.mpd
    # nixosModules.microcode

    # shared:
    nixosModules.cliPackages
    # emacs: moved to homeModules
  ];
}
