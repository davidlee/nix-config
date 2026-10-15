{
  description = "machine songs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-home.url = "github:nixos/nixpkgs/nixos-unstable";
    stable.url = "github:nixos/nixpkgs/nixos-24.11";

    # Jailed agents (formerly `pub`). Follows-anchor for panopticon/satan/
    # satan-attrd's (nested) `pub` inputs, so they share this one copy
    # instead of vendoring their own. Also consumed directly by
    # overlays/agents.nix (linux only — nothing on darwin forces this input).
    #
    # Locked from GitHub (portable, like `emacs`); `home_override` in the
    # Justfile switches to the local checkout so an agents/ edit lands
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
    # justfile's switch targets override it with the local checkout, so an
    # emacs.nix edit lands without a push.
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

    panopticon = {
      url = "path:/home/david/dev/panopticon";
      inputs = {
        nixpkgs.follows = "nixpkgs-home";
        pub.follows = "agents";
        doctrine.inputs.pub.follows = "agents";
      };
    };

    satan = {
      # url = "path:/home/david/dev/satan";
      url = "github:davidlee/satan";
      inputs = {
        nixpkgs.follows = "nixpkgs-home";
        agents.follows = "agents";
        doctrine.inputs.agents.follows = "agents";
      };
    };

    satan-patcher = {
      url = "path:/home/david/dev/satan-patcher";
      inputs.nixpkgs.follows = "nixpkgs-home";
    };

    satan-attrd = {
      url = "path:/home/david/dev/satan-attrd";
      inputs = {
        nixpkgs.follows = "nixpkgs-home";
        pub.follows = "agents";
        spec-driver.inputs.pub.follows = "agents";
      };
    };

    goad = {
      url = "git+file:///home/david/dev/goad";
    };

    # The capsule's host-side perimeter as systemd units under dedicated uids
    # (nixosModules.capsule-perimeter, wired in features/virt/capsule.nix, which
    # also takes microvm.nix's host module through this input rather than locking
    # a second copy). The VM itself is still built from the local checkout by
    # `vm capsule` or created imperatively with `microvm -c`; this input carries
    # the host half only. Was github:davidlee/microvm-spike.
    #
    # `target.follows` is a fetchability shim, not a version choice.
    # `target` is the repo oubliette confines — doctrine, as
    # `git+file:///home/david/dev/doctrine`, a path that exists on Sleipnir and
    # nowhere else, so locking or updating this input from darwin would try to
    # fetch something that isn't there — same class of problem as `agents` above.
    # Nothing here reads it: it feeds oubliette's
    # nixosConfigurations.capsule (the guest's tool set), which this flake never
    # evaluates. Importing microvm.nix's *host* module does not change that;
    # declaring a `microvm.vms.<name>` would, which is why the VMs stay
    # imperative (oubliette NOTES item 11).
    #
    # A dependency's nixConfig is ignored, so oubliette's
    # microvm.cachix.org substituter does not apply here. Only matters if this
    # config ever builds the VM.
    oubliette = {
      url = "github:davidlee/oubliette";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        target.follows = "nixpkgs";
        goad-walk.follows = "nixpkgs";
      };
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
