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
    ./network.nix
    ./security.nix
    # ./virtualisation.nix
    ./users.nix
    ./fonts.nix
  ];
}
