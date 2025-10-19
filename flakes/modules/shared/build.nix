_: let
  buildPackages = pkgs:
    with pkgs; [
    ];
in {
  flake.nixosModules.build = {pkgs, ...}: {
    environment.systemPackages = buildPackages pkgs;
  };

  flake.darwinModules.build = {pkgs, ...}: {
    environment.systemPackages = buildPackages pkgs;
  };
}
