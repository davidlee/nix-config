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
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-3.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
        
    # fenix = {
    #   url = "github:nix-community/fenix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nixarr.url = "github:rasmus-kirk/nixarr";
    ucodenix.url = "github:e-tho/ucodenix";
  };

  outputs = inputs@{ self, nixpkgs, darwin, home-manager, ... }: {

    darwinConfigurations = let
      inherit (self) outputs;
      username = "davidlee";
      hostname = "fusillade";
      system = "aarch64-darwin";

      specialArgs = { inherit inputs outputs username hostname; };

      pkgs = import nixpkgs {
        inherit system;
        hostPlatform = system;
        config.allowUnfree = true;
      };
    in {
      "${hostname}" = inputs.darwin.lib.darwinSystem {
        inherit pkgs specialArgs;
       
        modules = [
          ./darwin
          { system.configurationRevision = self.rev or self.dirtyRev or null; }
  
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./darwin/home.nix;
          }
        ];
      };
    };
      
    nixosConfigurations = let
      inherit (self) outputs;
      hostname = "Sleipnir";
      username = "david";
      specialArgs = { inherit inputs outputs username hostname; };
    in {
      "${hostname}" = nixpkgs.lib.nixosSystem {
        inherit specialArgs;

        modules = [
          ./hosts/${hostname}/config.nix
          inputs.home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = import ./hosts/${hostname}/home.nix;
          }
        ];
      };
    };
  };
}
