_: {
  flake.homeModules.media = {pkgs, ...}: {
    home.packages = with pkgs; [
      ## media players
      mpv
      playerctl

      ## youtube
      # invidtui
      # youtube-tui
      # ytermusic

      ## GUI
      ## image viewers
      viu

      ## cli audio
      asak
      cmus

      ## media players
      vlc
      # kodi-wayland
      # kodi-cli
      celluloid
      mpv

      ## video
      # shortcut

      ## music player & library management
      spotify
      # beets
      # fooyin
      # quodlibet
      # spotify: moved to homeModules.media
      # tauon
      # tokei
      # deadbeef
      # cantata
    ];
  };
}
