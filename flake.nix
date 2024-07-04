{
  description = "Nix for MacOS configuration";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      # url = "github:nix-community/home-manager/release-24.05";
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # gitu.url = "github:altsem/gitu";
  };

  outputs = inputs @ {
    self,
    darwin,
    home-manager,
    nixpkgs,
    ...
    # gitu
  }: let
    username = "davidlee";
    useremail = "admin@davlee.com";
    hostname = "fusillade";
    system   = "aarch64-darwin";

    specialArgs =
      inputs
      // {
        inherit username useremail hostname;
      };
 in {
    darwinConfigurations."${hostname}" = darwin.lib.darwinSystem {
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };


      inherit system specialArgs;
      modules = [
        ./modules/nix-core.nix
        ./modules/system.nix
        ./modules/apps.nix
        ./modules/host-users.nix
       # home manager
       home-manager.darwinModules.home-manager
       {
         home-manager.useGlobalPkgs = true;
         home-manager.useUserPackages = true;
         home-manager.extraSpecialArgs = specialArgs;
         home-manager.users.${username} = import ./home;
         # home-manager.users.davidlee = import ./home;
         # FIXME
         home-manager.backupFileExtension = "nixed";
       }

      ]; # modules
    };
    darwinPackages = self.darwinConfigurations."fusillade".pkgs;

    # nix code formatter
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
