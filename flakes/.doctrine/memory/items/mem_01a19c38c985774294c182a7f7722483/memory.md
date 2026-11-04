Measured 2026-11-02 (SL-022 design) with a synthetic flake in `/tmp`:
`inputs.project.url = "path:./sub"` locks as

    {"type": "path", "path": "./sub", "narHash": …}

— **relative**, not an absolute path. So a flake can carry a fixture as a default
input (`dev-envs/stub-project`) and still be evaluated from a store copy.

Consequence for lock guards: `~/flakes/justfile` forbids *every* path node in the
root lock. That rule cannot be reused where a relative fixture is legitimate; the
sharper form rejects `file:` URLs and absolute path nodes only:

    jq -e '[.nodes[].locked // empty
            | select(((.url // "") | startswith("file:"))
                     or (.type == "path" and ((.path // "") | startswith("/"))))] == []'

## The `narHash` beside it pins the fixture's content (corrected 2026-11-04)

Measured 2026-11-04 (SL-023 PHASE-03, Lix 2.95.4) in a scratch copy of
`dev-envs`. This replaces an earlier claim that the hash was an inert sentinel
and the fixture "always current" — that was wrong.

- The recorded `narHash` is the fixture directory's NAR hash
  (`nix hash path stub-project`), and evaluation uses **the store path with that
  hash**, not the directory beside the flake. An edited stub is invisible until
  `nix flake update project` (in `dev-envs`) re-hashes it. `nix flake lock` does
  not re-hash while the old store path exists.
- If that store path is absent (a fresh machine, or after GC — it is not a GC
  root), evaluation fails: `cannot fetch input 'path:./stub-project?…narHash=…'
  because it uses a relative path`. A wrong hash fails the same way.
- Real use is unaffected: with `--override-input project …` the stub node is
  never fetched (verified with Smut). What breaks is `dev-envs`' own checks
  (`just test`'s stub check) on a machine that lacks the path.
- Therefore: after any stub edit (including a formatter's), run
  `nix flake update project --flake path:$HOME/flakes/dev-envs` and commit the
  lock. Lock guards judge the node's shape only.
