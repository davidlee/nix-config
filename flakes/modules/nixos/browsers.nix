{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    firefox
    # firefox-devedition BROKEN
    firefoxpwa
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    nativeMessagingHosts.packages = [pkgs.firefoxpwa];
  };
}
