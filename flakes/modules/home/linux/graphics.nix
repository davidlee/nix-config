{
  pkgs,
  stable,
  ...
}: {
  home.packages = with pkgs; [
    krita
    stable.mypaint
    inkscape
    gimp
    blender
    drawpile
    # diagrams
    yed
    drawio
    penpot-desktop
  ];
}
