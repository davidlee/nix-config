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

**Include pattern (user, 2026-10-27).** Replace the per-repo
`if declare -F use_flake_local …` blocks with shared snippets the `.envrc`
includes, e.g.:

```
source_env ~/flakes/envrc/agents.sh       # live agents input, ro/rw dep lists
source_env ~/flakes/envrc/containers.sh   # docker/podman selection (drifted per repo)
```

direnv's `source_env` (not plain `source`) also watches the included file,
so editing a snippet reloads every repo that includes it. `use_flake_local`
today lives in home-manager's direnv stdlib (`modules/home/programs.nix:20`),
which is why each `.envrc` guards on `declare -F`; moving it into the snippet
makes the snippet the single definition, changeable without a home switch.
Snippets live in this tracked repo, not in `/workspace` (an untracked symlink
farm). Trade-off: a public repo's `.envrc` then names a path only this
machine has; `source_env_if_exists` plus `use flake .` covers foreign clones.
Security: a snippet runs on the host at every `cd`, unasked, so `~/flakes`
must be read-only in jails (W1, IMP-044).

Done (2026-10-27).

- `envrc/agents.sh` (tracked) is the one definition of `use_flake_local`
  (moved out of home-manager's direnv stdlib, `modules/home/programs.nix`)
  and the new `use_agents_dev [<input>…] [args]`: inputs default to
  `agents`, and it adds `--impure` iff `JAIL_WORKSPACE_DEPS` or
  `JAIL_WORKSPACE_DEPS_RW` is non-empty. Evidence: the only `getEnv` in any
  consumer's evaluation is `agents/workspace-binds.nix`, which reads those
  two. Behaviour tests: `envrc/agents-test`, run by `just test`.
- Every `.envrc` form B/C/D (and notes, emacs) is now:
  `source_env_if_exists ~/flakes/envrc/agents.sh` +
  `if has use_agents_dev; then use agents_dev [agents emacs]; else use flake .; fi`.
  16 files (vk is a symlink to bough). Tracked ones committed in bough,
  retrograde, satan-attrd and notes; the rest are untracked. Form A
  (`use flake`) repos left alone: no live input wanted.
- Effects: B repos with deps (goad) now see them (were silently dropped
  under pure eval); C repos without deps (org-incremental-writing, _SDLC)
  now evaluate purely, and their devshells were checked to evaluate pure.
  notes' `.envrc` used `use flake_pub`, which overrode a nonexistent `pub`
  input, so notes never had live agents; it does now.
- `use_flake_pub` dropped: no user left. The `pub` shim flake stays (the
  top-level flake still follows doctrine's and spec-driver's nested `pub`).
- Template: `_envrc` takes the new form; `flake.nix` has agents following
  nixpkgs, a `quotient` input (v0.6.0), `quotient-read`/`quotient-write` via
  `quotientFormFamily` (IMP-046), and a `quotient-forms` devshell command.
  `piGatewayModels` needs no template line: the helper binds it. Checked by
  instantiating the template and building the forms, `jailed-pi` and the
  devshell against the local agents.
- Not done: `containers.sh`. Only satan and emacs set `DOCKER_HOST`, to the
  same value; no drift to fix yet.
- IMP-007 not absorbed: shared recipes are a separate concern from the
  template and the envrc helper.
- The stdlib removal takes effect at the next `just home-switch`; until
  then both definitions exist and the sourced one wins.
