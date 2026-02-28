_: {
  flake.homeModules.helix = {
    pkgs,
    inputs,
    ...
  }: {
    home.packages = [
      inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
