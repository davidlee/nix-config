# Comms features, in projection order. Shape: README § Feature tree.
{lib, ...}: let
  available = import ./available.nix lib;
in [
  {
    name = "chat";
    platforms = lib.platforms.linux;
    homeManager = {pkgs, ...}: {
      # programs.zoom-us.enable = true;
      home.packages = with pkgs; [
        beeper
        signal-desktop
        signal-cli
        qrencode # for signal-cli

        discord
        element-desktop
        # zotero
        # slack
      ];
    };
  }

  {
    name = "mail";
    platforms = lib.platforms.linux;
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        thunderbird-latest
      ];
    };
  }

  {
    name = "feeds";
    homeManager = {pkgs, ...}: {
      home.packages = available pkgs (with pkgs; [
        ## text readers
        circumflex

        ## feeds, content / social
        russ # RSS
        # tuir # reddit - BROKEN
        tut # mastodon
        tuisky # bluesky
        wiki-tui # wikipedia
        # slack-term
        rssguard
      ]);
    };
  }
]
