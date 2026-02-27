{
  description = "home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    parent.url = "path:..";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = {
    nixpkgs,
    parent,
    home-manager,
    ...
  } @ inputs: {
    homeConfigurations.david = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [parent.homeModules.Sleipnir];
      extraSpecialArgs = {
        self = parent;
        inherit inputs;
        username = "david";
      };
    };
  };
}
