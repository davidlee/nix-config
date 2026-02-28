_: {
  flake.nixosModules.rocm = {...}: {
    nixpkgs.config.rocmSupport = true;
  };
}
