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

    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };

    nix-search-tv = {
      url = "github:3timeslazy/nix-search-tv";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    zig-overlay.url = "github:mitchellh/zig-overlay";
    zls-overlay.url = "github:zigtools/zls";
    ucodenix.url = "github:e-tho/ucodenix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  # outputs = inputs: flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  outputs = inputs @ {
    self,
    nixpkgs,
    nix-stable,
    home-manager,
    flake-parts,
    darwin,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} (top @ {
      config,
      withSystem,
      moduleWithSystem,
      ...
    }: {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.home-manager.flakeModules.home-manager
        (inputs.import-tree ./modules)
        # ./modules/nixos/ai.nix
      ];

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      perSystem = {
        config,
        pkgs,
        ...
      }: {
        treefmt.programs.alejandra.enable = true;
      };

      flake = {
        nixosConfigurations = let
          hostname = "Sleipnir";
          username = "david";
          system = "x86_64-linux";

          stable = import nix-stable {
            inherit system;
            config.allowUnfree = true;
          };

          specialArgs = {
            inherit self inputs username hostname system stable;
            outputs = self.outputs;
          };
        in {
          "${hostname}" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;

            modules = [
              # nixos
              ./hosts/${hostname}/config.nix

              # home manager
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = specialArgs;
                home-manager.backupFileExtension = "backup";
                home-manager.users.${username} = import ./hosts/${hostname}/home.nix;
              }
            ];
          }; # Sleipnir
        }; # nixosConfigurations

        darwinConfigurations = let
          username = "davidlee";
          hostname = "fusillade";
          system = "aarch64-darwin";

          pkgs = import nixpkgs {
            inherit system;
            hostPlatform = system;
            config.allowUnfree = true;
          };

          specialArgs = {
            inherit self inputs pkgs username hostname system;
            outputs = self.outputs;
          };
        in {
          "${hostname}" = darwin.lib.darwinSystem {
            inherit pkgs specialArgs;
            modules = [
              {system.configurationRevision = self.rev or self.dirtyRev or null;}
              ./darwin
            ];
          };
        };
      };
    });
}
