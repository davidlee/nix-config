# Web features, in projection order. Shape: README § Feature tree.
{lib, ...}: [
  {
    name = "browsers";
    platforms = lib.platforms.linux;
    homeManager = {
      pkgs,
      config,
      # inputs,
      ...
    }: {
      home.packages = with pkgs; [
        # (callPackage ../../../packages/helium.nix {})
        # ladybird
        vivaldi
        ungoogled-chromium
        epiphany
      ];

      programs = {
        firefox = {
          enable = true;
          package = pkgs.firefox;
          # nativeMessagingHosts.packages = [pkgs.firefoxpwa];
        };
        firefoxpwa.enable = true;
        firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";
      };
    };
  }
]
