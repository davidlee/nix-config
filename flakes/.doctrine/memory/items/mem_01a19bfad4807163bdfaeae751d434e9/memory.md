Observed 2026-11-02 from a jailed agent session working in `~/flakes`.

- `~/.cfg` — the home repo's git dir (the worktree is `~`) — is mounted
  read-only. `git add` fails with "Unable to create ~/.cfg/index.lock:
  Read-only file system". A confined agent therefore cannot stage, commit, or
  even `git add -N` a new file.
- Nix consequence: `~/flakes` is a git flake, so refs that resolve through git
  (`/home/david/flakes`, `git+file:`) cannot see a file the session created.
  Evaluate a new subflake as `path:/home/david/flakes/<sub>#…`, which copies
  the directory including untracked files.
- `~/.cache` is read-only as well: nix dies with "cannot open SQLite database
  …/eval-cache-v5/….sqlite". Set `XDG_CACHE_HOME=/tmp/<dir>/cache`.
- Builds still work: a trivial derivation builds through the daemon.
- Anything durable (the commit, `git add -N`) belongs to the user's shell or a
  non-confined session.


See also [[mem.fact.flakes.git-add-n]] (the fix a writable session can apply),
[[mem.fact.flakes.override-records-in-lock]] (why `--no-write-lock-file` is
mandatory here), and [[mem.fact.jail-nix.launcher-one-line]].