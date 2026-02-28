_: {
  flake.homeModules.browsers = {pkgs, ...}: {
    home.packages = with pkgs; [
      # (callPackage ../../../packages/helium.nix {})
      ladybird
      vivaldi
      ungoogled-chromium
    ];
  };
}
