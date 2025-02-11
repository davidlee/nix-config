{
  description = "Top level flake for nixOS configuration";


  nixConfig = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];

    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://walker.cachix.org"
      "https://walker-git.cachix.org"
      "https://cache.nixos.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
      "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = { 
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    walker.url = "github:abenz1267/walker";

    hyprland.url = "github:hyprwm/Hyprland?submodules=1";

    hy3 = {
      url = "github:outfoxxed/hy3"; 
      inputs.hyprland.follows = "hyprland";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland"; 
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
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
      
      overlays =  import ./overlays { inherit inputs; };
      nixpkgs.overlays = [
        inputs.nixpkgs-wayland.overlay
      ];

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
            # inherit hy3;
          };

          modules = [
            ./hosts/${host}/config.nix
            {
            }

            # inputs.stylix.nixosModules.styli

            home-manager.nixosModules.home-manager
            {
 
              # Apply the overlays to the NixOS system
              # nixpkgs.overlays = overlays;

              # pass extra args to home.nix
              home-manager.extraSpecialArgs = {
                inherit username;
                inherit inputs;
                inherit host;
                inherit systems;
                # inherit hy3;
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
