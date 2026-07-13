{
  description = "machine songs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-home.url = "github:nixos/nixpkgs/nixos-unstable";
    stable.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-home";
    };

    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
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

    emacs-overlay = {
      url = "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
    };

    # To bump: change the tag below, then `nix flake update llama-cpp-src`.
    # The build number is derived from this ref in modules/overlays/llama-edge.nix.
    llama-cpp-src = {
      url = "github:ggml-org/llama.cpp/b8660";
      flake = false;
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    nix-search-tv.url = "github:3timeslazy/nix-search-tv";
    zig-overlay.url = "github:mitchellh/zig-overlay";
    zls-overlay.url = "github:zigtools/zls";
    # bough.url = "git+ssh://git@github.com/davidlee/vk";
    ucodenix.url = "github:e-tho/ucodenix";
    zed.url = "github:zed-industries/zed";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-home";
    };

    panopticon = {
      url = "path:/home/david/dev/panopticon";
      inputs.nixpkgs.follows = "nixpkgs-home";
    };

    satan = {
      # url = "path:/home/david/dev/satan";
      url = "github:davidlee/satan";
      inputs.nixpkgs.follows = "nixpkgs-home";
    };

    satan-patcher = {
      url = "path:/home/david/dev/satan-patcher";
      inputs.nixpkgs.follows = "nixpkgs-home";
    };

    satan-attrd = {
      url = "path:/home/david/dev/satan-attrd";
      inputs.nixpkgs.follows = "nixpkgs-home";
    };

    lem = {
      url = "github:lem-project/lem";
      inputs.nixpkgs.follows = "nixpkgs-home";
    };

    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # niri-float-sticky = {
    #   url = "github:probeldev/niri-float-sticky";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae.url = "github:vicinaehq/vicinae";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({...}: {
      imports = [
        inputs.treefmt-nix.flakeModule
        ./overlays.nix
        ./modules/home-modules.nix
        ./modules/darwin-modules.nix
        (inputs.import-tree ./modules/home)
        (inputs.import-tree ./modules/nixos)
        (inputs.import-tree ./modules/shared)
      ];

      systems = ["x86_64-linux" "aarch64-darwin"];

      perSystem = _: {
        treefmt.programs.alejandra.enable = true;
        treefmt.programs.statix.enable = true;
      };

      flake = {
        templates = {
          agents = {
            path = ./_templates/agents;
            description = "Dev shell with jailed LLM agents";
          };
          default = self.templates.agents;
        };

        nixosConfigurations = let
          hostname = "Sleipnir";
          username = "david";
          system = "x86_64-linux";
          stable = import inputs.stable {
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
              {nixpkgs.overlays = [self.overlays.llama-edge self.overlays.whisper-rocm self.overlays.click-threading-fix];}
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
            overlays = [
              inputs.emacs-overlay.overlays.default
              (final: prev: {
                direnv = prev.direnv.overrideAttrs (old: {
                  doCheck = false;
                });
              })
              (final: prev: {
                inherit
                  (prev.lixPackageSets.stable)
                  nixpkgs-review
                  nix-eval-jobs
                  nix-fast-build
                  colmena
                  ;
              })
            ];
          };

          specialArgs = {
            inherit self inputs pkgs username hostname system;
            inherit (self) outputs;
          };
        in {
          "${hostname}" = inputs.darwin.lib.darwinSystem {
            inherit pkgs specialArgs;
            modules = [
              {hostPlatform.system.configurationRevision = self.rev or self.dirtyRev or null;}
              ./darwin
            ];
          };
        }; # Darwin

        homeConfigurations = let
          username = "david";
          system = "x86_64-linux";
          pkgs = import inputs.nixpkgs-home {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              inputs.emacs-overlay.overlays.default
            ];
          };
          stable = import inputs.stable {
            inherit system;
            config.allowUnfree = true;
          };
        in {
          "${username}" = inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [self.homeModules.Sleipnir];
            extraSpecialArgs = {
              inherit self inputs username stable;
            };
          };
        };
      }; # flake
    });
}
