{pkgs, ...}: {
  linuxHome = with pkgs; [
    # tealdeer is the tldr client (provides bin/tldr); plain `tldr` dropped.
    tealdeer
    cheat
    pinfo
  ];
}
