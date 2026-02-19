_: {
  flake.nixosModules.browsers = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # (callPackage ../../packages/helium.nix {})
      vivaldi
      librewolf
      firefox
      firefox-devedition
      firefoxpwa
      # floorp-bin
      ungoogled-chromium
      tor-browser
      pkgs.firefoxpwa
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
