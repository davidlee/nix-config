{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./boot.nix
    ./services.nix
    ./hardware.nix
    ./network.nix
    ./security.nix
    ./virtualisation.nix
    ./users.nix
    ./fonts.nix
  ];
}
