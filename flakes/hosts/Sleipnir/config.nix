{
  pkgs,
  self,
  ...
}: {
  nix.package = pkgs.lixPackageSets.stable.lix;

  imports = with self; [
    ./hardware-configuration.nix
    nixosModules.env
    nixosModules.nix
    nixosModules.flatpak
    nixosModules.lib
    nixosModules.browsers
    nixosModules.editors
    nixosModules.fonts
    nixosModules.keyboard
    nixosModules.webserver
    nixosModules.postgresql
    nixosModules.mpd
    nixosModules.media
    nixosModules.graphics
    nixosModules.programs
    nixosModules.util
    nixosModules.security
    nixosModules.user
    nixosModules.games
    nixosModules.boot
    nixosModules.greeter
    nixosModules.radeon
    nixosModules.network
    nixosModules.wayland
    nixosModules.sway
    nixosModules.office
    nixosModules.ai
    nixosModules.terminals
    nixosModules._1password
    nixosModules.wayland-packages
    nixosModules.xdg
    nixosModules.x11
    nixosModules.keyring
    nixosModules.pipewire
    nixosModules.bluetooth
    nixosModules.openrgb
    nixosModules.locate
    nixosModules.avahi
    nixosModules.podman
    nixosModules.zed-editor
    # nixosModules.kmscon
    # nixosModules.microcode

    # shared:
    nixosModules.cliPackages
  ];
}
