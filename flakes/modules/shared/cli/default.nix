{
  pkgs,
  lib,
}: let
  files = lib.attrNames (builtins.readDir ./_packages);
  data = map (f: import (./_packages + "/${f}") {inherit pkgs lib;}) files;
  bucket = b: lib.concatMap (d: d.${b} or []) data;
in {
  # common      - portable userland CLI tools (both platforms), owned by Home Manager
  # linuxHome   - Linux-only userland CLI tools, owned by Home Manager
  # linuxSystem - Linux-only machine/admin substrate, owned by NixOS environment.systemPackages
  common = bucket "common";
  linuxHome = bucket "linuxHome";
  linuxSystem = bucket "linuxSystem";
}
