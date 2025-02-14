{
  description = "Top level flake for nixOS configuration";

  nixConfig = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    # download-buffer-size = 500000000;

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
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url   = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs.url          = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = { 
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix.url = "github:helix-editor/helix/master";

    walker.url = "github:abenz1267/walker";

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hyprland.url = "github:hyprwm/Hyprland?submodules=1";
    hyprland.url = "github:hyprwm/Hyprland?ref=v0.47.2";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hy3 = {
      url = "github:outfoxxed/hy3?rev=hl0.47.0-1"; 
      inputs.hyprland.follows = "hyprland";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland"; 
    };
    
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nixpkgs-stable,
    lix-module,
    home-manager,
    ...
}:
  let
    inherit (self) outputs;

    systems = [
      "x86_64-linux"
      "aarch64-darwin"
      # "aarch64-linux"
      # "i686-linux"
      # "x86_64-darwin"
    ];

    host = "nixos";
    username = "david";

    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    overlays =  import ./overlays { inherit inputs; };

    nixosModules = import ./nixos;
    userModules = import ./home;

    nixpkgs.overlays = [
      inputs.nixpkgs-wayland.overlay
      
      # DWL
      (final: prev: {
        # dwl = prev.dwl.overrideAttrs { patches = [ ./dwl-patches/config.patch ]; };
      }) 

      # pin packages to nixpkgs-stable
      (self: super: {
        # lldb = nixpkgs-stable.lldb;
      })
    ];

    nixosConfigurations = {
      "${host}" = nixpkgs.lib.nixosSystem {

        specialArgs = {
          inherit systems;
          inherit inputs;
          inherit username;
          inherit host;
          inherit outputs;
          
          pkgs-stable = import nixpkgs-stable {
            config.allowUnfree = true;
          };
        };

        modules = [
          ./hosts/${host}/config.nix
          lix-module.nixosModules.default

          home-manager.nixosModules.home-manager
          {

            home-manager.extraSpecialArgs = {
              inherit username;
              inherit inputs;
              inherit host;
              inherit systems;
            };

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./hosts/${host}/home.nix;
          }
        ];
      };
    };

    # standalone home-manager
    homeConfigurations = {
      "${host}" = nixpkgs.lib.nixosSystem {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs outputs;
          inherit host username;
          inherit systems;
        };
        useGlobalPkgs = true;
        usUserPackages = true;
        backupFileExtension = "backup";

        modules = [
          ./hosts/${host}/home.nix
        ];
      };
    };
  };
}
