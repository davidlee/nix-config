{
  description = "home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({...}: {
      imports = [
        inputs.treefmt-nix.flakeModule
        ../modules/home-modules.nix
        (inputs.import-tree ../modules/home)
      ];

      systems = ["x86_64-linux"];

      perSystem = _: {
        treefmt.programs.alejandra.enable = true;
        treefmt.programs.statix.enable = true;
      };

      flake.homeConfigurations.david = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [self.homeModules.Sleipnir];
        extraSpecialArgs = {
          inherit self inputs;
          username = "david";
        };
      };
    });
}
