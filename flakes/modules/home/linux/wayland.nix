{pkgs, ...}: {
  # conflicts with DMS
  # services.swaync.enable = true;
  #
  # xdg.configFile."swaync/config.json".source =
  #   lib.mkForce
  #   (config.lib.file.mkOutOfStoreSymlink
  #     "${config.home.homeDirectory}/.config/swaync/config.local.json");
  # xdg.configFile."swaync/style.css".source =
  #   lib.mkForce
  #   (config.lib.file.mkOutOfStoreSymlink
  #     "${config.home.homeDirectory}/.config/swaync/style.local.css");

  # monitor hot-swapping. disabled: single display (DP-3). started from
  # sway extraConfig via `systemctl --user start kanshi.service` when enabled.
  services.kanshi = {
    enable = false;
    settings = [
      {
        profile.name = "solo";
        profile.outputs = [
          {
            criteria = "DP-3";
            status = "enable";
          }
        ];
      }
    ];
  };

  home.pointerCursor = {
    enable = true;
    name = "phinger-cursors-light";
    package = pkgs.phinger-cursors;
    size = 32;
    x11 = {
      enable = true;
      defaultCursor = "phinger-cursors-light";
    };
  };
}
