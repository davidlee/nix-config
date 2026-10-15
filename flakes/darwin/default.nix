{
  imports = [
    ./system.nix
    ./brew.nix
    ./packages.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # Preserve the existing installer-managed Lix and its daemon configuration.
  nix.enable = false;
}
