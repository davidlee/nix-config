_: {
  flake.nixosModules.browsers = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      firefox
      firefox-devedition
      firefoxpwa
      # pkgs.firefoxpwa

      # vivaldi
      # librewolf
      # floorp-bin
      # ungoogled-chromium
      # tor-browser
      # ladybird
      # midori
      # qutebrowser
      # kdePackages.angelfish
      # palemoon-bin
      # inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    programs.firefox = {
      enable = true;
      package = pkgs.firefox;
      nativeMessagingHosts.packages = [pkgs.firefoxpwa];
    };
  };
}
