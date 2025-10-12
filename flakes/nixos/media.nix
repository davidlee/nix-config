{pkgs, ...}: {
  services = {
    mpd = {
      enable = false;
      musicDirectory = "/media/music";
      extraConfig = ''
      '';
    };
  };
  environment.systemPackages = with pkgs; [
    ## audio / music
    ncpamixer
    asak
    cmus
    di-tui # di.fm player
    fum
    termusic
    rmpc

    ## image / graphics / multimedia
    viu

    ## media players
    mpv
    playerctl

    ## youtube
    # invidtui
    # youtube-tui
    # ytermusic
  ];
}
