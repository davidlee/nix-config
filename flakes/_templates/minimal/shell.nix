{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  packages = with pkgs; [guile];

  shellHook = ''
    echo hello guile
  '';
}
