{
  inputs,
  outputs,
  pkgs,
  username,
  hostname,
  system,
  ...
}: let
  specialArgs = {
    inherit
      inputs
      outputs
      pkgs
      username
      hostname
      system
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
    
  nixpkgs.overlays = [
    (final: prev: {
      inherit
        (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];

  nix.package = pkgs.lixPackageSets.stable.lix;
}
