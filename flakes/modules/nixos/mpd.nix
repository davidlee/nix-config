{...}: {
  flake.nixosModules.mpd = {...}: {
    services = {
      mpd = {
        enable = false;
        musicDirectory = "/media/music";
        extraConfig = ''
        '';
      };
    };
  };
}
