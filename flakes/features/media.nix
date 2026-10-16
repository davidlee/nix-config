# Media features, in projection order. Shape: README § Feature tree.
{lib, ...}: [
  {
    name = "players";
    platforms = lib.platforms.linux;
    homeManager = {pkgs, ...}: {
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
      ];
    };
  }

  {
    name = "spotify";
    platforms = lib.platforms.linux;
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        ## music player & library management
        spotify
        # spotifycli
        spotify-cli-linux
        spotifyd
        spotify-tray
        spotify-player
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

  # this also depends on v4l2loopback in boot
  {
    name = "obs";
    requires = ["desktop.core"];
    platforms = lib.platforms.linux;
    homeManager = {pkgs, ...}: {
      programs.obs-studio = {
        enable = true;
      };
      programs.obs-studio.plugins = [pkgs.obs-studio-plugins.wlrobs];
    };
  }
]
