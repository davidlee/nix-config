{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./boot.nix
    ./packages.nix
    ./programs.nix
    ./services.nix
    ./hardware.nix
    ./security.nix
    ./users.nix
    ./fonts.nix
    ./xdg.nix
  ];
}
