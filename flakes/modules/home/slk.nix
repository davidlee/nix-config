_: {
  flake.homeModules.slk = {
    inputs,
    pkgs,
    ...
  }: {
    home.packages = [
      inputs.slk.packages.${pkgs.system}.default
    ];
  };
}
