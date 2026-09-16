# Feature flag declarations. Evaluated once by ../features.nix, outside the
# NixOS / darwin / home-manager module systems, and injected into all three as
# a plain attrset. See ../README.md#feature-flags.
#
# Defaults describe a host that says nothing. A host overrides what it likes in
# hosts/<hostname>/features.nix.
{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;

  # An option that follows another flag unless the host pins it.
  follows = other: description:
    mkOption {
      inherit description;
      type = types.bool;
      default = other;
      defaultText = lib.literalExpression "config.games.enable";
    };

  enabledByDefault = description:
    mkOption {
      inherit description;
      type = types.bool;
      default = true;
    };
in {
  options = {
    desktop = {
      sway = enabledByDefault "sway compositor, system and user halves";
      niri = enabledByDefault "niri compositor, system and user halves";
      cosmic = enabledByDefault "COSMIC desktop";
      kde = enabledByDefault "KDE Plasma";
      mango = enabledByDefault "mango compositor";
    };

    games = {
      enable = mkEnableOption "Steam, wine, protontricks, and the nix-ld libraries games need";
      gamescope = follows config.games.enable "gamescope session and gamemode";
      mangohud = follows config.games.enable "mangohud performance overlay (home)";
    };

    ai = {
      llama-cpp = enabledByDefault "llama.cpp server";
      rocm = enabledByDefault "ROCm compute stack, for llama.cpp on Radeon";
    };

    hardware = {
      openrgb = mkEnableOption "OpenRGB lighting control";
      microcode = mkEnableOption "ucodenix CPU microcode updates";
      ssd = mkEnableOption "SSD mount options (noatime, discard)";
    };

    virt = {
      qemu = enabledByDefault "QEMU/libvirt";
      docker = mkEnableOption "Docker daemon (podman is unconditional)";
    };

    apps = {
      appimage = enabledByDefault "AppImage binfmt support";
      flatpak = enabledByDefault "Flatpak";
      cad = enabledByDefault "CAD and 3D printing tools (home)";
    };

    fonts = enabledByDefault "system font set";
    printing = enabledByDefault "CUPS and printer drivers";
    speech = enabledByDefault "speech synthesis and recognition";
    webserver = enabledByDefault "local webserver";
    snooze = enabledByDefault "nightly suspend and RTC wake, system and user halves";
    mpd = mkEnableOption "Music Player Daemon";
    sunshine = mkEnableOption "Sunshine game streaming host";
  };
}
