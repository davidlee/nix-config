_: {
  flake.homeModules.zed-editor = {
    inputs,
    pkgs,
    ...
  }: {
    home.packages =
      if false
      then [inputs.zed.packages.${pkgs.stdenv.hostPlatform.system}.default]
      else [pkgs.zed-editor];
  };
}
