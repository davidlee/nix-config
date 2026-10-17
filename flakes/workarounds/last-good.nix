# lastGood: one package from an earlier nixpkgs revision (design SL-012
# sec-3, DEC-054).
#
#   lastGood {rev; narHash} pkgs attr  ->  that revision's pkgs.<attr>
#
# {rev; narHash} is pasted from `workarounds/last-good <input>`, which reads
# it from the right committed flake.lock. The revision is imported for pkgs'
# system and with pkgs' config. Used in a local overlay or a package list:
#
#   final: prev: {foo = lastGood {rev = "…"; narHash = "…";} prev ["foo"];}
#   home.packages = [(lastGood {…} pkgs ["foo"])];
#
# Leaf apps only: the old package brings its own closure, which coexists
# with the current one. A library other packages depend on gets a local
# override / overrideAttrs / overridePythonAttrs patch instead (DEC-054).
#
# Every use gets a probe in ./default.nix, so workarounds/check says when
# the current revision has it again.
#
# Null-valued config attrs are dropped: the evaluated config carries
# defaults such as `replaceStdenv = null`, which an older nixpkgs reads as
# set and calls.
{
  rev,
  narHash,
}: pkgs: attr: let
  inherit (pkgs) lib;
  old =
    import (builtins.fetchTree {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      inherit rev narHash;
    }) {
      inherit (pkgs.stdenv.hostPlatform) system;
      config = lib.filterAttrs (_: v: v != null) pkgs.config;
    };
in
  lib.getAttrFromPath attr old
