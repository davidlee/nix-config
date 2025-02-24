{
  description = "Top level flake for nixOS configuration";

  inputs = {
    nixpkgs-stable.url   = "github:nixos/nixpkgs/nixos-24.11";

    nixpkgs.url          = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "nixos-cosmic/nixpkgs";

    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";

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
        
    helix.url = "github:helix-editor/helix/master";
    walker.url = "github:abenz1267/walker";

    # nixpkgs-wayland = {
    #   url = "github:nix-community/nixpkgs-wayland";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # nixvim = {
    #   url = "github:nix-community/nixvim";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # hyprland.url = "github:hyprwm/Hyprland?ref=v0.47.2";

    # hy3 = {
    #   url = "github:outfoxxed/hy3?rev=hl0.47.0-1"; 
    #   inputs.hyprland.follows = "hyprland";
    # };
    
    # nur = {
    #     url = "github:nix-community/NUR";
    #     inputs.nixpkgs.follows = "nixpkgs";
    # };

    # hyprland-plugins = {
    #   url = "github:hyprwm/hyprland-plugins";
    #   inputs.hyprland.follows = "hyprland"; 
    # };
  };

  outputs = {
    self,
    nixpkgs,
    # nixpkgs-stable,
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
  in {
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    nixosModules = import ./nixos;
    userModules = import ./home;
 
    nixosConfigurations = {
      "${hostname}" = nixpkgs.lib.nixosSystem {

        specialArgs = {
          inherit systems inputs username useremail hostname outputs;
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
