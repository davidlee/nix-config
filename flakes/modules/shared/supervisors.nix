_: let
  supervisorsPackages = pkgs:
    with pkgs; [
    ];
in {
  flake.nixosModules.supervisors = {pkgs, ...}: {
    environment.systemPackages = supervisorsPackages pkgs;
  };

  flake.darwinModules.supervisors = {pkgs, ...}: {
    environment.systemPackages = supervisorsPackages pkgs;
  };
}
