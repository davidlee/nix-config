# IDE-002: Per-host local input overrides as host data

Which flake inputs a host overrides with a local checkout lives in the
`justfile` as strings — `system_override` (oubliette, agents) and
`home_override` (emacs) — applied per recipe, not per host. So the Mac and
Sleipnir can only differ by recipe (`darwin-*` vs `system-*`/`home-*`), and
the knowledge of "this host has a local checkout of X" is implicit.

Idea: keep `--override-input` as the mechanism, but declare each host's local
overrides as host data — e.g. a field in `hosts/<h>/meta.nix` mapping input
name → local path — and have the justfile derive the flags from it (e.g. via
`nix eval` of the host's meta). Draupnir and Sleipnir then differ
declaratively.

Touches the same recipes as SL-004's per-OS flake ref (`flake :=`), but is
not SL-004 work. Raised during SL-004 design review, 2026-10-15. Related:
IMP-010 (meta.nix validation would cover the new field).
