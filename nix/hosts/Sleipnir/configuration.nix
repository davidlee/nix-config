{
  pkgs,
  config,
  ...
}: {
  imports = [
    ../../pinned.nix
  ./hardware-configuration.nix
  ];
}
