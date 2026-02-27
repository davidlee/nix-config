_: {
  flake.homeModules.ai = {
    inputs,
    pkgs,
    ...
  }: {
    home.packages = [
      inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
