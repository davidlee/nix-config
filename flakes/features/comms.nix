# Comms features, in projection order. Shape: README § Feature tree.
{lib, ...}: [
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
]
