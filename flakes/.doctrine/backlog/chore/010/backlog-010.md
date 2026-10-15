# CHR-010: Add a just gate recipe so doctrine check gate runs

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`doctrine check gate` fails in this repo because there is no `just gate`
recipe. Today the gate is run by hand as `just test`, then `nix fmt` (with
`flake.lock` restored afterwards, `mem.fact.flakes.fmt-relock`), then
statix and deadnix. A `gate` recipe should run the same checks without
re-locking: alejandra `--check`, `statix check`, `deadnix --fail`, and
`just test`.

Found in SL-001 PHASE-01; restated in the SL-001 audit (RV-003).

## Resolution (2026-10-15)

`just gate` = `just test`, then `nix build .#checks.<system>.treefmt --no-link --no-write-lock-file`.
The treefmt flake check (from treefmt-nix) runs the same alejandra/statix/deadnix config as
`nix fmt`, read-only, in the sandbox — one config, no re-lock. `doctrine check gate` passes.

Gotcha found: `nix fmt` alone reported "0 changed" over 9 unformatted files — treefmt's mtime
cache. Use `nix fmt --no-write-lock-file -- --no-cache` when in doubt; the gate is not affected.
