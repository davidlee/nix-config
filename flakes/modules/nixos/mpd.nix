_: {
  flake.nixosModules.mpd = _: {
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
