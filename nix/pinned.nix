# https://jade.fyi/blog/pinning-nixos-with-npins/
{
  config,
  pkgs,
  lib,
  ...
}: let
  sources = import ./npins;
in {
  nix.settings = {
    experimental-features = "nix-command flakes";
  };

  nixpkgs.flake.source = sources.nixpkgs;

  nix.registry.nixpkgs.to = {
    type = "path";
    path = sources.nixpkgs;
  };
  nix.nixPath = ["nixpkgs=flake:nixpkgs"];
}
