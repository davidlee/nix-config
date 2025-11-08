{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = {nixpkgs, ...}: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];

    # -> attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
  in
    forAllSystems (system: {
      pkgs.${system}.mkShell = {
        packages = with pkgs.${system}; [
          hello
        ];
      };
    });
}
