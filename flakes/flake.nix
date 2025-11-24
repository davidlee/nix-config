{
  description = "machine songs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      url = "github:helix-editor/helix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    raise.url = "github:svelterust/raise";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    nix-search-tv.url = "github:3timeslazy/nix-search-tv";
    zig-overlay.url = "github:mitchellh/zig-overlay";
    zls-overlay.url = "github:zigtools/zls";
    ucodenix.url = "github:e-tho/ucodenix";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    zed.url = "github:zed-industries/zed";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({...}: {
      imports = with inputs; [
        inputs.treefmt-nix.flakeModule
        inputs.home-manager.flakeModules.home-manager
        (inputs.import-tree ./modules)
      ];

      systems = ["x86_64-linux" "aarch64-darwin"];

      perSystem = _: {
        treefmt.programs.alejandra.enable = true;
        treefmt.programs.statix.enable = true;
      };

      flake = {
        nixosConfigurations = let
          hostname = "Sleipnir";
          username = "david";
          system = "x86_64-linux";
          stable = import inputs.nix-stable {
            inherit system;
            config.allowUnfree = true;
          };

          specialArgs = {
            inherit self inputs username hostname system stable;
            inherit (self) outputs;
          };
        in {
          "${hostname}" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;

            modules = [
              ./hosts/${hostname}/config.nix
              self.nixosModules.home-manager
            ];
          };
        };

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
            inherit (self) outputs;
          };
        in {
          "${hostname}" = inputs.darwin.lib.darwinSystem {
            inherit pkgs specialArgs;
            modules = [
              {system.configurationRevision = self.rev or self.dirtyRev or null;}
              ./darwin
            ];
          };
        }; # Darwin
      }; # flake
    });
}
