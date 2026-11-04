# IMP-057: Jail and Quotient definitions for the home repo

This repo (`~/flakes`) has no jail and no Quotient forms. Pi therefore runs here
unconfined, and the agent-safety setup that project flakes get from the
dev-envs consumer (SL-022) does not apply. This item adds the definitions.

Terms:

- **Jail** — a bubblewrap sandbox that confines an agent to a bound set of
  paths and tools (see SL-022 § Context).
- **Quotient form** — a per-call agent entry point (`read`, `write`) that the
  host's Quotient server launches for a delegate. Forms are approved by hand
  with `quotient allow`.

The shape differs from a project flake:

- A project flake exports `packages.<system>.dev-tools` and the consumer builds
  around it. This repo *is* the flake, so its own tools (nix, just, statix,
  treefmt, the gate's checks) need an equivalent producer output, or the jail
  has no toolset to bind.
- The git worktree is `$HOME` (see `~/flakes/CLAUDE.md`). A jail launched there
  would expose all of `~`, so its launch directory must be `~/flakes` or below.
  IMP-042 (refuse a launch dir that is `$HOME` or an ancestor) is the guard.
- The repo is public (POL-001). The jail must bind no secret material, and the
  forms must not read outside the checkout.

Open questions for the slice (not decided here):

- Whether the root flake gets a `dev-tools` output, or the dev-envs consumer
  takes the repo's tools some other way.
- Which paths the jail binds read-only and which read-write, given `$HOME` is
  the worktree and `.doctrine/`, `.pi/` and `.claude/` are tracked here.

Related: SL-022 (the consumer and its proof), IMP-056 (Doctrine consumer,
step 3), IMP-042 (launch-dir guard).

## Preflight (2026-11-04)

Findings that supersede parts of the body above:

- The producer already exists: `dev-tools/flake.nix`, a subflake exporting
  `packages.<system>.dev-tools` (just, jq, nushell, alejandra, statix, deadnix),
  built for the oubliette room (commit add489ed). The root flake cannot export
  it (cycle through the `fleet` input). So the first open question above is
  answered: reuse the subflake; no second tool list.
- The git toplevel is `$HOME`, so `use_dev_envs` and `dev-envs-forms` (both
  default the project to `git+file:<toplevel>`) name the wrong project here.

### OQ1 — naming the project when the toplevel is `$HOME` — decided

Probed: a `git+file:$HOME?dir=flakes/dev-tools` project fails (for a
`flake = false` input `?dir=` does not narrow the source; flake-compat finds no
`flake.nix` at the root). `path:$HOME/flakes/dev-tools` evaluates.

Decision (agreed): `use_dev_envs` gains an explicit project-ref override (as
`dev-envs-forms` already has `--project`); `~/flakes/.envrc` and the forms link
pass `path:$HOME/flakes/dev-tools`. No consumer change. The helper must watch
the override's `flake.nix` and `flake.lock`, not the toplevel's. Cost accepted:
this one project drops the "tracked files only" property (SPEC-003).

### OQ2 — can the gate's `nix` run in the jail? — decided: no, not in this item

Probed (plain bwrap, read-only host `/nix/store`, writable home, no daemon
socket; the mechanism, not the real jail's binds):

- `nix eval` and `nix build` against a private store (`--store local?root=…`)
  work, and nix auto-enables its build sandbox, so nested user namespaces work
  inside bwrap. `dev-tools` builds in 8 s; the private store holds 739 MB cold
  (all substituted from cache.nixos.org, so it needs the network).
- `local-overlay://` is not supported by Lix 2.95.4. Dead end on this host.
- Evaluating the root flake fails at lock resolution: nine inputs in
  `flake.lock` are `ssh://git@github.com/davidlee/…` (deck_of_dwarf, fleet,
  notes, resume, retrograde, satan-corpus, screwtape, smut, www), private, and
  a jail holds no ssh keys. A private store solves where builds go, not where
  inputs come from. Cost of a real gate build is unmeasured.

Decision: the jail covers authoring and the non-nix lint and tests; `just gate`
stays host-side; `nix` is not added to `dev-tools`. A follow-up must first solve
input access (read-only checkouts, a pre-fetched store, or a gate that avoids
the root flake). Possible small follow-up: a `just lint` recipe running statix,
alejandra and deadnix directly, so a jail has a gate it can run.

### OQ3 — jail, forms, or both — decided: both

Forms first (`dev-envs-forms --project path:$HOME/flakes/dev-tools`, then the
operator's `quotient allow`), then the jail through `~/flakes/.envrc`
(`use_dev_envs` with the OQ1 override). Launching from `~` by mistake is not a
risk: no flake there carries a jail. IMP-042 stays separate.

### OQ4 — git in the jail — decided: rw `.cfg`, `hooks/` and `config` read-only

The jail binds only `~/flakes` (at `/workspace/flakes`), so it cannot touch
`~/.gitconfig`, `~/.config/*` or any tracked file outside `flakes/`. Git finds no
repo there today (`~/.git` is a pointer to `~/.cfg`, `core.worktree` is `$HOME`).

Design shape: bind `~/.cfg` read-write at `/workspace/.cfg`, set
`GIT_DIR=/workspace/.cfg` and `GIT_WORK_TREE=/workspace` (so `flakes/…` index
paths line up), then overlay `hooks/` and `config` read-only.

- Expressible in the library as it stands: `extraOptions` takes `add-runtime`
  combinators, runtime args follow every static one, and bwrap mounts in argv
  order. `workspaceDepsRw` can also place a rw path at `/workspace/<basename>`
  (static, absolute paths), but the overlays need runtime args anyway.
- Residual risk accepted: a writable git dir lets an agent stage and commit as
  the operator; with the overlays it cannot plant a hook or config that runs on
  the host. Elevated over a project jail only in that `.cfg` holds the whole
  dotfiles history. System-wide hardening: IMP-065.
- Missing files: ~260 tracked paths outside `flakes/` look deleted in the jail.
  Safe commands are path-scoped (`git add -u flakes/`). A jail-only
  `skip-worktree` or sparse-checkout is a possible later hardening.

### OQ5 — `.envrc` wiring — decided

`~/flakes/.envrc` gains `use_dev_envs` with the OQ1 override and keeps its
`SLEIPNIR_BUILD` export. No `.envrc` exists above `~/flakes` (none at `~`), so
direnv's walk-up adds nothing. A cold `dev-envs#default` build is the same cost
every project pays.

### OQ6 — tool list — decided: add treefmt, one shared definition

The formatter config lives only in the root flake (`perSystem.nix`:
`treefmt.programs` via treefmt-nix; the repo has no `treefmt.toml`), and
`dev-tools` is a separate subflake because the root cannot be its dependency
(the private `fleet` input). A bare `treefmt` would format nothing.

Decision: `dev-tools/treefmt.nix` holds the program set (alejandra, statix,
deadnix). The root `perSystem.nix` imports it; the `dev-tools` subflake gains a
`treefmt-nix` input and builds the wrapper from the same file, adding it to
`paths`. Side effect: the oubliette room's `toolsPackage` gains treefmt, and the
subflake gains a lock entry.

## Scope as agreed (no slice yet; design sketch from this card)

1. `use_dev_envs` takes an explicit project ref (OQ1); `dev-envs-forms` already
   has `--project`. Tests in `envrc/dev-envs-test`, `bin/dev-envs-forms-test`.
2. `dev-tools`: shared `treefmt.nix` + wrapper (OQ6).
3. `~/flakes/.envrc` calls `use_dev_envs` with the override (OQ5).
4. Jail library: a git-dir option binding `~/.cfg` rw at `/workspace/.cfg` with
   `hooks/` and `config` read-only, and `GIT_DIR`/`GIT_WORK_TREE` (OQ4). The
   system-wide form of the overlay is IMP-065; this item needs it for `.cfg`.
5. Link and approve forms: `dev-envs-forms --project …`, then `quotient allow`
   (operator's act).
6. Gate stays host-side (OQ2). Optional `just lint` follow-up.

Open for design: whether step 4 lands as a general library option (and so
subsumes IMP-065's overlay for ordinary repos) or as a `.cfg`-specific
`extraOptions` entry here first.
