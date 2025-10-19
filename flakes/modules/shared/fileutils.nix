_: let
  fileutilsPackages = pkgs:
    with pkgs; [
    ];
in {
  flake.nixosModules.fileutils = {pkgs, ...}: {
    environment.systemPackages = fileutilsPackages pkgs;
  };

  flake.darwinModules.fileutils = {pkgs, ...}: {
    environment.systemPackages = fileutilsPackages pkgs;
  };
}
