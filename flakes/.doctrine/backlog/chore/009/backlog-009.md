# CHR-009: Re-scope flakes memories: scope.paths flakes/ vs doctrine root

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Four memories carry `scope.paths: [flakes/]`: `mem.pattern.flakes.drv-gate`,
`mem.fact.nix.merge-order`, `mem.fact.flakes.git-add-n` and
`mem.fact.flakes.fmt-relock`. Slice selectors resolve against `~/flakes`
(`mem.fact.flakes.selector-root`), so these memories may never surface by
path. Verify how memory path scope resolves, then re-scope them. Raised in
SL-001 design, 2026-10-15.

## Resolution (2026-10-15)

Verified by probing `memory retrieve --path-scope` and the PreToolUse hook (`memory surface`):
path scopes are literal prefixes of the doctrine-root-relative path, so `flakes/…` never matched.
The rule is recorded in `mem.fact.flakes.selector-root`. New scopes:

| memory | paths / globs | commands |
|---|---|---|
| `mem.pattern.flakes.drv-gate` | flake.nix hosts.nix features.nix overlays.nix perSystem.nix hosts/ features/profiles/ | just drvs, just drvs-sets |
| `mem.fact.nix.merge-order` | hosts.nix features.nix features/profiles/ overlays.nix overlays/ | just drvs-sets |
| `mem.fact.flakes.fmt-relock` | flake.lock perSystem.nix | (unchanged) |
| `mem.fact.flakes.git-add-n` | glob `**/*.nix` | nix eval, nix build, just drvs, just gate |

`git-add-n`'s worktree sentence (duplicated `home-worktree`) is now a link. The hook surfaces
nothing for Bash commands, so command scopes only reach `memory retrieve --command`.
