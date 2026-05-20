_: {
  flake.homeModules.wayland = {
    pkgs,
    config,
    lib,
    ...
  }: {
    services.swaync.enable = true;

    xdg.configFile."swaync/config.json".source =
      lib.mkForce
      (config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.config/swaync/config.local.json");
    xdg.configFile."swaync/style.css".source =
      lib.mkForce
      (config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.config/swaync/style.local.css");

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
