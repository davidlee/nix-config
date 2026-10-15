Doctrine's project root here is `~/flakes`; the git root is `~` (worktree of
`~/.cfg`). `doctrine slice selector` paths resolve against the doctrine root,
so `flakes/hosts.nix` matches nothing — write `hosts.nix`. Check with
`doctrine slice selector doctor <slice>`: "unmatched" on a file that exists
means a wrong prefix. Found in SL-001 design, 2026-10-15.
