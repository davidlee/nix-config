# Layered dev-env consumer, proven against Smut

## Context

Terms used below:

- **bubblewrap (`bwrap`)** — the unprivileged sandbox that runs a *jailed* agent:
  a private filesystem and PID namespace with explicitly bound paths.
- **`dev-tools`** — a project flake's `packages.<system>.dev-tools`: one
  `buildEnv` (a derivation that symlinks a list of packages into a single store
  path) holding every tool the project's gate needs.
- **gate** — the project's own check command; Smut's `just gate` runs build,
  clippy, `cargo fmt --check`, and tests.
- **direnv / nix-direnv** — loads a dev shell on `cd`. The hook is each
  checkout's `.envrc`, which is globally git-ignored on this host.
- **`drvPath`** — the store path of a derivation's `.drv` file. Equal `drvPath`
  means byte-identical build instructions, so it is the oracle for "same pins".
- **Quotient form** — a per-call agent entry point (`read`, `write`) that the
  *host's* Quotient server launches for a delegate. A jail ships only a
  `quotient` client that talks to the host over a socket.
- **GC root** — a store path the Nix garbage collector will not delete.

Today every project flake is two things at once: the project's shell, and a copy
of this repo's personal agent-jail setup. Smut's lock records the cost — 7 root
inputs, 21 nodes, 6 nixpkgs-ish, of which the `agents` input alone brings 11
nodes, two nixpkgs pins are stale and un-followed (`rust-overlay → nixpkgs_5`,
`devshell → nixpkgs_3`), and `nix flake update` in any project bumps `jail-nix`,
`llm-agents` and `bun2nix` into that project's public diffs. Nobody audits a
graph that size, which is why both stale pins survived.

The correction splits by **ownership**: the project owns "a shell that can build
and test this crate"; this repo owns "a jail with my agents, profiles and
packages". Three roles follow — a **producer** exports `dev-tools`; a
**consumer** (this slice) takes one and builds a shell and a jail; a
**re-publisher** (Oubliette, `/srv/fleet`) hands a project's bundle to a third
party. Only the consumer is in scope here.

```
            ~/flakes/dev-envs/flake.nix        (own lock: nixpkgs, agents, quotient)
              │
project input │   outputs, per system:
(override:    ├─ devShells.jail = [ project.dev-tools ] ++ launcher ++ agent CLIs
 git+file:    ├─ packages.jail  = launcher  (jailed-pi under the specDev profile)
 ~/dev/smut)  └─ packages.quotient-{read,write}
              ▲
              └── ~/dev/smut packages.<system>.dev-tools      (unchanged producer)
```

Two tier-5 inputs, both evidence rather than instruction, and each with a
foreshortened view:

| input | written | could verify | only inferred |
|---|---|---|---|
| `~/dev/smut/nix.local.md` | by an agent inside a Smut jail | Smut's flake, lock, CI, gate | this repo's layout and jail library |
| `layered-dev-envs.local.md` | by a reviewer in this repo | this repo's lib, fleet's consumption seam, Quotient's host side | Smut's build, any gate actually run |

The second corrected the first on four points this slice adopts: a
`buildEnv` is one derivation (so compose `[ projectTools ] ++ extras`, never
`projectTools ++ extras`); *preserve* the project's pins by default; Quotient
forms are built by the consumer but installed on the host; and the natural root
for the factory is a new subflake, because `~/flakes/flake.nix` already consumes
fleet and taking fleet's input back would cycle.

## Scope & Objectives

Build the consumer, and prove it against an **unmodified** Smut checkout. That
is step 1 of three; see Follow-Ups.

| # | deliverable | path |
|---|---|---|
| 1 | consumer subflake: own lock, `project` input, stub project, jail + shell + form outputs | `dev-envs/flake.nix`, `dev-envs/flake.lock`, `dev-envs/stub-project/flake.nix` |
| 2 | direnv entry point: land in `dev-envs#jail` with the current checkout as `project` | `envrc/dev-envs.sh` |
| 3 | host-side form linker: build the project's forms, link and root them | `bin/dev-envs-forms` (+ test) |
| 4 | proof against Smut: same tool `drvPath`, `just gate` green in the jail, forms admitted | notes + README |

Decisions this scope carries into design (each is a design target, not a
settled answer):

- **D1 — project pins win.** `project` is declared *without*
  `inputs.nixpkgs.follows`, so a jail's `rust`/`just`/`mold` are Smut's, not
  this repo's. Making them follow would silently change the compiler and the
  gate's behaviour. The oracle is the two-eval comparison, per system:
  `nix eval ~/dev/smut#packages.<system>.dev-tools.drvPath` must equal
  `nix eval ~/flakes/dev-envs#packages.<system>.devTools.drvPath
  --override-input project git+file:~/dev/smut --no-write-lock-file`. The
  consumer exposes the project's bundle as `devTools` for exactly this
  comparison; the name differs from the producer's `dev-tools` on purpose, so a
  pass-through is never mistaken for a producer contract.
- **D2 — `agents` is declared from GitHub, overridden locally.** `path:./agents`
  (the sketch's form) resolves relative to the flake's own source copy, so it
  breaks in any store copy — including a lock from
  `github:davidlee/nix-config?dir=flakes/dev-envs`, and on the Mac. Follow the
  existing convention for `emacs`/`agents`: declare the remote, override to the
  in-tree checkout in read-only recipes.
- **D3 — keyless jail only.** The project arrives as an *input override*, not as
  a directory convention, so this slice needs no project-key derivation and no
  per-project extras file. One jail, named `jail`. Extras return when a second
  real project needs something Smut's bundle does not provide.
- **D4 — the shell carries the personal CLIs.** Smut's `devshells.default`
  installs `devToolPkgs ++ [ codex ]`; its `dev-tools` is `devToolPkgs` alone.
  A consumer shell of project tools only would therefore silently lose
  `codex` (the MCP server slave). The shell is
  `[ project.dev-tools ] ++ [ launcher ] ++ personal agent CLIs`.
- **D5 — forms are built here, installed on the host.** Merely putting form
  derivations in the jail's package list does not make the host's Quotient
  select them: selection needs the links in the checkout's `.quotient/forms`
  and an explicit `quotient allow`. The linker reproduces the existing
  mechanism (build with `-o .quotient/result-<c>`, then symlink
  `.quotient/forms/<c>` to the form's binary), which is also what keeps the
  form alive — `--out-link` registers a GC root at the symlink — and it carries
  `--no-write-lock-file` so building a form never re-locks the consumer flake.

## Non-Goals

- **Changing Smut's tracked files.** No input removal, no lock slimming, no
  devshell edit. Pointing Smut's *untracked* `.envrc` at the new helper is
  allowed as the last verification step (it is globally ignored and reverts in
  one line); `git status` on tracked paths must be unchanged throughout.
- Step 2 (subtract `agents`/`quotient` from Smut, 21 nodes → 8) and step 4
  (other repos).
- Fleet, Oubliette, capsules, rooms: `dev-tools` is already consumed there and
  stays a project-owned output. No change to `/srv/fleet`.
- `_templates/agents`: the template still writes the *old* pattern into new
  projects, and stays until the new pattern is proven against a second project.
- Environments that are more than packages — shell hooks, service startup,
  offline language dependencies. Smut has none of these (its devshell is
  packages plus two commands), so this slice cannot exercise them; Doctrine and
  Emacs are the step-3 consumers that will.
- SATAN, whose `mkJailedMalebolge` is a genuine product export rather than a
  personal convenience.
- Secrets: none enter Nix source or store paths (POL-001).

## Affected surface

| path | change |
|---|---|
| `dev-envs/flake.nix` | new: inputs, jail/shell/form outputs, `checks.stub` |
| `dev-envs/flake.lock` | new |
| `dev-envs/stub-project/flake.nix` | new: the contract's smallest executable form |
| `envrc/dev-envs.sh` | new: `use_dev_envs`, reusing `use_flake_local`'s override shape |
| `envrc/agents.sh` | maybe: factor `use_flake_local`'s ref so both helpers share it |
| `bin/dev-envs-forms` (+ `-test`) | new: host-side linker |
| `justfile` | two `path:`-invoked checks and two bash tests in `just test`, plus the dev-envs lock guard (design DEC-104) |
| `README.md` | § Jailed Agents gains the producer/consumer split and how a project joins |

The root `flake.nix`/`flake.lock` are **not** touched: `dev-envs` is a
standalone subflake like `dev-tools/`, `agents/`, `emacs/`.

## Summary

One new subflake that consumes a project's `dev-tools` and produces a dev shell,
a jailed `pi`, and the project's Quotient forms — plus the direnv helper and the
host linker that make them reachable. Proven by running Smut's own gate inside
it, with Smut's pins intact and its tracked tree untouched.

## Risks, assumptions, open questions

- **A1** `use flake <ref> --override-input project git+file:$PWD` reaches
  `nix print-dev-env` through nix-direnv. Documented upstream, unverified here;
  it is the first thing that fails and the directive rests on it.
- **A2** Smut's `dev-tools` is a superset of what its gate needs (`rust` carries
  clippy and rustfmt; `just`, `mold`, `sccache`, `cargo-edit`, `shellcheck`,
  `stdenv.cc`). If it is not, the failure looks like a coding error in the gate.
- **A3** The Smut checkout is dirty; findings describe its current tracked
  content, not a commit.
- **R1** A nested `buildEnv` mixes two nixpkgs (the jail's, for bwrap and the
  agent, and the project's, for the tools). Collisions are reported at the outer
  env — expected noise, not a failure; real collisions are a finding.
- **R2** The consumer becomes a single point of failure for every participating
  project's shell. Mitigation is the `.envrc` fallback: no helper → `use flake .`
  and the project's own devshell, so a broken personal flake costs the jail,
  never the build.
- **R3** `--override-input` snapshots the project tree per edit state. Use
  `git+file:` (tracked content only), not `path:`, or `target/` enters the store
  on every evaluation.
- **R4** Long first build: `pi` and the jail's closure are not small.
- **R5** `~/flakes` is a git flake, so a new file does not exist to Nix until it
  is intent-to-added: `git add -N dev-envs/…` before the first eval, or the
  failure is "path does not exist".
- **R6** A lock-writing command carries the override into the invoked flake's
  lock: `nix eval`/`nix build --override-input project …` without
  `--no-write-lock-file` records a `path`/`git file:` node in
  `dev-envs/flake.lock`, which then silently pins the machine's checkout. Every
  override here is read-only and must say so. **Sharpened in design:** the stub
  input's own node is `path = "./stub-project"` — *relative*, verified by
  experiment — so the dev-envs guard rejects `file:` URLs and absolute paths
  rather than every path node, and the root lock's blanket rule cannot be reused
  verbatim (DEC-104).
- **R7** `slice conformance` and `verify-vt` compare git-root-relative paths
  against `~/flakes`-relative selectors, so they report everything as both
  undeclared and undelivered in this repo (ISS-005). Evidence at audit time is
  the explicit commands in § Verification, judged by agent, not those verbs.
- **OQ-1** Does the linker live in `bin/` (with a test, like the other helpers)
  or as a `just` recipe? Recommendation: `bin/`, because it needs the flake
  ref resolution the direnv helper also needs, and `bin/` scripts here are
  tested.
- **OQ-2** Does `envrc/dev-envs.sh` duplicate `use_flake_local`, or does
  `agents.sh` grow a ref parameter? Recommendation: parameterise — one
  override mechanism, two entry points.
- **OQ-3** The pass-through output's name: `devTools` (signals "the project's
  bundle, forwarded") or `dev-tools` (reuses the producer's name).
  Recommendation: `devTools`, resolved by D1.
- **OQ-4** Do the jail and the shell both need the form derivations in their
  package lists, or only the shell? Recommendation: only the shell — forms are
  built and linked from the host, where `nix build` is available.

## Verification / closure intent

- **VT** `dev-envs#checks.<system>.stub`: the factory evaluates against the stub
  project (no `pi` build), and the stub jail's shell carries the stub's
  `dev-tools`. Guards the contract without building agents.
- **VT** `dev-envs#checks.<system>.quotient-forms`:
  `quotient.lib.checkFormFamily` over the consumer's form family, the check this
  repo already runs at its root (`perSystem.nix`). It is the only static guard
  on the forms' bwrap line, which must stay plain words.
- **VT** linker test: a fixture project directory; `<cwd>/.quotient/forms/<c>`
  resolves to the form binary, and `<cwd>/.quotient/result-<c>` exists as the
  GC root. Re-running is idempotent; a project with no forms fails loudly.
- **VA** pin fidelity: the two-`nix eval` `drvPath` comparison in D1 prints
  equal paths. Inequality is a design failure, not a test flake. Both sides run
  with `--no-write-lock-file` (R6).
- **VA** gate parity: `nix develop '~/flakes/dev-envs#jail'
  --override-input project 'git+file:~/dev/smut' --no-write-lock-file
  --command just gate` is green, and the run reports the same `rustc`/`just`
  store paths as Smut's own devshell.
- **VA** the jail launches: `jailed-pi --version` inside the shell, a model
  response through the LLM gateway, and no provider key in the jail.
- **VH** form admission: `quotient allow` on the linked forms; a `read`
  delegate runs in the linked form. Approval stays an operator act.
- **VA** Smut untouched: `git -C ~/dev/smut status --porcelain` shows nothing
  new on tracked paths.
- **VA** no host drift: `just drvs` is unchanged, because the root flake does
  not consume `dev-envs` — it is a standalone subflake, so the whole slice is
  outside every host and home evaluation.
- `just fmt`, `just doctor` clean at this repo's root.

## Follow-Ups

- **Step 2** — subtract from Smut: drop `agents`/`quotient`, the jail and form
  blocks, add `follows` to `rust-overlay` and `devshell`; the lock should drop
  from 21 nodes to 8, and fleet must still evaluate its `dev-tools`.
- **Step 3** — Doctrine, then Emacs: the first consumers with environment beyond
  packages, which is where the customisation API gets designed.
- **Step 4** — the per-project extras file (`projects/<key>.nix`), the project
  key derivation, and the second jail per project.
- `_templates/agents`: rewrite or retire once the pattern is proven twice.
- Audit each exported bundle for gate completeness (Screwtape has none; fleet's
  Quotient target uses `extraTools`).
