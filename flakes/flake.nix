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

    nixarr.url = "github:rasmus-kirk/nixarr";

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # update AMD microcode
    ucodenix.url = "github:e-tho/ucodenix";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      inherit (self) outputs;
    in
  {
    nixosConfigurations = let
      hostname = "Sleipnir";
      username = "david";
    in {
    
      # nixpkgs.overlays = [ inputs.nixpkgs-wayland.overlay ];

      "${hostname}" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs username hostname; };

        modules = [
          ./hosts/${hostname}/config.nix

          inputs.home-manager.nixosModules.home-manager {
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
