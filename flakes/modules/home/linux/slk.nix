# parked — `inputs.slk` is not declared in flake.nix; add it before enabling.
{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.slk.packages.${pkgs.system}.default
  ];
}
