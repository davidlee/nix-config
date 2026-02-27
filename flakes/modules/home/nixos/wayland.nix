_: {
  flake.homeModules.wayland = {pkgs, ...}: {
    home.pointerCursor = {
      name = "phinger-cursors-light";
      package = pkgs.phinger-cursors;
      size = 32;
      x11 = {
        enable = true;
        defaultCursor = "phinger-cursors-light";
      };
    };
  };
}
