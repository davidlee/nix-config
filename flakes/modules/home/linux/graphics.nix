{
  pkgs,
  # stable,
  ...
}: {
  home.packages = with pkgs; [
    krita
    mypaint
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
