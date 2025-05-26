{ inputs, ... }: {
  imports = [
    ./system.nix
    ./nix-core.nix
    ./brew.nix
    ./packages.nix

    inputs.lix-module.nixosModules.default 
    
    ../nixos/zig.nix
  ];
}
