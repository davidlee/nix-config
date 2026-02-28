_: {
  flake.nixosModules.rocm = _: {
    nixpkgs.config.rocmSupport = true;
  };
}
