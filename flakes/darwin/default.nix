{
  inputs,
  pkgs,
  username,
  hostname,
  ...
}: let
  specialArgs = {
    inherit
      inputs
      pkgs
      username
      hostname
      ;
  };
in {
  imports = [
    ./system.nix
    ./nix-core.nix
    ./brew.nix
    ./packages.nix

    inputs.home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = specialArgs;
      home-manager.backupFileExtension = "backup";
      home-manager.users.${username} = import ./home.nix;
    }
  ];

  nix.package = pkgs.lixPackageSets.stable.lix;
}
