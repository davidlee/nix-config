# Media features, in projection order. Shape: README § Feature tree.
{lib, ...}: let
  available = import ./available.nix lib;
in [
  {
    name = "view";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs;
        [
          ## image / graphics / multimedia
          chafa
          viu
        ]
        ++ available pkgs [
          ueberzugpp
        ];
    };
  }

  {
    name = "convert";
    homeManager = {pkgs, ...}: {
      home.packages = available pkgs (with pkgs; [
        resvg
        ffmpeg-full
      ]);
    };
  }

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

        ## cli audio
        asak
        cmus

        ## media players
        vlc
        # kodi-wayland
        # kodi-cli
        celluloid

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
