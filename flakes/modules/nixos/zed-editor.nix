_: {
  flake.nixosModules.zed-editor = {
    inputs,
    system,
    ...
  }: {
    environment.systemPackages = [
      inputs.zed-editor-flake.packages.${system}.zed-editor
    ];
  };
}
