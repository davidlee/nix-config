_: {
  flake.homeModules.browsers = {pkgs, ...}: {
    home.packages = with pkgs; [
      # (callPackage ../../../pub/helium.nix {})
      ladybird
      vivaldi
      ungoogled-chromium
    ];
  };
}
