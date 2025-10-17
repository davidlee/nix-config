{...}: {
  flake.nixosModules.media = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      ## CLI

      ## audio / music
      pavucontrol
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

      ## GUI

      ## media players
      vlc
      # kodi-wayland
      # kodi-cli
      celluloid
      mpv

      ## video
      # shortcut

      ## music player & library management
      # beets
      # fooyin
      # quodlibet
      spotify
      # tauon
      # tokei
      # deadbeef
      # cantata
    ];
  };
}
