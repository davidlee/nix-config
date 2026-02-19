{
  pkgs,
  self,
  ...
}: {
  nix.package = pkgs.lixPackageSets.stable.lix;

  imports = with self; [
    ./hardware-configuration.nix

    nixosModules._1password
    # nixosModules.ai
    nixosModules.appimage
    nixosModules.avahi
    nixosModules.bluetooth
    nixosModules.boot
    nixosModules.browsers
    nixosModules.editors
    nixosModules.env
    nixosModules.flatpak
    nixosModules.fonts
    nixosModules.games
    nixosModules.gamedev
    nixosModules.gamescope
    nixosModules.graphics
    nixosModules.greeter
    nixosModules.kanshi
    nixosModules.kde
    nixosModules.kernel
    nixosModules.keyboard
    nixosModules.keyring
    nixosModules.lib
    nixosModules.locate
    nixosModules.media
    nixosModules.network
    nixosModules.nix
    nixosModules.office
    nixosModules.openrgb
    nixosModules.pipewire
    nixosModules.podman
    nixosModules.postgresql
    nixosModules.programs
    nixosModules.radeon
    nixosModules.security
    nixosModules.sshd
    nixosModules.sway
    # nixosModules.hyprland
    nixosModules.swayidle
    nixosModules.terminals
    nixosModules.user
    nixosModules.util
    nixosModules.wayland
    nixosModules.wayland-packages
    nixosModules.webserver
    nixosModules.x11
    nixosModules.xdg
    nixosModules.zed-editor
    # nixosModules.kmscon
    # nixosModules.mangohud
    # nixosModules.mpd
    # nixosModules.microcode
    # nixosModules.virtualisation

    # shared:
    nixosModules.cliPackages
    nixosModules.emacs
  ];
}
