Doctrine's project root here is `~/flakes`; the git root is `~` (worktree of
`~/.cfg`). `doctrine slice selector` paths resolve against the doctrine root,
so `flakes/hosts.nix` matches nothing — write `hosts.nix`. Check with
`doctrine slice selector doctor <slice>`: "unmatched" on a file that exists
means a wrong prefix. Found in SL-001 design, 2026-10-15.


**Memory scopes too** (verified 2026-10-15, CHR-009). `scope.paths` is a
literal prefix match against the doctrine-root-relative path; the PreToolUse
hook (`doctrine memory surface`) sends paths in that form. A `flakes/…` scope
never surfaces: write `flake.lock`, `hosts/`. `scope.globs` (`**/*.nix`)
match at any depth, top level included. `scope.commands` match by whole-token
prefix (`just drvs` ≠ `just drvs-sets`), via `memory retrieve --command` only:
the hook surfaces nothing for Bash commands. Probe a scope with
`doctrine memory retrieve --path-scope <path> --json`.
