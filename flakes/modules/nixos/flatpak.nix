_: {
  flake.nixosModules.flatpak = _: {
    services.flatpak.enable = true;
  };
}
