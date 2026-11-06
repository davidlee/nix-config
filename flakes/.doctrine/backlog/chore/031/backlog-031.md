# CHR-031: Audit capsule-tools across project flakes and update the fleet targets

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

DEC-128: `dev-tools` carries no Doctrine; a room gets it from `capsule-tools`.
Audit every project with a fleet target, and for each:

1. Does its room need Doctrine? If so, export `capsule-tools` (its tool list plus
   Doctrine), as `~/dev/doctrine/flake.nix` and `~/dev/satan/flake.nix` do.
2. Set `toolsPackage = "capsule-tools"` in `/srv/fleet/targets/<repo>.nix` and
   re-lock fleet.
3. Only then drop Doctrine from `dev-tools` (DEC-112's order).

Known, 2026-11-06:

- satan: `capsule-tools` exists (uncommitted), but `targets/satan.nix` still says
  `dev-tools`. Its room loses Doctrine if the flake lands first.
- malebolge, panopticon: Doctrine is in `dev-tools`.
- screwtape, www: read the flake; a grep is not enough.

Also: SPEC-003 does not name `capsule-tools` or this rule. Add both by revision.

Related: CHR-030, DEC-112, DEC-128.
