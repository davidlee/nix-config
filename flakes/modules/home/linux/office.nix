{pkgs, ...}: {
  home.packages = with pkgs; [
    mpris-timer # aka play timer
    rssguard
  ];
}
