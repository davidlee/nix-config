{
  description = "The producer contract's smallest executable form: packages.<system>.dev-tools";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAll = f: nixpkgs.lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});
  in {
    packages = forAll (pkgs: {
      dev-tools = pkgs.buildEnv {
        name = "stub-dev-tools";
        paths = [pkgs.hello];
      };
      probe = pkgs.hello; # the same derivation, named for the check
    });
    devShells = forAll (pkgs: {default = pkgs.mkShell {packages = [pkgs.hello];};});
  };
}
