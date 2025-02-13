
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
    ./hyprland.nix
    ./cursors.nix
  ];

  wayland = {
    windowManager = {
      river = {
        enable = true;
        systemd.enable = true;
      };
      wayfire = {
        enable = true;
      };
    };
  };
}
