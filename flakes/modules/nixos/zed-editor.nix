_: {
  flake.nixosModules.zed-editor = {
    inputs,
    system,
    pkgs,
    ...
  }: {
    environment.systemPackages =
      if false
      then [inputs.zed.packages.${system}.default]
      else [pkgs.zed-editor];
  };
}
