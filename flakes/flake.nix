{
  description = "machine songs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-home.url = "github:nixos/nixpkgs/nixos-unstable";
    stable.url = "github:nixos/nixpkgs/nixos-24.11";

    # Jailed agents (formerly `pub`). Follows-anchor for panopticon/satan/
    # satan-attrd's (nested) `pub` inputs, so they share this one copy
    # instead of vendoring their own. Also consumed directly by
    # overlays/agents.nix, which every system and home evaluation applies.
    #
    # Locked from GitHub, like `emacs`; the justfile's read-only recipes build
    # from the in-tree checkout (tree_override), so an agents/ edit lands
    # without push + `nix flake update agents`.
    agents.url = "github:davidlee/nix-config?dir=flakes/agents";

    # Agent CLIs (codex, claude, gemini, ...). Follows agents' pin, so host
    # and every project jail share one agent version: bump it in agents
    # (`nix flake update llm-agents`), then `nix flake update agents` here.
    # agents keeps llm-agents off our nixpkgs so the numtide binary cache
    # (cache.numtide.com) applies. Injected via overlays/agents.nix.
    llm-agents.follows = "agents/llm-agents";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-home";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # helix = {
    #   url = "github:helix-editor/helix/master";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # Wrapped Emacs (the manual package list), shared with the ~/.config/emacs and
    # satan devshells — one derivation, one set of pins (its own nixpkgs and
    # overlay). GitHub for portability: darwin has no /home/david. The
    # justfile's read-only recipes override it with the in-tree checkout, so
    # an emacs.nix edit lands without a push.
    emacs = {
      url = "github:davidlee/nix-config?dir=flakes/emacs";
      # Override the upstream flake's moving tarball with a revision-locked fetch.
      inputs.emacs-overlay.url = "github:nix-community/emacs-overlay";
    };

    # PrismML llama.cpp fork, for Bonsai's ternary formats. To bump: change the
    # release tag, `nix flake update llama-cpp-prism-src`, then re-derive
    # npmDepsHash in overlays/llama-prism.nix (the version comes from this ref).
    llama-cpp-prism-src = {
      url = "github:PrismML-Eng/llama.cpp/prism-b10754-2459f68";
      flake = false;
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    ucodenix.url = "github:e-tho/ucodenix";
    # zig-overlay.url = "github:mitchellh/zig-overlay";
    # zls-overlay.url = "github:zigtools/zls";
    # bough.url = "git+ssh://git@github.com/davidlee/vk";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-home";
    };

    # Developed in ~/dev checkouts (bin/dev-checkouts): declared and locked by
    # remote; read-only recipes override each with a present checkout.
    panopticon = {
      url = "github:davidlee/panopticon";
      inputs = {
        nixpkgs.follows = "nixpkgs-home";
        agents.follows = "agents";
        doctrine.inputs.pub.follows = "agents";
      };
    };

    satan = {
      url = "github:davidlee/satan";
      inputs = {
        nixpkgs.follows = "nixpkgs-home";
        agents.follows = "agents";
        doctrine.inputs.agents.follows = "agents";
      };
    };

    satan-patcher = {
      url = "github:davidlee/sloptower";
      inputs.nixpkgs.follows = "nixpkgs-home";
    };

    satan-attrd = {
      url = "github:davidlee/satan-attrd";
      inputs = {
        nixpkgs.follows = "nixpkgs-home";
        agents.follows = "agents";
        spec-driver.inputs.pub.follows = "agents";
      };
    };

    goad.url = "github:davidlee/goad";

    # The capsule's host-side perimeter as systemd units under dedicated uids
    # (nixosModules.capsule-perimeter, wired in features/virt/capsule.nix, which
    # also takes microvm.nix's host module through oubliette rather than locking
    # a second copy). The fleet is this host's declaration of its capsules — a
    # private consumer of oubliette's mkFleet at /srv/fleet (oubliette SL-004);
    # oubliette itself declares no target and arrives as the fleet's input. The
    # VMs are created imperatively with `microvm -c <slot> -f /srv/fleet`; this
    # input carries the host half only. Was github:davidlee/oubliette, and
    # before that github:davidlee/microvm-spike.
    #
    # No `follows` shim on the fleet's targets (doctrine, goad-walk): the
    # perimeter module evaluates each target's guest image, which reads the
    # target flake's `packages`, so a target that follows nixpkgs fails eval
    # (`attribute 'packages' missing`). Their revs are the fleet's lock.
    #
    # A dependency's nixConfig is ignored, so oubliette's
    # microvm.cachix.org substituter does not apply here. Only matters if this
    # config ever builds the VM.
    fleet = {
      url = "git+ssh://git@github.com/davidlee/oubliette-fleet";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    umbriel = {
      url = "git+https://github.com/noctalia-dev/umbriel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-desktop.url = "github:aaddrick/claude-desktop-debian";

    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lem = {
      url = "github:lem-project/lem";
      inputs = {
        # its own flake-parts pins a 2025 nixpkgs.lib that still uses `or` as an identifier
        nixpkgs.follows = "nixpkgs-home";
        flake-parts.follows = "flake-parts";
      };
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae.url = "github:vicinaehq/vicinae";

    elephant.url = "github:abenz1267/elephant";

    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };
  };

  outputs = inputs @ {self, ...}:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (
      _: let
        linuxSystems = ["x86_64-linux" "aarch64-linux"];
      in {
        imports = [
          inputs.treefmt-nix.flakeModule
          ./overlays.nix
          ./hosts.nix # *Configurations, one per hosts/<host>/meta.nix
          ./workarounds/probes.nix # workaroundProbes: transient-breakage probes (workarounds/default.nix)
        ];

        systems = linuxSystems ++ ["aarch64-darwin"];

        perSystem = ./perSystem.nix;

        flake = {
          templates = {
            agents = {
              path = ./_templates/agents;
              description = "Dev shell with jailed LLM agents";
            };
            default = self.templates.agents;
          };
        }; # flake
      }
    );
}
