{ ... }: {
  imports = [
    ./system.nix
    ./nix-core.nix
    ./brew.nix
    ./packages.nix

    ../nixos/zig.nix
  ];
}
