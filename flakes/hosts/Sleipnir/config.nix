{
  pkgs,
  inputs,
  ...
}: {
  nix.package = pkgs.lixPackageSets.stable.lix;

  # Sleipnir-only package fixes. mkNixos (../../hosts.nix) appends the agents
  # overlay after these with mkAfter; without it, it would apply first.
  nixpkgs.overlays = with inputs.self.overlays; [
    llama-prism
    whisper-rocm
    click-threading-fix
  ];

  imports = [
    ./hardware-configuration.nix
    ./machine.nix

    ../../modules/nixos/1password.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/avahi.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/boot.nix
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
    # not features: selecting one says "flip me", which would be a lie here.
    # ../../modules/nixos/hyprland.nix   (hyprlandPlugins.hyprexpo missing)
    # ../../modules/nixos/kmscon.nix     (services.kmscon.fonts removed upstream)

    # shared:
    ../../modules/nixos/cli.nix
  ];
}
