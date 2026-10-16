# Host factories. Every directory under ./hosts with a meta.nix is a host;
# meta.nix is plain data:
#
#   { kind = "nixos" | "darwin"; system = "x86_64-linux"; home = true; }
#
# `home` adds a standalone home-manager config,
# homeConfigurations."<username>@<hostname>", from hosts/<host>/home.nix, on
# either kind (DEC-017).
#
# Each host's entry point is hosts/<host>/config.nix. Each host's features
# are resolved once (./features.nix) and every factory for that host gets the
# same selection: the modules the feature tree projects for the factory's
# class are appended to its `modules`. See README § Features.
#
# The rule (DEC-016): a factory supplies host identity (`args`) plus one
# injected module; the evaluator builds pkgs. Local package fixes are modules
# beside their consumer. `stable` (nixos-24.11) is a module argument, not a
# specialArg and not a pkgs attribute: callPackage would feed a `pkgs.stable`
# to every `stable ? …` default (mem.fact.nix.callpackage-autoargs).
#
# `coverage` holds ADR-005 targets: configurations that select a feature no
# switchable host selects, or the NixOS base (`base@aarch64-linux`) or home
# base (`home@aarch64-linux`) alone, so `just coverage` proves they still
# evaluate. They are off every switch path and outside `just drvs`.
{
  inputs,
  self,
  config,
  ...
}: let
  inherit (inputs.nixpkgs) lib;

  username = "david";
  resolve = import ./features.nix lib;
  tree = import ./features {inherit lib;};
  # system -> overlay. See ./overlays/agents.nix.
  agentsOverlay = import ./overlays/agents.nix {inherit inputs;};
  linuxSystems = lib.filter (lib.hasSuffix "-linux") config.systems;

  hosts = lib.mapAttrs (name: _: import ./hosts/${name}/meta.nix) (
    lib.filterAttrs (name: type: type == "directory" && builtins.pathExists ./hosts/${name}/meta.nix)
    (builtins.readDir ./hosts)
  );
  hostsOf = kind: lib.filterAttrs (_: meta: meta.kind == kind) hosts;

  # The evaluations a host has, i.e. the classes a feature may land in:
  # its kind (which names its system class), plus homeManager with a home.
  classesOf = meta: [meta.kind] ++ lib.optional (meta.home or false) "homeManager";

  # extra: outer modules beyond the host's own features.nix.
  select = hostname: meta: extra: let
    host = ./hosts/${hostname}/features.nix;
  in
    resolve {
      inherit tree;
      classes = classesOf meta;
      inherit (meta) system;
      modules = lib.optional (builtins.pathExists host) host ++ extra;
    };

  # One resolution per host, shared by all its factories, so a failed check
  # stops a home-only build as well as a system one.
  selections = lib.mapAttrs (hostname: meta: select hostname meta []) hosts;

  # Host identity: specialArgs (system evaluations), extraSpecialArgs (home).
  args = hostname: {inherit inputs username hostname;};

  stableModule = system: {
    _module.args.stable = import inputs.stable {
      inherit system;
      config.allowUnfree = true;
    };
  };

  # Injected into system evaluations.
  platformModule = meta: {
    nixpkgs.hostPlatform = meta.system;
    # mkAfter: host config.nix overlays (package fixes) apply first.
    nixpkgs.overlays = lib.mkAfter [(agentsOverlay meta.system)];
    imports = [(stableModule meta.system)];
  };

  mkNixos = hostname: meta: selection:
    lib.nixosSystem {
      specialArgs = args hostname;
      modules =
        [
          ./hosts/${hostname}/config.nix
          (platformModule meta)
        ]
        ++ selection.modules.nixos;
    };

  # Injected into home evaluations. Home Manager re-imports nixpkgs from
  # config.nixpkgs, putting module overlays before pkgs.overlays; this list
  # keeps the order the factory-built pkgs had.
  homeModule = system: {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [
      inputs.lem.overlays.default
      inputs.claude-desktop.overlays.default
      (agentsOverlay system)
      inputs.llm-agents.overlays.shared-nixpkgs
    ];
    imports = [(stableModule system)];
  };

  # Bare import, not legacyPackages: that carries nixpkgs' flake-only lib
  # overlay, which Home Manager would inherit (RV-009 F-6).
  mkHome = hostname: {system, ...}: selection:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs-home {inherit system;};
      modules =
        [
          (homeModule system)
          ./hosts/${hostname}/home.nix
        ]
        ++ selection.modules.homeManager;
      extraSpecialArgs = args hostname;
    };

  # No pkgs: nix-darwin builds them from nixpkgs.source (darwin follows our
  # nixpkgs), so module overlays reach module pkgs (ISS-004).
  mkDarwin = hostname: meta: selection:
    inputs.darwin.lib.darwinSystem {
      specialArgs = args hostname;
      modules =
        [
          {system.configurationRevision = self.rev or self.dirtyRev or null;}
          ./hosts/${hostname}/config.nix
          (platformModule meta)
        ]
        ++ selection.modules.darwin;
    };

  # Applies a factory to each host, with that host's shared selection.
  configure = mk: lib.mapAttrs (hostname: meta: mk hostname meta selections.${hostname});

  homes =
    lib.mapAttrs' (hostname: lib.nameValuePair "${username}@${hostname}")
    (configure mkHome (lib.filterAttrs (_: meta: meta.home or false) hosts));

  darwinConfigurations = configure mkDarwin (hostsOf "darwin");

  # Bare `david`: transitional alias for the pre-factory key. Drop once
  # nothing calls `.#david`.
  homeConfigurations = homes // {${username} = homes."${username}@Sleipnir";};

  # Evaluation-only checks on the factories (DEC-016). Each failure throws
  # its own message. The probe reads the `pkgs` argument modules actually
  # receive, so a leftover specialArgs.pkgs fails it (RV-009 F-3).
  factoryChecks = let
    probe = c:
      (c.extendModules {
        modules = [
          ({pkgs, ...}: {
            nixpkgs.overlays = [(_: _: {factoryProbe = true;})];
            assertions = [
              {
                assertion = pkgs.factoryProbe or false;
                message = "darwin module overlays do not reach module pkgs (ISS-004)";
              }
            ];
          })
        ];
      }).system.drvPath;
    expect = what: ok: ok || throw "checks.factories: ${what}";
    classes = map classesOf [
      {kind = "nixos";}
      {
        kind = "nixos";
        home = true;
      }
      {kind = "darwin";}
      {
        kind = "darwin";
        home = true;
      }
    ];
  in
    map probe (lib.attrValues darwinConfigurations)
    ++ [
      (expect "no darwinConfigurations.Draupnir" (darwinConfigurations ? Draupnir))
      (expect "classesOf over kind x home: ${builtins.toJSON classes}"
        (classes == [["nixos"] ["nixos" "homeManager"] ["darwin"] ["darwin" "homeManager"]]))
      (expect "no homeConfigurations.\"${username}@Draupnir\"" (homeConfigurations ? "${username}@Draupnir"))
    ];
in {
  perSystem = {pkgs, ...}: {
    checks.factories = builtins.deepSeq factoryChecks (pkgs.runCommand "factories" {} "touch $out");
  };

  flake = {
    # Overlaid full nixpkgs, so the `agents` registry alias
    # (modules/nixos/nix.nix) resolves `nix shell agents#codex` etc. to the
    # llm-agents builds. Everything else under agents#… still works — this
    # is a superset of nixpkgs.
    legacyPackages = lib.genAttrs linuxSystems (system:
      import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [(agentsOverlay system)];
      });

    # Every llm-agents CLI, surfaced as this flake's own packages so the
    # `agents` registry alias resolves `nix shell agents#<any>` (amp, droid,
    # goose-cli, grok, …) — the full roster, not just the curated overlay
    # set. Kept OUT of the overlay on purpose: ~200 names, many colliding
    # with real nixpkgs attrs (dolt, code, handy, omp, but, ck), so
    # blanket-injecting would shadow them system-wide. tryEval guards attrs
    # that throw on eval; drop non-derivations (buildNpmPackage, hooks,
    # default, …).
    packages = let
      keep = n: v: n != "default" && (builtins.tryEval (lib.isDerivation v)).value or false;
    in
      lib.genAttrs linuxSystems (system: lib.filterAttrs keep inputs.llm-agents.packages.${system});

    nixosConfigurations = configure mkNixos (hostsOf "nixos");
    inherit darwinConfigurations homeConfigurations;

    coverage."Sleipnir+openrgb" =
      mkNixos "Sleipnir" hosts.Sleipnir
      (select "Sleipnir" hosts.Sleipnir [{feature.hardware.openrgb.enable = true;}]);

    coverage."Sleipnir+llama-cpp" =
      mkNixos "Sleipnir" hosts.Sleipnir
      (select "Sleipnir" hosts.Sleipnir [{feature.ai.llama-cpp.enable = true;}]);

    # Evaluates the rocmSupport closure; builds nothing (ADR-005 D5).
    coverage."Sleipnir+rocm" =
      mkNixos "Sleipnir" hosts.Sleipnir
      (select "Sleipnir" hosts.Sleipnir [{feature.ai.rocm.enable = true;}]);

    # Evaluates the whisper-cpp ROCm closure (overlays/whisper-rocm.nix); builds nothing.
    coverage."Sleipnir+speech" =
      mkNixos "Sleipnir" hosts.Sleipnir
      (select "Sleipnir" hosts.Sleipnir [{feature.audio.speech.enable = true;}]);

    coverage."Sleipnir+sunshine" =
      mkNixos "Sleipnir" hosts.Sleipnir
      (select "Sleipnir" hosts.Sleipnir [{feature.services.sunshine.enable = true;}]);

    # docker off: the two are exclusive (DEC-022); a plain false beats the
    # workstation profile's mkDefault.
    coverage."Sleipnir+podman" = mkNixos "Sleipnir" hosts.Sleipnir (select "Sleipnir" hosts.Sleipnir [
      {
        feature.virt.podman.enable = true;
        feature.virt.docker.enable = false;
      }
    ]);

    # The NixOS base alone on aarch64-linux (DEC-027): proves it evaluates
    # headless and off x86, with no host, feature or machine config. Builds nothing.
    coverage."base@aarch64-linux" = lib.nixosSystem {
      specialArgs = args "base";
      modules = [
        ./modules/nixos
        (platformModule {system = "aarch64-linux";})
        {
          system.stateVersion = "24.11";
          fileSystems."/" = {
            device = "/dev/disk/by-label/nixos";
            fsType = "ext4";
          };
        }
      ];
    };

    # The home base and Linux layer alone on aarch64-linux (DEC-034): proves
    # they evaluate headless and off x86, with no host, feature or identity.
    # Evaluated by `just coverage` and `just isolation`; builds nothing.
    coverage."home@aarch64-linux" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs-home {system = "aarch64-linux";};
      modules = [
        (homeModule "aarch64-linux")
        ./modules/home/linux
        {
          home = {
            inherit username;
            homeDirectory = "/home/${username}";
            stateVersion = "24.11";
          };
        }
      ];
      extraSpecialArgs = args "home-base";
    };
  };
}
