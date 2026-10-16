# Notes features, in projection order. Shape: README § Feature tree.
{lib, ...}: let
  available = import ./available.nix lib;
in [
  {
    name = "terminal";
    homeManager = {pkgs, ...}: {
      home.packages = available pkgs (with pkgs; [
        kb
        nb
        tpnote
        tui-journal
      ]);
    };
  }

  {
    name = "joplin";
    platforms = lib.platforms.linux;
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        joplin
        # obsidian
      ];
    };
  }
]
