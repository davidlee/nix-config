# IMP-047: W4 — One canonical dev-flake template and .envrc helper

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Programme W4. Make the template (`_templates/agents/{flake.nix,_envrc}`) the
one current pattern, and replace the `.envrc` hack variants with one helper.

`.envrc` variants found (helper `use_flake_local` in
`modules/home/programs.nix`):
- A `use flake` — deck_of_dwarf, oubliette, resume, screwtape
- B `use flake_local agents` (pure) — goad, malebolge, retrograde,
  satan-attrd, www; silently ignores `JAIL_WORKSPACE_DEPS`
- C `use flake_local agents --impure` — doctrine, panopticon,
  org-incremental-writing (its comment names a nonexistent file)
- D `use flake_local agents emacs --impure` — satan

Want: one helper (e.g. `use agents_dev`) that owns the impure decision and
reads the ro/rw dep lists from W1 (IMP-044). Template gains: agents follows
nixpkgs (only satan and screwtape do today), the W3 (IMP-046) form helper,
`piGatewayModels`.

Overlaps IMP-007 (shared dev-environment recipes flake); decide at slice
whether this absorbs it.
