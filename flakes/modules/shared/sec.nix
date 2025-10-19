_: let
  secPackages = pkgs:
    with pkgs; [
    ];
in {
  flake.nixosModules.sec = {pkgs, ...}: {
    environment.systemPackages = secPackages pkgs;
  };

  flake.darwinModules.sec = {pkgs, ...}: {
    environment.systemPackages = secPackages pkgs;
  };
}
