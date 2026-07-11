{pkgs, ...}: {
  common = with pkgs; [
    figlet
  ];
  linuxHome = with pkgs; [
    fastfetch
    fortune
    cmatrix
    nms

    ## feeds, content / social
    russ # RSS
    # tuir # reddit - BROKEN
    tut # mastodon
    tuisky # bluesky
    wiki-tui # wikipedia
    slack-term
  ];
}
