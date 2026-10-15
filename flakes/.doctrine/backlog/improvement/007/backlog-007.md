# IMP-007: Shared dev-environment recipes flake

From the feature-architecture brief §5. A small, separately consumable flake in this repo (like `agents`, `emacs`) exporting functions that take the project's `pkgs`, so projects own versions; export a preconstructed shell where sharing exact toolchains is intentional. Committed consumers use pinned references. Keep nix-direnv; an ad-hoc wrapper runs `nix develop <ref>#ruby --command nu`. Not a module class.
