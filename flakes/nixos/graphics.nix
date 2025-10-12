{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## graphics & 3d
    blender
    # gimp-with-plugins
    krita
    inkscape
    # darktable
    # ansel
    # digikam
    # penpot-desktop
    # pikopixel
  ];
}
