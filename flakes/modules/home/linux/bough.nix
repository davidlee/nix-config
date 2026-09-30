# parked — `inputs.bough` is commented out in flake.nix; restore it before enabling.
{
  inputs,
  pkgs,
  ...
}: let
  bh = inputs.bough.packages.${pkgs.stdenv.hostPlatform.system};
in {
  home.packages = [
    bh.default
  ];
}
