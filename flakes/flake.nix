{
  description = "machine songs";

  inputs = {

    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
      follows = "nixos-cosmic/nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = { 
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-1.tar.gz";
      # url = "https://git.lix.systems/lix-project/nixos-module.git";
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

    ucodenix.url = "github:e-tho/ucodenix";
  };

  outputs = inputs@{ self, nixpkgs, darwin, home-manager, ... }:
    let
      inherit (self) outputs;
    in
  {

    darwinConfigurations = let
      username = "davidlee";
      hostname = "fusillade";
      system = "aarch64-darwin";

      configuration = { pkgs, ... }: {
        system.configurationRevision = self.rev or self.dirtyRev or null;
        system.stateVersion = 6;
      };

      specialArgs = { inherit inputs outputs username hostname; };
    in {
      "${hostname}" = inputs.darwin.lib.darwinSystem {
        
        modules = [
          configuration
          ./darwin
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./darwin/home;
          }
        ];
      };
    };
      
    nixosConfigurations = let
      hostname = "Sleipnir";
      username = "david";
      specialArgs = { inherit inputs outputs username hostname; };
    in {
      "${hostname}" = nixpkgs.lib.nixosSystem {

        modules = [
          ./hosts/${hostname}/config.nix
          inputs.home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = import ./hosts/${hostname}/home.nix; # TODO move to /hosts/Sleipnir.nix
          }
        ];
      };
    };
  };
}
