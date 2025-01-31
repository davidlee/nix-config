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
    # ./config.nix
    ./hardware.nix
    ./security.nix
    # ./variables.nix
    ./users.nix
    ./fonts.nix
    ./xdg.nix
  ];
}
