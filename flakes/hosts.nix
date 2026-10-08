# Host factories. Every directory under ./hosts with a meta.nix is a host;
# meta.nix is plain data:
#
#   { kind = "nixos" | "darwin"; system = "x86_64-linux"; home = true; }
#
# `home` (nixos only) adds a standalone home-manager config,
# homeConfigurations."<username>@<hostname>", from hosts/<host>/home.nix.
# Darwin runs home-manager as a darwin module instead (see ./darwin).
#
# Each host's entry point is hosts/<host>/config.nix. Feature flags are
# resolved per host (./features.nix) and passed as a specialArg so they can
# gate imports. See README § Feature flags.
{
  inputs,
  self,
  ...
}: let
  inherit (inputs.nixpkgs) lib;

  username = "david";
  mkFeatures = import ./features.nix lib;
  agentsOverlay = import ./overlays/agents.nix {inherit inputs;};

  hosts = lib.mapAttrs (name: _: import ./hosts/${name}/meta.nix) (
    lib.filterAttrs (name: type: type == "directory" && builtins.pathExists ./hosts/${name}/meta.nix)
    (builtins.readDir ./hosts)
  );
  hostsOf = kind: lib.filterAttrs (_: meta: meta.kind == kind) hosts;

  mkStable = system:
    import inputs.stable {
      inherit system;
      config.allowUnfree = true;
    };

  mkNixos = hostname: {system, ...}:
    lib.nixosSystem {
      specialArgs = {
        inherit inputs username hostname;
        stable = mkStable system;
        features = mkFeatures hostname;
      };
      modules = [
        ./hosts/${hostname}/config.nix
        {nixpkgs.overlays = [(agentsOverlay system)];}
      ];
    };

  mkHome = hostname: {system, ...}:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs-home {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          inputs.claude-desktop.overlays.default
          (agentsOverlay system)
          inputs.llm-agents.overlays.shared-nixpkgs
        ];
      };
      modules = [
        ./hosts/${hostname}/home.nix
        {nixpkgs.overlays = [inputs.lem.overlays.default];}
      ];
      extraSpecialArgs = {
        inherit inputs username hostname;
        stable = mkStable system;
        features = mkFeatures hostname;
      };
    };

  mkDarwin = hostname: {system, ...}: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      hostPlatform = system;
      config.allowUnfree = true;
      overlays = [
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
  in
    inputs.darwin.lib.darwinSystem {
      inherit pkgs;
      specialArgs = {
        inherit inputs pkgs username hostname;
        features = mkFeatures hostname;
      };
      modules = [
        {system.configurationRevision = self.rev or self.dirtyRev or null;}
        ./hosts/${hostname}/config.nix
      ];
    };

  homes =
    lib.mapAttrs' (hostname: meta: lib.nameValuePair "${username}@${hostname}" (mkHome hostname meta))
    (lib.filterAttrs (_: meta: meta.home or false) (hostsOf "nixos"));
in {
  flake = {
    nixosConfigurations = lib.mapAttrs mkNixos (hostsOf "nixos");
    darwinConfigurations = lib.mapAttrs mkDarwin (hostsOf "darwin");

    # Bare `david`: transitional alias for the pre-factory key. Drop once
    # nothing calls `.#david`.
    homeConfigurations = homes // {${username} = homes."${username}@Sleipnir";};
  };
}
