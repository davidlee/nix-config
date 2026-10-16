# Editor features, in projection order. Shape: README § Feature tree.
{lib, ...}: [
  {
    name = "zed";
    platforms = lib.platforms.linux;
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.zed-editor];
    };
  }

  {
    name = "lem";
    platforms = lib.platforms.linux;
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        lem-ncurses
      ];
    };
  }
]
