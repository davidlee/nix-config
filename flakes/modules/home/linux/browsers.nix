{
  pkgs,
  # inputs,
  ...
}: {
  home.packages = with pkgs; [
    # (callPackage ../../../pub/helium.nix {})
    # ladybird
    vivaldi
    ungoogled-chromium
    firefox
    firefoxpwa
    epiphany
    # inputs.hythera-nur.packages.${pkgs.system}.waterfox
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    nativeMessagingHosts.packages = [pkgs.firefoxpwa];
  };
}
