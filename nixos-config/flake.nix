{
  description = "Top level flake for nixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = { 
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    # hyprland = {
    #   url = "git+https://github.com/hyprwm/Hyprland?submodules=1&ref={version}";
    #   version = "0.47.1";
    # };
    # hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    hyprland.url = "github:hyprwm/Hyprland";
    hy3 = {
      url = "github:outfoxxed/hy3"; 
      inputs.hyprland.follows = "hyprland";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland"; # Prevents version mismatch.
    };
    
    # nix-index-database.url = "github:nix-community/nix-index-database";
    # nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    # nixvim.url = "github:nix-community/nixvim";
    # nix-inspect.url = "github:bluskript/nix-inspect";
    # rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    # stylix.url = "github:danth/stylix";
    # nvf = {
    #   url = "github:notashelf/nvf";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, hy3, ... }@inputs:
    let
      inherit (self) outputs;

      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      host = "nixos";
      username = "david";
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages =
        forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

      # Or 'nixpkgs-fmt'
      formatter =
        forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#hostname'
      nixosConfigurations = {
        "${host}" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit systems;
            inherit inputs;
            inherit username;
            inherit host;
            inherit outputs;
          };

          modules = [
            ./hosts/${host}/config.nix

            # inputs.stylix.nixosModules.styli

            home-manager.nixosModules.home-manager
            {
              # Apply the overlays to the NixOS system
              # nixpkgs.overlays = overlays;
              home-manager.extraSpecialArgs = {
                inherit username;
                inherit inputs;
                inherit host;
                inherit systems;
                inherit hy3;
              };

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = import ./hosts/${host}/home.nix;
            }
          ];
        };
      };
    };
}
