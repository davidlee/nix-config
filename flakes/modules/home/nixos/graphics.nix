_: {
  flake.homeModules.graphics = {
    pkgs,
    stable,
    ...
  }: {
    home.packages = with pkgs; [
      stable.krita
    ];
  };
}
