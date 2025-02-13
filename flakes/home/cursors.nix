

{
  config,
  pkgs,
  hy3,
  inputs,
  lib,
  ...
}: {
  
  home.pointerCursor = {
    name = "phinger-cursors-light";
    package = pkgs.phinger-cursors;
    size = 32;
    gtk.enable = true;
    x11 = {
      enable = true;
      defaultCursor = "phinger-cursors-light";
    };
  };
}
