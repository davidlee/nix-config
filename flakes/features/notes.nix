# Notes features, in projection order. Shape: README § Feature tree.
{lib, ...}: [
  {
    name = "joplin";
    platforms = lib.platforms.linux;
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        joplin
      ];
    };
  }
]
