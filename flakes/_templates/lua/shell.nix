{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  packages = with pkgs; [
    lua-language-server
    stylua
    selene
    lua5_1
    lua51Packages.luarocks
  ];
}
