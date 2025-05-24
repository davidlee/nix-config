{inputs, ... }: {
  imports = [
    ./system.nix
    ./nix-core.nix
    ./brew.nix
    # inputs.nixvim.nixDarwinModules.nixvim
  ];

}
