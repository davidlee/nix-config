{
  config,
  lib,
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

  # Resolver tests. Evaluating them is the test; the build is a stub.
  checks.features = let
    failures = import ./features-test.nix lib;
  in
    if failures == []
    then pkgs.runCommand "features-test" {} "touch $out"
    else throw "features-test.nix failed:\n${lib.generators.toPretty {} failures}";
}
