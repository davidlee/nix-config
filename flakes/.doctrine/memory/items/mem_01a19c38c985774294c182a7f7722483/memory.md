Measured 2026-11-02 (SL-022 design) with a synthetic flake in `/tmp`:
`inputs.project.url = "path:./sub"` locks as

    {"type": "path", "path": "./sub", "narHash": …}

— **relative**, not an absolute path. So a flake can carry a fixture as a default
input (`dev-envs/stub-project`) and still be evaluated from a store copy
(`?dir=…`, the Mac), which an absolute path could not.

Consequence for lock guards: `~/flakes/justfile:65` forbids *every* path node.
That rule cannot be reused verbatim where a relative fixture is legitimate; the
sharper form rejects `file:` URLs and absolute path nodes only:

    jq -e '[.nodes[].locked // empty
            | select(((.url // "") | startswith("file:"))
                     or (.type == "path" and ((.path // "") | startswith("/"))))] == []'

Both were exercised against synthetic locks: the sharp one passes `./sub` and
fails `/home/...`.

## The `narHash` beside it is a sentinel, not the fixture's hash

Measured 2026-11-02 (SL-022 PHASE-01) on the real lock:

    "project": {"lastModified": 1, "narHash": "sha256-gmt/SQp9gEx+EPhXa7fcwVdu048pzbxk/CaPRTqCebA=", "path": "./stub-project", "type": "path"}

- That `narHash` is **not** the directory's NAR hash: the stub's own is
  `sha256-C3PFa6…`. Adding a file to `stub-project/` and re-running
  `nix flake lock` leaves the recorded value unchanged.
- It is load-bearing as a sentinel. Substituting a real hash breaks evaluation:
  `error: cannot fetch input 'path:./stub-project?narHash=…' because it uses a
  relative path`. With the sentinel, the input resolves inside the parent flake's
  store copy, so the fixture is always current.
- Therefore: never "correct" that hash, and no lock guard should re-hash path
  nodes — judge the node's shape only (the `jq` expression above).
