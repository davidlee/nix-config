# Notes features, in projection order. Shape: README § Feature tree.
{lib, ...}: [
  {
    name = "terminal";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux (with pkgs; [
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
