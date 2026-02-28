_: {
  flake.homeModules.media = {pkgs, ...}: {
    home.packages = with pkgs; [
      spotify
    ];
  };
}
