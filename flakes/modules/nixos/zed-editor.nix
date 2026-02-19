_: {
  flake.nixosModules.zed-editor = {
    inputs,
    pkgs,
    ...
  }: {
    environment.systemPackages =
      if false
      then [inputs.zed.packages.${pkgs.stdenv.hostPlatform.system}.default]
      else [pkgs.zed-editor];
  };
}
