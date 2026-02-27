_: {
  flake.homeModules.browsers = {pkgs, ...}: {
    home.packages = with pkgs; [
      ladybird
      vivaldi
      ungoogled-chromium
    ];
  };
}
