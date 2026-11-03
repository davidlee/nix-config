# Layered dev-env consumer, carried to Doctrine

## Context

Terms used below (SL-022 § Context defines bubblewrap, `dev-tools`, gate,
direnv, `drvPath`, Quotient form and GC root):

- **producer / consumer** — a project flake *produces* `packages.<system>.dev-tools`;
  `~/flakes/dev-envs` *consumes* it and builds the shell, the jails and the
  Quotient forms around it (SL-022).
- **crane** — the Nix Rust builder Doctrine's flake uses for `packages.doctrine`.
- **capsule / fleet** — the microVM rooms declared in `/srv/fleet`; a target
  names the project output its guest installs (`toolsPackage`).
- **`jailLib`** — this repo's jail library (`agents/`), whose combinators
  (`set-env`, `tryFwdEnv`, …) shape a jail's environment.

SL-022 proved the consumer on Smut, whose environment is packages and two shell
commands. Doctrine (`~/dev/doctrine`) is the first project whose environment is
more than packages, and the one with the most agent wiring of its own: five
jails, two forms, the `agents` and `quotient` inputs, and a `dirge` re-export.
Its `.envrc` still calls `use_agents_dev`; nothing has moved yet. This slice is
where the pattern that later rolls out to other repos (SATAN, Emacs, …) gets
decided.

What Doctrine's flake carries beyond its tool list (read from
`~/dev/doctrine/flake.nix` on 2026-11-03):

| item | where | nature |
|---|---|---|
| `LD_LIBRARY_PATH` (libstdc++), `UV_PYTHON_PREFERENCE=only-system` | devshell env; jails get the first only | env the tools need |
| forward `DOCTRINE_BIN`; `CARGO_BUILD_RUSTFLAGS` (forms only) | `projectOptions` | host env the tools read |
| darwin iconv `RUSTFLAGS` startup hook | devshell | darwin only |
| `d`, `jd`, `drn`, `jpi`, `jcx`, `jcl`, `jail-zsh` | devshell commands | personal conveniences |
| unjailed `claude`, `codex` | `projectPkgs`, so every jail and form | personal agent CLIs |
| `jailed-{pi,pi-research,claude,codex,shell}` | `jailPkgs` | personal jails |
| `doctrine-quotient-{read,write}` | `quotientForms`; `just quotient-forms` links them under `~/.local/state/quotient/forms`, named by `~/.config/quotient/doctrine.policy.json` | forms, second convention |
| `dirge` | `packages.dirge` | re-export of the agents flake's package |
| crane `doctrine` | inside `packages.dev-tools` (`flake.nix:416`) | the product, for the fleet guest |

No services. The only hook is darwin's. The bun fixed-output derivation is a
build input of the product, not part of the dev environment.

Two findings shape the design:

- **Doctrine's `dev-tools` carries the product.** It exists for the fleet guest
  (`/srv/fleet/targets/doctrine.nix`, `toolsPackage = "dev-tools"`), which
  cannot reach the host's `cargo install`. Taken as the consumer's bundle, every
  `git+file` snapshot of the checkout would be a new crane derivation: a
  release build per direnv reload and per form, whose binary the jail then
  shadows with `/run/doctrine-bin`. (Inferred from the flake; not evaluated.)
- **Dispatch does not use the Nix jails.** `scripts/spawn-confined.sh` confines
  its `pi` and `claude` harnesses with Doctrine's own
  `doctrine worktree jail-prefix`. The five `jailed-*` packages serve
  interactive use only.

Research: `.doctrine/backlog/improvement/056/research/pi.md` (a Doctrine agent,
in-jail; tier-5 evidence). It establishes that the host's Doctrine binary
reaches a jail only as the agents flake's directory bind at `/run/doctrine-bin`,
and that `doctrine install` bakes its own `current_exe()` into gitignored pi
extensions — so in a jail the baked host path dangles. That defect is
Doctrine's, and pre-dates this slice.

A follow-up from the same agent corrects its first account. Doctrine commit
`ff3653dc9` (2026-10-19; verified to exist and touch `flake.nix`, `justfile`,
`flake.lock`) deliberately replaced the crane-store bind of IMP-249's era with
the host install: "one binary for host and jail, so no consumer flake pins a
copy that lags it" (`agents/jailed-agents.nix`). The directory bind cured
IMP-249's actual defect (a file bind pinned the inode that `cargo install`'s
atomic rename replaced), so a store path bought nothing further. Current roles:

| binary | serves |
|---|---|
| `~/.local/share/doctrine/bin/doctrine` (`just install`) | host PATH; every jail, bound at `/run/doctrine-bin` |
| crane store path | `packages.default`; `packages.dev-tools`, for the fleet guest only |
| `~/.cargo/bin/doctrine` | nothing (legacy) |

## Scope & Objectives

Make Doctrine a producer and nothing else, and grow the consumer to serve it,
so that Doctrine's `.envrc` lands in `dev-envs#jail` with the same working
environment its own flake gives today.

Settled by the user (2026-11-03), carried as scope:

- **S1 — jail set.** The consumer builds `pi`, `pi-research`, `claude`, `codex`
  and `shell` jails, and no others. They replace Doctrine's five.
- **S2 — subtract now.** Doctrine's flake loses its jails, forms, devshell agent
  wiring, the `agents` and `quotient` inputs, and `packages.dirge` (dropped, not
  moved).
- **S3 — darwin keeps working, with an escape hatch.** The consumer stays
  Linux-only. On the Mac, Doctrine's own devshell may lose the agent CLIs for
  now, but there must be a named way to get them back (e.g. a darwin-side
  override for agent packages) without re-adding them to Doctrine.

- **S4 — Doctrine's jail options, spelled once (user, 2026-11-03).** Every
  Doctrine-related option a jail or form needs (the install-root bind and its
  in-jail path, the `PATH` entry, `DOCTRINE_BIN` forwarding) has one owner in
  the shared layer (the agents posture `hostDoctrine`, applied by the
  consumer), not one spelling per repo. Today the bind lands at
  `/run/doctrine-bin` while `doctrine install` bakes the path of whichever
  binary ran it into pi's extensions, so pi works only in the namespace that
  installed last. Solve it once, in principle: one path valid in host and
  jail. Rolling it out to the other repos (six `~/dev/*/flake.nix` carry
  their own host-path bind, per research) is out of scope.
  The path is `just install`'s root, `~/.local/share/doctrine/bin` (the
  canonical install, user 2026-11-03). On this host `~/.local/bin/doctrine` is a
  symlink to it, and first on PATH. pi's bake (`current_exe()`, symlinks
  resolved) records the canonical path; codex's (`doctrine:DEC-404`, the PATH
  entry, deliberately not its target) records `~/.local/bin/doctrine`, which the
  jail's persisted home lacks. So "one path in host and jail" must cover what
  every bake site records, not only the bind. Inferred from code; not run.
  *Settled:* DEC-110 (the host-path bind as a runtime argument; `/run/doctrine-bin`
  goes) and DEC-109 (paths are host facts in `agents/doctrine.nix`). One
  correction to the wording above: `DOCTRINE_BIN` forwarding is project data
  (Doctrine's `devEnv.hostEnv`, DEC-114), not the shared layer's.
- **S5 — every path is `~/.local/share/doctrine/bin` (user, 2026-11-03).** It
  goes first on the host PATH and on the jail's PATH, bound at that same path;
  the `~/.local/bin/doctrine` symlink is removed, last: only after
  `doctrine install` has re-baked pi and codex on the host and in a jail, and
  codex's MCP server starts on both sides (RV-046 F-1). Every bake site then
  records one path, valid on both sides.

Raised by the user at design start (2026-11-03), carried as design inquiries
(`doctrine design tree SL-023`):

- **inq-11** — the Doctrine path declared once in Nix (ADR-004 §4: a plain
  constant every consumer imports) and passed to home-manager, the shell and
  the jail env; what `DOCTRINE_BIN` means once set everywhere. → DEC-109.
- **inq-12** — PATH precedence between NixOS session vars, home-manager and
  shell inits, where order matters (doctrine, cargo, npm, …). → DEC-107.
- **inq-13** — the pattern documented somewhere evergreen (a spec for host
  devshells and jails), here or in a follow-up. → DEC-118: a tech spec, this
  slice's last phase.
- **inq-14** — the intended responsibility boundary between
  `agents/jailed-agents.nix` and `dev-envs`. → DEC-108: four layers (host
  facts, jail library, personal consumer, project).

Constraint carried in (Doctrine `ff3653dc9`, the user's own decision):

- **C1 — one Doctrine binary for host and jail: the host install.** No consumer
  output puts a store-built `doctrine` on a jail's or a form's PATH. The host
  install is the only one on PATH, bound at its own host path (DEC-110, which
  replaces the `/run/doctrine-bin` route this constraint first named). A
  supplied Nix-built Doctrine is mounted at `/run/doctrine-nix-bin`, read-only
  and never on PATH (DEC-109). The crane build otherwise serves out-of-tree
  consumers only (`packages.default`, the fleet guest via `capsule-tools`,
  DEC-112).

Design targets, as scoped before design; each is now settled (decision noted):

- **T1 — bundle split.** C1 all but forces this: `dev-tools` carrying the
  product puts a second, lagging binary on every jail's PATH (shadowed by
  `/run/doctrine-bin`, but built per snapshot). Proposed: Doctrine's `dev-tools`
  becomes gate tools only; a new `capsule-tools = dev-tools + doctrine` serves
  the fleet guest, and `/srv/fleet/targets/doctrine.nix` names it. Open: the
  name. → DEC-112: `capsule-tools`, in a three-step order with no gap.
- **T2 — customisation API.** Proposed: the project states what its tools need
  as plain data with no agent concepts — env (`{ VAR = str; }`) and host vars to
  forward (`[ VAR … ]`) — carried on `dev-tools` as `passthru`, so the contract
  stays one attribute and the consumer stays keyless (SL-022 D3). Alternatives
  to weigh: a per-project extras file in the consumer (SL-022's step 4);
  arguments to `use_dev_envs`. `buildEnv` accepting `passthru` is unverified.
  → DEC-114: `passthru.devEnv = { env; hostEnv; }` (`passthru.env` would shadow
  the derivation's own `env`); preferences for every project (agent teams,
  sccache, mold on Linux, `UV_PYTHON_PREFERENCE`) are one host-facts list that
  home-manager exports and the consumer applies.
- **T3 — personal, uniform.** Jail set, devshell commands and the unjailed agent
  CLIs live in the consumer and are the same for every project. Smut gains the
  four extra jails as a side effect; DEC-106's export contract (one `jail`
  package) is superseded. → DEC-113: `jailed-*` packages, `devShells.default`
  with `jpi`/`jcl`/`jcx`/`jsh`; DEC-111: Doctrine keeps only `jd`.
- **T4 — forms convention.** One convention for the rollout: Doctrine's
  state-dir + named per-root policy, or the consumer's in-checkout
  `.quotient/forms` links (DEC-102). Moving Doctrine means editing
  `doctrine.policy.json` and a fresh `quotient allow` (the operator's act).
  → DEC-115: in-checkout links, approved; the policy keeps a fallback.
- **T5 — fidelity oracle.** SL-022's `drvPath` equality is trivially true here
  (the consumer passes the bundle through). Proposed: diff today's
  `jailed-pi` launcher (outer and inner) against the consumer's, with the
  expected deltas enumerated in advance; plus Doctrine's gate green in the jail
  and both forms admitted. → DEC-117.
- **S3's escape hatch** → DEC-116: `agents.pi` on every platform, selected in
  `personal`; claude and codex from their own installers.

## Non-Goals

- The baked-path defect in Doctrine's pi extensions (research § "What the pi
  installer does"), and IMP-234 (installer `--dev` posture). Doctrine's to fix;
  this slice must not make it worse. Specifically: the pi arm bakes raw
  `current_exe()` with none of the PATH guard that `doctrine:DEC-404` gives
  codex's user-level entry (`boot.rs:441,2806`, per the research agent). C1
  keeps the install location where it is. S4 changes only where the jail sees
  it, towards the host path, which makes a baked host path valid in the jail
  rather than invalid. Moving the install root itself is out of scope, and
  would make the pi guard a prerequisite.
- Emacs (IMP-056's second consumer), the home repo (IMP-057), SATAN and other
  repos (step 4).
- Changing how dispatch confines workers.
- `_templates/agents`: retired only after the pattern is proven on a second
  project with more than packages.
- Darwin outputs of the consumer.
- Secrets: none enter Nix source or store paths (POL-001).

## Affected surface

Three repositories and the host.

| repo | path | change |
|---|---|---|
| `~/flakes` | `agents/doctrine.nix` (new), a host-facts env list beside it (new) | host facts (DEC-109, DEC-114) |
| `~/flakes` | `agents/jailed-agents.nix`, `agents/jailed-agents-test.nix`, `agents/README.md` | host-path bind, `/run/doctrine-nix-bin` (DEC-109, DEC-110) |
| `~/flakes` | the host PATH owners (NixOS session env on Linux, darwin home) | one ordered user-bin list (DEC-107) |
| `~/flakes` | `features/dev.nix`, `features/profiles/personal.nix` | new feature `dev.env`: the env list with `sccache`, `mold` (Linux) in the home, selected by `personal` (DEC-114; a feature, not the home base: SPEC-002, RV-046 F-3) |
| `~/flakes` | `dev-envs/flake.nix`, `dev-envs/flake.lock` | five jails, default shell, shorthands (DEC-113); `devEnv` and host list applied (DEC-114); pinned doctrine input (DEC-109) |
| `~/flakes` | `dev-envs/stub-project/flake.nix` | states `devEnv` (DEC-114) |
| `~/flakes` | `envrc/dev-envs.sh` (+ test) | `#jail` → `#default` (DEC-113) |
| `~/flakes` | `bin/dev-envs-forms` (+ test) | used for Doctrine (DEC-115) |
| `~/flakes` | `features/agents.nix`, `features/profiles/{personal,personal-linux}.nix` | `agents.pi` on every platform (DEC-116) |
| `~/flakes` | `README.md` § Jailed Agents, `justfile`, a new tech spec | contract and recipes; DEC-118 |
| `~/dev/doctrine` | `flake.nix`, `flake.lock`, `justfile` (`quotient-forms` goes, `install` clears mold), `.envrc` (untracked) | DEC-111, DEC-112, DEC-114 |
| `~/dev/doctrine` | `scripts/oubliette.sh` (:181-182) | reworded with DEC-112 |
| `~/dev/doctrine` | `tests/e2e_worker_confinement.rs` | only if nested bwrap fails: probe and skip (DEC-111) |
| `/srv/fleet` | `targets/doctrine.nix` | `toolsPackage = "capsule-tools"` (DEC-112) |
| host | `~/.config/quotient/doctrine.policy.src.json` (untracked) → `policy-install` | forms fallback (DEC-115) |

## Risks, assumptions, open questions

- **R1 — cross-repo change.** Doctrine is governed by its own doctrine corpus;
  editing its flake and justfile may warrant a record there (it already has
  `doctrine:IMP-522`, forms). Open: whether this slice is the only record, or
  Doctrine carries a paired item. → DEC-119: a paired Doctrine chore at
  execution; CHR-028 here for the gated `follows` removal.
- **R2 — fleet coupling.** Changing what `dev-tools` holds changes the fleet
  guest unless T1's rename lands in the same step. The two must move together.
  → DEC-112's order. The guest also gains `bwrap` (DEC-111).
- **R3 — jail env parity.** `.envrc` exports reach the shell, but a jail sees
  only what it forwards. Today's jails forward `DOCTRINE_BIN` and set
  `LD_LIBRARY_PATH`; the forms also forward `CARGO_BUILD_RUSTFLAGS`. A missing
  forward fails as a build or link difference, not as an error. → DEC-114
  states every variable's owner; DEC-117's diff enumerates the deltas.
- **R4 — Doctrine's flake is unvalidatable in a jail** (`doctrine:RSK-011`):
  only a host `nix build` proves it.
- **R5 — two nixpkgs in one jail** (SL-022 R1): jail and agents from dev-envs'
  pin, tools from Doctrine's. Doctrine's `agents` input followed Doctrine's
  nixpkgs, so the agent CLIs' pin changes.
- **R6 — first build cost.** Five jails and two forms; pi's closure is large.
- **A1** — SL-022's mechanics (override shape, `--no-write-lock-file`, lock
  guard DEC-104) carry over unchanged.
- **OQ-1** — Is anything else using `packages.dirge`, `packages.bubblewrap` or
  `packages.jailed-*` from Doctrine's flake? (Checked for `dirge`, the user's
  call: drop.)

## Verification / closure intent

DEC-117 is authoritative; in short:

- After all three DEC-112 steps and before subtraction, the launcher diff for
  all five jails shows only the enumerated deltas (RV-046 F-2).
- Doctrine's `just gate` green inside `jailed-pi`; sccache works in jails and
  forms.
- Both forms built by the consumer, linked in the checkout, approved, and run
  once each (DEC-115).
- The bake probe: one `doctrine` path on both sides of the wall.
- Fleet's Doctrine target evaluates against `capsule-tools`: the same guest tool
  set plus the product and `bwrap`.
- Doctrine's flake: no `agents`/`quotient` input; `nix flake check` green on
  x86_64-linux; aarch64-darwin evaluates, as does Draupnir's home.
- `just test` green in `~/flakes`; Smut still loads through `use_dev_envs`.
- The tech spec exists and README points to it (DEC-118).

## Summary

Doctrine stops building its own agent environment and exports only what its
tools need; the consumer grows from one jail to five and learns to apply a
project's stated env. Host facts (Doctrine's paths, the PATH order, and env
preferences true of every project) are spelled once and reach host shells and
jails alike. The pattern the remaining repos follow is decided here.

## Follow-Ups

- CHR-028 — drop the root flake's `doctrine.inputs.{agents,pub}.follows` once
  satan, screwtape and panopticon re-lock Doctrine.
