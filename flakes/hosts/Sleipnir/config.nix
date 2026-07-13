{
  pkgs,
  self,
  ...
}: {
  nix.package = pkgs.lixPackageSets.stable.lix;

  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos/1password.nix
    ../../modules/nixos/appimage.nix
    ../../modules/nixos/avahi.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/browsers.nix
    ../../modules/nixos/cargo.nix
    ../../modules/nixos/cosmic.nix
    # ../../modules/nixos/docker.nix
    ../../modules/nixos/env.nix
    ../../modules/nixos/flatpak.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/games.nix
    ../../modules/nixos/gamescope.nix
    # ../../modules/nixos/graphics.nix
    ../../modules/nixos/greeter.nix
    ../../modules/nixos/kanshi.nix
    ../../modules/nixos/kde.nix
    ../../modules/nixos/kernel.nix
    ../../modules/nixos/keyboard.nix
    ../../modules/nixos/keyring.nix
    ../../modules/nixos/lib.nix
    ../../modules/nixos/locate.nix
    ../../modules/nixos/llama-cpp.nix
    ../../modules/nixos/maintenance.nix
    ../../modules/nixos/network.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/niri.nix
    ../../modules/nixos/oom.nix
    # ../../modules/nixos/openrgb.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/podman.nix
    ../../modules/nixos/printing.nix
    ../../modules/nixos/postgresql.nix
    ../../modules/nixos/programs.nix
    ../../modules/nixos/qemu.nix
    ../../modules/nixos/radeon.nix
    ../../modules/nixos/rocm.nix
    ../../modules/nixos/security.nix
    ../../modules/nixos/snooze.nix
    ../../modules/nixos/ssh.nix
    ../../modules/nixos/sway.nix
    ../../modules/nixos/speech.nix
    # ../../modules/nixos/hyprland.nix
    ../../modules/nixos/user.nix
    ../../modules/nixos/util.nix
    ../../modules/nixos/wayland.nix
    ../../modules/nixos/wayland_packages.nix
    ../../modules/nixos/webserver.nix
    ../../modules/nixos/x11.nix
    ../../modules/nixos/xdg.nix
    # ../../modules/nixos/kmscon.nix
    # ../../modules/nixos/mpd.nix
    # ../../modules/nixos/microcode.nix

    # shared:
    self.nixosModules.cliPackages
    # emacs: moved to homeModules
  ];
}
