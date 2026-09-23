{
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

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    # nativeMessagingHosts.packages = [pkgs.firefoxpwa];
  };
  programs.firefoxpwa.enable = true;
  programs.firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";
}
