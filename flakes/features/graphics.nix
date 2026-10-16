# Graphics features, in projection order. Shape: README § Feature tree.
{lib, ...}: [
  {
    name = "paint";
    platforms = lib.platforms.linux;
    homeManager = {
      pkgs,
      stable,
      ...
    }: {
      home.packages = with pkgs; [
        krita
        stable.mypaint
        inkscape
        gimp
        drawpile
        penpot-desktop
      ];
    };
  }

  {
    name = "modelling";
    platforms = lib.platforms.linux;
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        blender
      ];
    };
  }

  {
    name = "color";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        pastel
      ];
    };
  }

  # openscad is portable: no platforms.
  {
    name = "cad";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        openscad # openscad-unstable
      ];
    };
  }
]
