{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = { 
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nix-darwin, nixpkgs, home-manager }:
  let
    username = "davidlee";
    hostname = "fusillade";
    specialArgs = { inherit username hostname inputs; };

    configuration = { pkgs, ... }: {
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
    };
  in
  {
    darwinConfigurations."${hostname}" = nix-darwin.lib.darwinSystem {
      inherit specialArgs;
      
      pkgs = import nixpkgs {
        hostPlatform = "aarch64-darwin";
        system = "aarch64-darwin";
        config.allowUnfree = true; 
      };
      
      modules = [ 
          ./nix-core.nix
          ./system.nix
          ./apps.nix
          ./host-users.nix
          ./brew.nix
          
        configuration 
        ./system.nix
        inputs.home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${username} = import ../hosts/${hostname}/home.nix;
        }
      ];
    };
  };
}
