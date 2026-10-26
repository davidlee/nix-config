# Read-only workspace deps by default; rw opt-in

## Context

Implements IMP-044 (programme item W1). A jail's workspace deps — sibling
repos mounted at `/workspace/<basename>` — come from the static `workspaceDeps`
argument merged with `JAIL_WORKSPACE_DEPS` (impure eval only), and every one
is bound **rw** (`--bind`, `agents/jailed-agents.nix` ~L560–618). There is no
read-only form, so an agent working in one repo can write to every
collaborator repo its jail sees (satan mounts nine; doctrine five).

Decision (user, 2026-10-27): **flip the default.** Workspace deps are
read-only; read-write is an explicit opt-in.

## Scope & Objectives

```
workspaceDeps        ─┐
JAIL_WORKSPACE_DEPS  ─┴─> --ro-bind  <dep> /workspace/<basename>
workspaceDepsRw      ─┐
JAIL_WORKSPACE_DEPS_RW┴─> --bind     <dep> /workspace/<basename>
```

- `workspaceDeps` and `JAIL_WORKSPACE_DEPS` bind read-only.
- New `workspaceDepsRw` argument and `JAIL_WORKSPACE_DEPS_RW` env var bind
  read-write; same parsing (newline/colon separated, absolute, trailing slash
  stripped) and the same `workspaceDepsFromEnv = false` switch.
- Existing guards hold across both lists: relative paths refused, duplicate
  destinations refused.
- Tests: `agents/jailed-agents-test.nix` (pure) and
  `agents/jailed-agents-env-test.nix` (impure, `just test`) cover ro, rw, both
  env vars, and the cross-list guards.
- Docs: `agents/README.md` (prose and option table).
- In-repo consumers that need rw move to the rw list:
  `_templates/agents/flake.nix` (comments/example), and the Emacs devshell
  flake (`~/.config/emacs/flake.nix`) if its deps need writing.

## Non-Goals

- Migrating `~/dev/*` repos' `.envrc` and flakes (W5, CHR-023), including
  satan, which another agent is reworking.
- The `.envrc` helper that would read both lists (W4, IMP-047).
- The launch dir (`mountLaunchDir`): stays rw — it is the project being
  worked on.
- Other ad-hoc binds in consumers (`rw-bind`, raw `--bind`).
- The wider refactor of `jailed-agents.nix` (W2, IMP-045).

## Summary

Risks and open questions, for `/design`:

- **Live consumers flip immediately.** Repos using the `.envrc` hack (variants
  B–D) evaluate the live `~/flakes/agents`, so the flip reaches them at the
  next direnv reload, not at their next lock bump. Any dep they genuinely
  write to (inferred candidates: satan's `~/notes`, `~/flakes` in several)
  goes read-only until moved to the rw list. Design must decide: accept and
  fix forward per repo, or land with a list of known rw needs handed to W5.
- **A path in both lists.** Refuse (duplicate destination, as today) or let
  rw win? Leaning refuse: one destination, one mode.
- **Nested ro under rw / overlapping paths** — e.g. `~/flakes` ro and
  `~/flakes/agents` rw at different basenames. bwrap applies binds in order;
  design checks whether ordering matters.

Verification / closure: `just test` green (pure and impure jail tests
asserting `--ro-bind` vs `--bind` per list and env var), lint and format
clean, README matches behaviour, and a built launcher inspected for the
expected bind args.

## Follow-Ups

- W4 (IMP-047): `.envrc` helper sets `JAIL_WORKSPACE_DEPS` /
  `JAIL_WORKSPACE_DEPS_RW`.
- W5 (CHR-023): per-repo rw lists; move as many deps to ro as practical.
