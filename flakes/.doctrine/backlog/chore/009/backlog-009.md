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
