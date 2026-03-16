_: {
  flake.homeModules.bough = {
    inputs,
    pkgs,
    ...
  }: let
    vk = inputs.bough.packages.${pkgs.system};
  in {
    home.packages = [
      vk.bough
      vk.arbourd
      vk.arbour
    ];
  };
}
