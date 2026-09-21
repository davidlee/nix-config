{
  pkgs,
  lib,
  features,
  ...
}: {
  nix.package = pkgs.lixPackageSets.stable.lix;

  # Unconditional modules first, then the feature-gated ones. Flags are
  # declared in ../../modules/features.nix and overridden in ./features.nix.
  imports =
    [
      ./hardware-configuration.nix

      ../../modules/nixos/1password.nix
      ../../modules/nixos/audio.nix
      ../../modules/nixos/avahi.nix
      ../../modules/nixos/bluetooth.nix
      ../../modules/nixos/boot.nix
      ../../modules/nixos/browsers.nix
      ../../modules/nixos/capsule.nix
      ../../modules/nixos/cargo.nix
      ../../modules/nixos/env.nix
      ../../modules/nixos/greeter.nix
      ../../modules/nixos/kernel.nix
      ../../modules/nixos/keyboard.nix
      ../../modules/nixos/keyring.nix
      ../../modules/nixos/lib.nix
      ../../modules/nixos/locate.nix
      ../../modules/nixos/maintenance.nix
      ../../modules/nixos/network.nix
      ../../modules/nixos/nix.nix
      ../../modules/nixos/oom.nix
      ../../modules/nixos/podman.nix
      ../../modules/nixos/postgresql.nix
      ../../modules/nixos/programs.nix
      ../../modules/nixos/qt.nix
      ../../modules/nixos/radeon.nix
      ../../modules/nixos/security.nix
      ../../modules/nixos/ssh.nix
      ../../modules/nixos/user.nix
      ../../modules/nixos/umbriel.nix
      ../../modules/nixos/util.nix
      ../../modules/nixos/wayland.nix
      ../../modules/nixos/wayland_packages.nix
      ../../modules/nixos/x11.nix
      ../../modules/nixos/xdg.nix

      # parked — these do NOT evaluate; repair before re-enabling. Deliberately
      # not feature flags: a flag says "flip me", which would be a lie here.
      # ../../modules/nixos/hyprland.nix   (hyprlandPlugins.hyprexpo missing)
      # ../../modules/nixos/kmscon.nix     (services.kmscon.fonts removed upstream)

      # shared:
      ../../modules/nixos/cli.nix
    ]
    ++ lib.optional features.apps.appimage ../../modules/nixos/appimage.nix
    ++ lib.optional features.desktop.cosmic ../../modules/nixos/cosmic.nix
    ++ lib.optional features.virt.docker ../../modules/nixos/docker.nix
    ++ lib.optional features.apps.flatpak ../../modules/nixos/flatpak.nix
    ++ lib.optional features.fonts ../../modules/nixos/fonts.nix
    ++ lib.optional features.games.enable ../../modules/nixos/games.nix
    ++ lib.optional features.games.gamescope ../../modules/nixos/gamescope.nix
    ++ lib.optional features.desktop.kde ../../modules/nixos/kde.nix
    ++ lib.optional features.ai.llama-cpp ../../modules/nixos/llama-cpp.nix
    ++ lib.optional features.desktop.mango ../../modules/nixos/mango.nix
    ++ lib.optional features.hardware.microcode ../../modules/nixos/microcode.nix
    ++ lib.optional features.mpd ../../modules/nixos/mpd.nix
    ++ lib.optional features.desktop.niri ../../modules/nixos/niri.nix
    ++ lib.optional features.hardware.openrgb ../../modules/nixos/openrgb.nix
    ++ lib.optional features.printing ../../modules/nixos/printing.nix
    ++ lib.optional features.virt.qemu ../../modules/nixos/qemu.nix
    ++ lib.optional features.ai.rocm ../../modules/nixos/rocm.nix
    ++ lib.optional features.snooze ../../modules/nixos/snooze.nix
    ++ lib.optional features.speech ../../modules/nixos/speech.nix
    ++ lib.optional features.hardware.ssd ../../modules/nixos/ssd.nix
    ++ lib.optional features.sunshine ../../modules/nixos/sunshine.nix
    ++ lib.optional features.desktop.sway ../../modules/nixos/sway.nix
    ++ lib.optional features.webserver ../../modules/nixos/webserver.nix;
}
