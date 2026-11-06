{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: {
    devShells = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux" "aarch64-darwin"] (system: {
      default = import ./shell.nix {pkgs = nixpkgs.legacyPackages.${system};};
    });
  };
}
