_: let
  netPackages = pkgs:
    with pkgs; [
    ];
in {
  flake.nixosModules.net = {pkgs, ...}: {
    environment.systemPackages = netPackages pkgs;
  };

  flake.darwinModules.net = {pkgs, ...}: {
    environment.systemPackages = netPackages pkgs;
  };
}
