{
  inputs,
  outputs,
  pkgs,
  username,
  hostname,
  system,
  ...
}: let
  specialArgs = {inherit inputs outputs pkgs username hostname system;};
in {
  imports = [
    ./system.nix
    ./nix-core.nix
    ./brew.nix
    ./packages.nix

    ../modules/nixCats.nix

    inputs.lix-module.nixosModules.default

    inputs.home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = specialArgs;
      home-manager.backupFileExtension = "backup";
      home-manager.users.${username} = import ./home.nix;
    }

    ../modules/zig.nix
  ];
}
