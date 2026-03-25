_: {
  flake.homeModules.bough = {
    inputs,
    pkgs,
    ...
  }: let
    bh = inputs.bough.packages.${pkgs.system};
  in {
    home.packages = [
      bh.default
    ];
  };
}
