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
      "https://cosmic.cachix.org"
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
    nixpkgs-stable.url   = "github:nixos/nixpkgs/nixos-24.11";

    nixpkgs.url          = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "nixos-cosmic/nixpkgs";

    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";

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

    hyprland.url = "github:hyprwm/Hyprland?ref=v0.47.2";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hy3 = {
      url = "github:outfoxxed/hy3?rev=hl0.47.0-1"; 
      inputs.hyprland.follows = "hyprland";
    };
    
    # nur = {
    #     url = "github:nix-community/NUR";
    #     inputs.nixpkgs.follows = "nixpkgs";
    # };
    # zen-browser = {
    #   url = "github:youwen5/zen-browser-flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
        
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland"; 
    };
    
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    lix-module,
    home-manager,
    nixos-cosmic,
    darwin,
    ...
} @ inputs:

  let
    inherit (self) outputs;

    systems = [
      "x86_64-linux"
      "aarch64-darwin"
    ];

    hostname = "nixos";
    username = "david";
    useremail = "admin@davlee.com";

    forAllSystems = nixpkgs.lib.genAttrs systems;

    lib = nixpkgs.lib;
    
  in {
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    overlays =  import ./overlays { inherit inputs; };

    nixosModules = import ./nixos;
    userModules = import ./home;
 
    nixpkgs.overlays = [
      inputs.nixpkgs-wayland.overlay
      
      (final: prev: {
        dwl = prev.dwl.override { conf = ./overlays/patches/dwl/config.h; };
      })

      # # pin packages to nixpkgs-stable
      # (final: prev: {
      #   # lldb = nixpkgs-stable.lldb;
      # })
    ];

    nixosConfigurations = {
      "${hostname}" = nixpkgs.lib.nixosSystem {

        specialArgs = {
          inherit systems inputs username useremail hostname outputs;
          
          pkgs-stable = import nixpkgs-stable {
            config.allowUnfree = true;
          };
        };

        modules = [
          ./hosts/${hostname}/config.nix
          lix-module.nixosModules.default
          nixos-cosmic.nixosModules.default
          home-manager.nixosModules.home-manager
          {

            home-manager.extraSpecialArgs = {
              inherit systems inputs username useremail hostname outputs;
            };

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./hosts/${hostname}/home.nix;
          }
        ];
      };
    };

    # standalone home-manager
    homeConfigurations = {
      "${hostname}" = nixpkgs.lib.nixosSystem {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit systems inputs username useremail hostname outputs;
        };
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";

        modules = [
          ./hosts/${hostname}/home.nix
        ];
      };
    };
  };
}
