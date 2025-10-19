_: let
  gfxPackages = pkgs:
    with pkgs; [
    ];
in {
  flake.nixosModules.gfx = {pkgs, ...}: {
    environment.systemPackages = gfxPackages pkgs;
  };

  flake.darwinModules.gfx = {pkgs, ...}: {
    environment.systemPackages = gfxPackages pkgs;
  };
}
