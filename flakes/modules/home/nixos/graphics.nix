_: {
  flake.homeModules.graphics = {pkgs, ...}: {
    home.packages = with pkgs; [
      # krita
    ];
  };
}
