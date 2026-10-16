`nix flake update <names> --override-input X <local>` (and `nix flake lock`)
writes X's override into `flake.lock` as a `path` / `git file://` node, even
though `original` still says `github:`. Evidence (2026-10-16, SL-009
research): `agents` locked `path /home/david/flakes/agents`, `oubliette`
locked `git file:///home/david/dev/oubliette/` with a `-dirty` rev, both from
`update-*` recipes carrying overrides (ISS-006). `emacs` was clean only
because `nix flake update emacs` later re-locked it (CHR-008).

- Read-only commands (`nix eval`, `nix build --no-write-lock-file`) may carry
  overrides; lock-writing ones must not (DEC-038).
- Check: `jq '.nodes[].locked | select(.type=="path" or ((.url//"")|startswith("file:")))' flake.lock`.
- A `git+file` override takes tracked files only (dirty tracked edits
  included); `path:` copies the whole directory, ignored files too.
