# ISS-007: atuin disabled on darwin: 18.23.0 not cached for aarch64-darwin, local build fails

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Found during SL-004 PHASE-06 (Draupnir cut-over), 2026-10-15. At nixpkgs
`7fd4004` (2026-10-11; `nixpkgs` and `nixpkgs-home` share it),
`atuin-18.23.0` (`/nix/store/g0n6d1cjskkaw63p3pl6jzn4gysyqqc6-…`) is not on
cache.nixos.org for aarch64-darwin, and a local build on Draupnir failed after
a long wait. Not caused by SL-004: any switch at this pin hits it.

Workaround: `darwin/home.nix` sets `programs.atuin.enable = lib.mkForce false`.
Linux keeps atuin.

Done when: a nixpkgs bump makes atuin substitutable for aarch64-darwin
(`nix path-info --store https://cache.nixos.org <outPath>`), the override is
removed, and `just home-switch` on Draupnir succeeds. Avoid `stable.atuin`
(24.11): it may not read a history database a newer atuin has migrated.
