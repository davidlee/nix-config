_: {
  flake.homeModules.niri = {
    pkgs,
    username,
    ...
  }: {
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
  };
}
