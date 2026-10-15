# Host factories. Every directory under ./hosts with a meta.nix is a host;
# meta.nix is plain data:
#
#   { kind = "nixos" | "darwin"; system = "x86_64-linux"; home = true; }
#
# `home` (nixos only) adds a standalone home-manager config,
# homeConfigurations."<username>@<hostname>", from hosts/<host>/home.nix.
# Darwin runs home-manager as a darwin module instead (see ./darwin).
#
# Each host's entry point is hosts/<host>/config.nix. Each host's features
# are resolved once (./features.nix) and every factory for that host gets the
# same selection: its legacy `flags` go in as the `features` specialArg, which
# hosts use to gate imports, and the modules the feature tree projects for the
# factory's class are appended to its `modules`. See README § Feature flags.
{
  inputs,
  self,
  ...
}: let
  inherit (inputs.nixpkgs) lib;

  username = "david";
  resolve = import ./features.nix lib;
  tree = import ./features;
  agentsOverlay = import ./overlays/agents.nix {inherit inputs;};

  hosts = lib.mapAttrs (name: _: import ./hosts/${name}/meta.nix) (
    lib.filterAttrs (name: type: type == "directory" && builtins.pathExists ./hosts/${name}/meta.nix)
    (builtins.readDir ./hosts)
  );
  hostsOf = kind: lib.filterAttrs (_: meta: meta.kind == kind) hosts;

  # The evaluations a host has, i.e. the classes a feature may land in.
  classesOf = meta:
    if meta.kind == "darwin"
    then ["darwin"]
    else ["nixos"] ++ lib.optional (meta.home or false) "homeManager";

  # extra: outer modules beyond the host's own features.nix.
  select = hostname: meta: extra: let
    host = ./hosts/${hostname}/features.nix;
  in
    resolve {
      inherit tree;
      classes = classesOf meta;
      modules = lib.optional (builtins.pathExists host) host ++ extra;
    };

  # One resolution per host, shared by all its factories, so a failed check
  # stops a home-only build as well as a system one.
  selections = lib.mapAttrs (hostname: meta: select hostname meta []) hosts;

  mkStable = system:
    import inputs.stable {
      inherit system;
      config.allowUnfree = true;
    };

  mkNixos = hostname: {system, ...}: selection:
    lib.nixosSystem {
      specialArgs = {
        inherit inputs username hostname;
        stable = mkStable system;
        features = selection.flags;
      };
      modules =
        [
          ./hosts/${hostname}/config.nix
          # mkAfter: host config.nix overlays (package fixes) apply first.
          {nixpkgs.overlays = lib.mkAfter [(agentsOverlay system)];}
        ]
        ++ selection.modules.nixos;
    };

  mkHome = hostname: {system, ...}: selection:
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
      modules =
        [
          ./hosts/${hostname}/home.nix
          {nixpkgs.overlays = [inputs.lem.overlays.default];}
        ]
        ++ selection.modules.homeManager;
      extraSpecialArgs = {
        inherit inputs username hostname;
        stable = mkStable system;
        features = selection.flags;
      };
    };

  # Darwin's embedded home-manager gets no projected modules (DEC-001).
  mkDarwin = hostname: {system, ...}: selection: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      hostPlatform = system;
      config.allowUnfree = true;
      overlays = [
        (_final: prev: {
          direnv = prev.direnv.overrideAttrs (_old: {
            doCheck = false;
          });
        })
        (_final: prev: {
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
        features = selection.flags;
      };
      modules =
        [
          {system.configurationRevision = self.rev or self.dirtyRev or null;}
          ./hosts/${hostname}/config.nix
        ]
        ++ selection.modules.darwin;
    };

  # Applies a factory to each host, with that host's shared selection.
  configure = mk: lib.mapAttrs (hostname: meta: mk hostname meta selections.${hostname});

  homes =
    lib.mapAttrs' (hostname: lib.nameValuePair "${username}@${hostname}")
    (configure mkHome (lib.filterAttrs (_: meta: meta.home or false) (hostsOf "nixos")));
in {
  flake = {
    nixosConfigurations = configure mkNixos (hostsOf "nixos");
    darwinConfigurations = configure mkDarwin (hostsOf "darwin");

    # Bare `david`: transitional alias for the pre-factory key. Drop once
    # nothing calls `.#david`.
    homeConfigurations = homes // {${username} = homes."${username}@Sleipnir";};
  };
}
