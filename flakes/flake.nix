{
  description = "machine songs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    helix = {
      url = "github:helix-editor/helix/master";
      inputs.nixpkgs.follows = "nixpkgs";
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
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    zig-overlay.url = "github:mitchellh/zig-overlay";
    zls-overlay.url = "github:zigtools/zls";

    nixarr.url = "github:rasmus-kirk/nixarr";
    ucodenix.url = "github:e-tho/ucodenix";
    raise.url = "github:knarkzel/raise";

    #
    # ramalama.url = "github:containers/ramalama/main";
  };

  #
  # NixOS
  #
  outputs = inputs @ {
    self,
    nixpkgs,
    nix-stable,
    home-manager,
    ...
  }: {
    nixosConfigurations = let
      inherit (self) outputs;

      hostname = "Sleipnir";
      username = "david";
      system = "x86_64-linux";
      stable = import nix-stable {
        inherit system;
        config.allowUnfree = true;
      };

      specialArgs = {
        inherit
          inputs
          outputs
          username
          hostname
          stable
          system
          ;
      };
    in {
      "${hostname}" = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          ./hosts/${hostname}/config.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./hosts/${hostname}/home.nix;
          }
        ];
      };
    };

    #
    # DARWIN
    #
    darwinConfigurations = let
      inherit (self) outputs;
      username = "davidlee";
      hostname = "fusillade";
      system = "aarch64-darwin";
      specialArgs = {
        inherit
          inputs
          outputs
          username
          hostname
          ;
      };
      pkgs = import nixpkgs {
        inherit system;
        hostPlatform = system;
        config.allowUnfree = true;
      };
    in {
      "${hostname}" = inputs.darwin.lib.darwinSystem {
        inherit pkgs specialArgs;
        modules = [
          {system.configurationRevision = self.rev or self.dirtyRev or null;}
          ./darwin
        ];
      };
    };
  };
}
