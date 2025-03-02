{
  description = "machine songs";

  inputs = {

    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    home-manager = { 
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
        
    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      inherit (self) outputs;
      hostname = "Sleipnir";
      username = "david";
    in
  {

    nixosConfigurations = {
      "${hostname}" = nixpkgs.lib.nixosSystem {

        specialArgs = {
          inherit inputs outputs username hostname;
        };

        modules = [
          ./hosts/${hostname}/config.nix
          ./modules/gnome.nix

          inputs.home-manager.nixosModules.home-manager
          {

            home-manager.extraSpecialArgs = { inherit inputs outputs username hostname; };

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./hosts/${hostname}/home.nix;
          }
        ];
      };
    };
  };
}
