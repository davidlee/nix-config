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

    nixarr.url = "github:rasmus-kirk/nixarr";

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

    # FIXME fails at runtime. Probably requires me to change approach to modules;
    # assuming it can work in principle
    # 
    homeConfigurations = let
      hostname = "Sleipnir";
      username = "david";
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      "${username}" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs outputs username hostname; };       
        modules = [
          ./hosts/${hostname}/home.nix         
          ./shared/packages.nix
        ];
      };
    };

    darwinConfigurations = let
      hostname = "fusillade";
      username = "davidlee";
      specialArgs = { inherit inputs outputs username hostname; };
    in {
      "${hostname}" = inputs.darwin.lib.darwinSystem {
        pkgs = import nixpkgs;
      
        modules = [
          ./darwin/nix-core.nix
          ./darwin/system.nix
          ./darwin/apps.nix
          ./darwin/host-users.nix
          ./darwin/brew.nix
          
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${username} = import ./home;
          }
        ]; 
      };
    };
  };
}
