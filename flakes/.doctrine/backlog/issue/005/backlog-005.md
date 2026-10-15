# ISS-005: Source-delta paths are git-root-relative; selectors and VT test_files are ~/flakes-relative

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

The git root is `~` (worktree of `~/.cfg`); the doctrine root is `~/flakes`.
The source-delta registry and `slice conformance` report changed paths
relative to the git root (`flakes/features.nix`), while slice selectors and
plan VT `test_file`s resolve against the doctrine root (`features.nix`).
So nothing matches:

- `doctrine slice conformance 1` lists every PHASE-01 file as both
  undeclared and undelivered.
- `doctrine slice verify-vt 1` reports SL-001 PHASE-01 VT-1..4 as
  UNATTRIBUTABLE ("not modified by this slice") after commit 84d77e11 and
  the phase's `completed` flip.

Same root mismatch as `mem.fact.flakes.selector-root` and CHR-009. Upstream
doctrine fix: strip the doctrine root's prefix from git-relative paths. Until
then, VT attribution for SL-001 is judged by agent: the keywords are present
and the files are in the phase commit.
