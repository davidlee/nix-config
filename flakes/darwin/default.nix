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
    ./brew.nix
    ./packages.nix

    inputs.home-manager.darwinModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = specialArgs;
        backupFileExtension = "backup";
        users.${username} = import ./home.nix;
      };
    }
  ];

  # Preserve the existing installer-managed Lix and its daemon configuration.
  nix.enable = false;
}
