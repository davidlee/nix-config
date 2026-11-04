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

Superseded 2026-11-04: `.cfg` is read-only. See § Design and handover.

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

Superseded 2026-11-04 by § Design and handover, which is the current scope.

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

## Independent review (2026-11-04)

Probed with plain bwrap on fabricated repos in the home layout (`.cfg` never
written; git 2.56). The real jail and form launchers were not run.

Holds: OQ1 (`path:$HOME/flakes/dev-tools` re-evaluated), OQ2, OQ6 (with the
notes below). Git finds no repo in a jail: observed ("not a git repository (or
any parent up to mount point /workspace)"), so no ASM is needed.

Corrections:

- **The body's "Pi runs here unconfined" is stale for delegates.** `~/flakes`
  is a policy root and takes the machine-default forms (IMP-048). A project form
  adds tools and env, not confinement.
- **OQ4's `GIT_DIR`/`GIT_WORK_TREE` env breaks fixtures.** With them set,
  `git init <tmp>` fails ("could not set 'core.repositoryformatversion'") and
  `git add` in that directory fails. Eight test scripts here use `git init` or
  `git -C`. Replacement that works: a static `.cfg/config` overlay with
  `core.worktree = ..`, a read-only `.git` file holding `gitdir: .cfg`, and
  `GIT_DISCOVERY_ACROSS_FILESYSTEM=1` (the bind is a mount boundary). Both files
  are relative, so one store copy serves any mount parent.
- **OQ4's path-scoped safety does not hold.** `git commit -a` from the jail
  committed every outside-`flakes/` path as deleted, and the host's `git status`
  then showed nothing (`showUntrackedFiles = no`): 259 paths here. `git add -u`
  is whole-tree, though `CLAUDE.md` calls it safe.
- **"Jail-only skip-worktree" is not possible.** The index is shared: a bit set
  in the jail hid a later host edit from the host's `git status`.
- **Forms differ from jails.** A form binds its root at its own path, not under
  `/workspace`, and `mkFormFamily` applies one `options` to `read` and `write`
  alike, so a read-write `.cfg` would reach the `read` form.
- **A launch from a subdirectory maps every path wrongly** (the launch dir lands
  at `/workspace/<basename>`). The bind must apply only when `$PWD` is the
  project root.
- **The overlays do not stop planted config.** See IMP-065 § Review: `commondir`
  in `.cfg` redirects host git to a planted config past a read-only `config`.
  A placeholder `commondir` holding `.`, bound read-only, closes that (probed).
- **Residual risk is understated.** A writable `~/flakes` already holds host
  execution: `envrc/dev-envs.sh` runs unjailed on entry to every project, and the
  flake itself reaches root at the next switch. Still better than an unjailed
  agent, but the git overlays are not what bounds this jail.

Notes on other decisions:

- OQ1: watch `dev-tools/*.nix`, since step 2 adds `treefmt.nix`.
- OQ5: `.envrc` needs `use_dev_envs … || :`, as it has no `use flake` fallback.
  `agents/*.nix` are watched, so in this repo an edit there rebuilds the jails at
  the next prompt, and a broken edit fails the shell.
- OQ6: one definition shares config, not versions: `dev-tools` and root pin
  different nixpkgs, so jail and gate formatters can disagree. Set
  `projectRootFile` on the wrapper, and `treefmt-nix.inputs.nixpkgs.follows`.
- `.quotient` is ignored only by an uncommitted line in `~/.gitignore_global`.

A jail-only `core.hooksPath` pre-commit refusing paths outside `flakes/` stopped
`commit -a` and allowed a scoped commit; `--no-verify` passes it. Not needed
with a read-only `.cfg`; kept in case jail commits are revisited.

## Design and handover (2026-11-04)

Status: sketch approved by the operator; not implemented. No slice (single
phase, repo sizing rule). This section is the current scope.

### Decisions

| # | question | decision |
|---|---|---|
| D1 | `.cfg` in jails | **Read-only**, reversing OQ4. Jails and forms alike. Commits stay host-side, as the gate does |
| D2 | general option or `.cfg`-specific | **`.cfg`-specific.** The general overlay stays in the backlog as IMP-065, rescoped |
| D3 | jails rebuild on `agents/*.nix` edits in this repo | **Accepted.** `.envrc` wiring stays (OQ5) |

Why read-only: it removes `commondir`, `commit -a`, shared-index and gitlink
planting in one move, and one bind serves both form capabilities. Probed:
`status`, `diff`, `log` and `blame` work; `git add` fails on `index.lock`; a
`commondir` write fails. Cost accepted: jailed agents cannot commit, and
`git status` lists the 259 outside-`flakes/` paths as ` D`.

### Shape

```
~/.cfg ──ro──────────> T/.cfg
store: config ──ro───> T/.cfg/config   core.worktree = ..
store: gitfile ──ro──> T/.git          gitdir: .cfg
~/flakes ────────────> T/flakes        T = /workspace (jail), $HOME (form)
```

`config` (no host `config` is shown, so remotes and branch tracking are absent):

```ini
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	worktree = ..
[status]
	showUntrackedFiles = no
```

### Steps

1. **`use_dev_envs`** (`envrc/dev-envs.sh`): add `--project <ref>`, spelled as in
   `dev-envs-forms`. With it, skip the toplevel lookup, pass the ref to
   `--override-input project`, and watch `<dir>/*.nix` and `<dir>/flake.lock`
   (`<dir>` = the ref less `path:`). Tests: `envrc/dev-envs-test`.
2. **`dev-tools`:** add `dev-tools/treefmt.nix` (the program set), imported by
   `perSystem.nix`. Add a `treefmt-nix` input with `inputs.nixpkgs.follows`, build
   the wrapper with `projectRootFile = "flake.nix"`, and add it to `paths`.
   `git add` the new file: root reads tracked files only.
3. **`~/flakes/.envrc`:** source the helper, then
   `use_dev_envs --project "path:$HOME/flakes/dev-tools" || :`. Keep the
   `SLEIPNIR_BUILD` export. `|| :` because there is no `use flake` fallback.
4. **Git access:**
   - New `agents/outer-git.nix`: the two store files and one `add-runtime` block,
     taking the git dir's name and `T`. It binds only when `dirname "$PWD"` is
     `$HOME`, so a launch from a subdirectory has no repo rather than wrong paths.
     Sets `GIT_DISCOVERY_ACROSS_FILESYSTEM=1`.
   - Export it from `agents/jailed-agents.nix` beside `tryFwdEnv`.
   - New key `passthru.devEnv.outerGitDir = ".cfg"` on `dev-tools`.
     `dev-envs/dev-env.nix` validates it (a bare name) and `dev-env-test.nix`
     covers it. Update SPEC-003, whose contract lists only `env` and `hostEnv`.
   - `dev-envs/flake.nix`: one line for the jails (`T = /workspace`), one for the
     forms (`T = "$HOME"`). Absent key: nothing changes for other projects.
5. **Forms:** from `~/flakes`, `bin/dev-envs-forms --project
   "path:$HOME/flakes/dev-tools"`, then `quotient allow` for each form. That is
   the operator's act.
6. **Docs:** README § Jailed Agents (`--project`, `outerGitDir`). `~/flakes/CLAUDE.md`:
   in a jail git is read-only, and ` D` paths outside `flakes/` are expected.
7. **Gate:** stays host-side. `just lint` remains optional.

### Verification

- Red first: a behaviour test beside the library, built on the recipe below,
  asserting `status`/`log` work, `git add` and a `commondir` write fail, a
  `git init` fixture in `/tmp` works, and a subdirectory launch finds no repo.
- `checks.quotient-forms` on the real family. By quotient's `docs/nix-forms.md`
  runtime binds are invisible to it and listed as residue; never run here.
- Launch one real jail and one real form in `~/flakes`: `git log -1`,
  `git status -- .`, `git add` refused.
- `just test`, `just gate`, lint and format.

### Unverified, to check while implementing

- That a form can mount at `$HOME/.cfg` and `$HOME/.git`. Its docs say runtime
  args come last and mount points are created in what lies beneath the home,
  so expect an empty `.git` and `.cfg` to appear in the persisted home on the
  host. If the mount fails, use the same `T` logic with a different parent.
- That the 8 test scripts using `git init`/`git -C` pass in a jail, and which
  other script tests run without `nix`. Only a minimal fixture was probed.
- That root and `dev-tools` formatters agree; their nixpkgs pins differ
  (`dev-tools` about 12 days older).

### Operational notes

- After pushing step 2, the oubliette room takes treefmt through the fleet's
  `dev-tools` input (`/srv/fleet/flake.nix`). That needs a fleet lock bump.
- The `.quotient` ignore is an uncommitted line in `~/.gitignore_global`: the
  operator's change, left alone. Commit it before linking on another checkout.
- Git safety here: never `git stash` or `git checkout`, and scope every command.

### Probe recipe

The scratch directory is disposable, so this is the reproducible form.
`-c`-style identity and `init` details are omitted.

```bash
BW="bwrap --ro-bind /nix /nix --ro-bind /run/current-system /run/current-system \
  --ro-bind /etc /etc --proc /proc --dev /dev --tmpfs /tmp --tmpfs /workspace \
  --setenv PATH $PATH --setenv HOME /tmp --unshare-pid"
# fixture: home/{flakes/f,.config/c} tracked; cfg/ a separate git dir;
# home/.git = "gitdir: <abs>/cfg"; cfg/config core.worktree = <abs>/home
$BW --bind home/flakes /workspace/flakes --ro-bind cfg /workspace/.cfg \
  --ro-bind jailcfg /workspace/.cfg/config --ro-bind gitfile /workspace/.git \
  --setenv GIT_DISCOVERY_ACROSS_FILESYSTEM 1 --chdir /workspace/flakes -- bash
```

bwrap needs absolute source paths. A hook in this minimal jail needs a store-path
shebang: there is no `/bin/sh`. In git config `;` starts a comment, so a
`core.fsmonitor` payload belongs in a script.
