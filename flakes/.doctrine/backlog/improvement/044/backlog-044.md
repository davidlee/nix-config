# IMP-044: W1 — Read-only workspace deps for jails; rw becomes opt-in

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Programme: dev-flake consolidation, items W1–W8 (IMP-044..050, CHR-023),
surveyed 2026-10-27.

**Now.** `workspaceDeps` (static) and `JAIL_WORKSPACE_DEPS` (env, impure eval
only) are merged and every entry is mounted **rw** with `--bind` at
`/workspace/<basename>` (`agents/jailed-agents.nix` ~L560–618). There is no
read-only form. Heavy users mount many collaborator repos rw: satan (notes,
emacs, flakes, panopticon, malebolge, quotient, oubliette, satan-attrd,
satan-corpus), doctrine (flakes, oubliette, spec-driver, …), panopticon
(satan, emacs, flakes).

**Want.** A read-only list, taken from `.envrc` as well as from the flake, and
as many existing mounts moved to ro as practical.

**Open (user to decide at slice):** flip the default, i.e. `workspaceDeps` /
`JAIL_WORKSPACE_DEPS` become ro and rw is the opt-in
(`workspaceDepsRw` / `JAIL_WORKSPACE_DEPS_RW`) — recommended; breaking, but
every consumer is the user's. Alternative: keep rw default, add a ro list.

Related: goad's `.envrc` sets `JAIL_WORKSPACE_DEPS` without `--impure`, so it
is (inferred) a no-op — W4 (IMP-047) removes that trap.
