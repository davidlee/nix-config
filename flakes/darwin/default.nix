{username, hostname, ... }: {

  imports = [
    # ./host-users.nix
    # ./apps.nix
    ./system.nix
    ./nix-core.nix
    ./brew.nix
  ];

}
