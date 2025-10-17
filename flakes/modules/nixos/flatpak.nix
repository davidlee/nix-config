{...}: {
  flake.nixosModules.flatpak = {...}: {
    services.flatpak.enable = true;
  };
}
