{ ... }: {
  modules = [
    ./nix-core.nix
    ./system.nix
    ./apps.nix
    ./host-users.nix
    ./brew.nix
  ];
}
