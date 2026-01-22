{pkgs, ...}: {
  flake.nixosModules.graphics = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      ## graphics & 3d
      blender
      # gimp-with-plugins
      krita
      inkscape
      gimp-with-plugins
      # darktable
      # ansel
      # digikam
      # penpot-desktop
      # pikopixel
    ];
  };
}
