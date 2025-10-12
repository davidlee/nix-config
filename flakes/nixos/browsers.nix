{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## browsers
    vivaldi
    librewolf
    firefox
    firefox-devedition
    firefoxpwa
    floorp-bin
    ungoogled-chromium
    tor-browser
    pkgs.firefoxpwa
    # ladybird
    # midori
    # qutebrowser
    # kdePackages.angelfish
    # palemoon-bin
    # inputs.zen-browser.packages.${pkgs.system}.default
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    nativeMessagingHosts.packages = [pkgs.firefoxpwa];
  };
}
