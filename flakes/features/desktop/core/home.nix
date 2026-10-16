# desktop.core's home half (ISS-008): what every graphical session here uses,
# whichever compositor runs it. tailscale-systray needs the base's tailscale
# daemon; swaybg is bound to graphical-session.target; systembus-notify
# forwards system-bus notifications to the session's notification daemon.
{
  pkgs,
  username,
  ...
}: {
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

  services.tailscale-systray.enable = true;

  systemd.user.services.swaybg = {
    Unit = {
      Description = "wallpaper (swaybg)";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
      Requisite = ["graphical-session.target"];
    };
    Service = {
      ExecStart = ''${pkgs.swaybg}/bin/swaybg -m fill -i "/home/${username}/Pictures/wallpaper/dark-water.jpg"'';
      Restart = "on-failure";
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  services.systembus-notify.enable = true; # notify-send from systemd
}
