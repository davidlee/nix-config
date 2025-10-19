_: let
  searchPackages = pkgs:
    with pkgs; [
    ];
in {
  flake.nixosModules.search = {pkgs, ...}: {
    environment.systemPackages = searchPackages pkgs;
  };

  flake.darwinModules.search = {pkgs, ...}: {
    environment.systemPackages = searchPackages pkgs;
  };
}
