{
  config,
  pkgs,
  ...
}: {
  treefmt.programs = {
    alejandra.enable = true;
    statix.enable = true;
    deadnix.enable = true;
  };
  devShells.default = pkgs.mkShell {
    packages = [config.treefmt.build.wrapper pkgs.gum pkgs.just pkgs.nix-output-monitor];
  };
}
