_: {
  flake.nixosModules.browsers = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      firefox
      firefox-devedition
      firefoxpwa
    ];

    programs.firefox = {
      enable = true;
      package = pkgs.firefox;
      nativeMessagingHosts.packages = [pkgs.firefoxpwa];
    };
  };
}
