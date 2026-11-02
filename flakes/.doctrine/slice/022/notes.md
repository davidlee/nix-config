# SL-022 notes

## Review passes

**Pass 1 — RV-044 (design, human lane).** 2026-11-02. Ten sections attested at
revision 32; no findings raised. Scope re-read against DEC-099..DEC-106 and
updated in two places (the `justfile` row became the definite gate wiring, R6
gained the relative-path-node sharpening). Design-target selectors narrowed from
three scoping globs to the nine exact paths § Code impact commits to.

**No further pass before planning.** What remains uncertain is empirical rather
than argumentative, and each item is cheaper to settle by running one command in
phase 1 than by reading more prose:

1. that `quotientFormFamily`'s `packages` really is what a form's PATH is built
   from — asserted from `quotient/nix/form-family.nix`'s signature, never from a
   form that was built and inspected;
2. that `jail.nix` renders the project bundle into the launcher's text in one of
   the two forms `checks.stub` accepts (the bundle's path, or a flattened
   member's);
3. that a relative `path:` input locks relatively — verified during design by
   experiment; re-checkable in phase 1 by reading `dev-envs/flake.lock`.

A further adversarial pass is worth it only if phase 1 falsifies one of these —
and then the finding belongs on a new RV against the implementation, not on a
re-review of this design.

## Working notes

**Section order is not the section number.** The design run stores sections in
its own order and materialises them in that order: the rendered document runs
sec-1, sec-2, sec-3, sec-4, sec-5, sec-10, sec-6, sec-7, sec-8, sec-9 — i.e.
`sections` are numbered for the *reader's* sequence, not numerically. Re-declaring
a section does not move it. Never edit `design.md` by hand: it is materialised,
and the run compares its digest.

**A confined session changes how phases verify.** In this session `~/.cfg` (the
home repo's git dir) and `~/.cache` are read-only: `git add -N` and commits fail,
and a git-resolved flake ref cannot see a file the session just created. Phases
evaluate through `path:~/flakes/dev-envs#…` with `XDG_CACHE_HOME` redirected;
staging and committing belong to the operator or a non-confined session
(`mem.fact.flakes.confined-session-ro`). Builds work.

**Two facts established during design, with their evidence.** A relative `path:`
flake input is locked as `path = "./stub-project"`, not as an absolute path
(synthetic flake in `/tmp/lockprobe`). The dev-envs lock guard — reject `file:`
URLs and absolute path nodes — passes that relative node and fails an absolute
one (same synthetic lock, mutated). Both are re-runnable in a minute if a later
reader doubts them.

**`DEC-099` is superseded, not amended.** The first export contract put the form
linker in the dev shell; drafting found that a flake cannot read `../bin/…` from
its own store copy, so `DEC-106` replaces it and keeps the linker a repo script.
The pair is the record of why the first answer was wrong.

**One premise drift found at planning.** `design.md` § Gates and locks cites the
root lock guard at `justfile:64`; it is at `:65`. The claim is unaffected (the root
rule forbids every path node), so the design was not reopened; the plan cites
`:65`. Also re-verified at planning: `quotient` at the pinned `v0.6.0` has both
`mkFormFamily`'s `packages ? [ ]` and `checkFormFamily` — the design's two
quotient premises hold against the pin, not just against the `~/dev` checkout.

## PHASE-01: what the phase learned that outlives it

**The design's stub check grepped the wrong file.** `packages.jail` is not the
launcher when `gateway` is set: `mkJailedPi` returns `gatewayJail.wrap inner`
(`agents/gateway-jail.nix`), a 16-line wrapper that checks the key file and run
directory and `exec`s the real launcher. `add-pkg-deps` renders
`${lib.getBin pkg}/bin` on the **inner** launcher's PATH, so the design's
`grep ${lib.getBin jail}/bin/jailed-pi` matches nothing and the check fails for
the wrong reason.

Settled empirically, in the design's favour where it matters: the bundle *is*
rendered as `<dev-tools>/bin` (the design's first alternative, not flattened
members), so `needles` is `[devTools]` alone and `probe` stayed in the stub as a
fixture only (DEC-103's rationale survives, its mechanism does not). The chosen
mechanism — operator-decided, since it departs from a locked design — follows
exactly one `exec`, resolving the target through `builtins.readFile` so the inner
launcher becomes a build input (a store *reference* is not one). Design text § The
flake, in full now disagrees with the code here: reconcile at `/audit`.

**`quotientFormFamily.packages` really is a form's PATH** (design's other flagged
uncertainty, settled): `packages` → `add-pkg-deps` → `<bundle>/bin` in the
read-form launcher; `checks.quotient-forms` passes on the stub family.

**The relative input's `narHash` is a sentinel, not the stub's hash.** Locked as
`lastModified = 1`, `narHash = sha256-gmt/SQp9…`; the stub's own NAR hash is
`sha256-C3PFa6…`, and adding a file to the stub leaves the recorded value alone.
Substituting a real hash breaks evaluation outright ("cannot fetch input
'path:./stub-project?narHash=…' because it uses a relative path"). Never "fix"
that hash; a lock guard judges node shape only.

**Two mechanical notes.** A flake's `outputs` needs a trailing `...` — nix passes
`self`, and a strict pattern fails with "called with unexpected argument 'self'".
And `nix flake lock` cannot run inside the git worktree here: the git-resolved
self-ref cannot see untracked new files, so the lock was minted from a `path:`
self-ref (`nix flake lock path:…`), which still records the relative stub node.

## PHASE-02: the link target the design got wrong

**`.quotient/forms/<c>` must resolve to `<form>/bin/quotient-<c>`, not to
`bin/jailed-quotient-<c>`.** The design's linker sketch linked the launcher; that
file does not exist in the form package's output. A family member is two
derivations: `family.<c>` is `writeShellScriptBin "quotient-<c>"`, which takes the
session directory and execs `<launcher>/bin/jailed-quotient-<c>` from another
store path. Quotient's `probeProjectForm` (`src/server/forms.ts`) resolves the
link and requires an executable regular file, so the design's link would be
refused as dangling. Corrected in `bin/dev-envs-forms`; evidenced by
`quotient/docs/nix-forms.md:95-131` and by an end-to-end run of the real linker
against the stub project (both links resolve, both executable, lock unwritten).
Design text § Quotient forms now disagrees with the code here: reconcile at
`/audit` alongside the PHASE-01 check-mechanism drift.

**The helper and the linker do not share code, by design.** `use_flake_local`
retargets inputs of the *current* flake; `use_dev_envs` substitutes a *different*
flake for the current one. A shared helper would parameterise away the only thing
they have in common.

## PHASE-03: the wiring, and what the proof cost

**`just test` gains four lines and one guard, in the recipe's own groups.** The
design sketched the four lines as one block; they went into the recipe's two
existing groups instead — the two `nix build …/dev-envs#checks…` beside the
`path:` agents checks, `envrc/dev-envs-test` beside `envrc/agents-test`,
`bin/dev-envs-forms-test` beside `bin/dev-checkouts-test`. The sharpened lock
guard sits immediately after the root guard, so both lock invariants fail fast and
adjacent. Ordering, not content: § Gates and locks is unaffected.

**This session's read-only surface is wider than PHASE-01/02 recorded.** Not just
`~/.cfg` and `~/.cache`: every path under `$HOME` except `~/flakes` is read-only,
and `GIT_CEILING_DIRECTORIES=/home/david` makes `git rev-parse` inside `~/flakes`
answer "not a git repository". Three measured consequences:

- `~/dev/smut/target` is read-only, so a project's gate cannot run *in* the
  checkout: cargo dies on `target/debug/.cargo-build-lock` (os error 30). The gate
  was proven in a writable export of the same commit
  (`git archive HEAD | tar -x -C /tmp/…`) with `CARGO_HOME`/`CARGO_TARGET_DIR` on
  `/tmp`, while the environment still came from the checkout's own `git+file:`
  project input.
- `~/.config/llm-gateway/keys/` is empty here: the gateway runs
  (`/run/llm-gateway/api.sock` listening) but no `pi` key *file* exists, so
  `jailed-pi` stops at its wrapper precondition. The launch was proven with `HOME`
  pointed at a shim holding a key file for the same gateway, which also makes the
  persisted home writable.
- `bin/dev-envs-forms` cannot run inside `~/flakes` in this session (no git
  toplevel, and it would write `.quotient/` into the repo); it was proven against
  the stub in PHASE-02 and remains an operator act (VH-1).

**Two pre-existing failures, neither this slice's.** `just drvs` aborts at
`homeConfigurations`: `elfutils-0.195` is unavailable on `aarch64-darwin` in the
pinned nixpkgs, so one group (`nixosConfigurations`) prints before the recipe
stops; the other groups, taken one at a time through the same `_drvs` sub-recipe
with the same overrides, are byte-identical before and after this phase. And
`just test` is red at `features/session/snooze-nag-test` (justfile:90): the script
draws the whole `Snooze 5m,20m,40m,60m` ladder where the test expects one label,
reproduced standalone with no slice file involved. Both for `/audit`, and both now
backlog items.

**The proof itself.** Pin fidelity: the project's
`packages.x86_64-linux.dev-tools.drvPath` and the consumer's
`packages.x86_64-linux.devTools.drvPath` are the same derivation
(`3mwyi9mlbv6w60iwsrd91f82dfnczcq2-smut-dev-tools.drv`). Gate parity: `just gate`
green in `dev-envs#jail` (build, clippy ×2, fmt, test ×2; the largest suite 379
passing), with `rustc`, `just` and `mold` resolving under
`/nix/store/70fngz64q1j7bj6fimg5h93gz8x0ac1i-smut-dev-tools/bin` — the project's
own bundle, at `rustc 1.100.0-beta.7`. Jail: `jailed-pi` starts in
`/workspace/smut` and answered through the gateway; the only key-shaped variable
inside was `PI_PROVIDER`, no provider key.

**The plan's `git+file:~/dev/smut` is shorthand.** A flakeref does not expand
`~`; the working form is `git+file:/home/david/dev/smut`.

**A doc block I wrote was broken, twice over (F-5).** README's *by hand* join
example used `path:~/flakes/dev-envs#jail`. Two independent traps: no shell expands
`~` mid-word, and this interactive zsh sets `extendedglob`, so an unquoted `#` is
that glob's repetition operator and the word dies with `no matches found` — not a
comment, but the same effect. The operator hit both and used an absolute path plus
`\#`. Corrected to `"path:$HOME/flakes/dev-envs#jail"` — the form
`envrc/dev-envs.sh` always used — and verified under `zsh -i`, not `zsh -c`
(`mem.fact.nix.flakeref-no-tilde`). The helper was never affected; only the prose
was.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-11-02 · PHASE-03 completed (justfile wiring + lock guard, README § Jailed Agents, the Smut proof) · nothing committed — the session's `$HOME` is read-only except `~/flakes`

### Produced
- SL-022 scoped, designed and planned: design run `dr-01a19c02` at revision 36, stage `locked`; ten sections; plan authored with three phases; slice at `ready`, **3/3 phases complete** — next is `/audit` (the two design drifts and the two pre-existing failures are its agenda).
- `.doctrine/slice/022/` (scope, `design.md`, `plan.toml`, `plan.md`, `notes.md`) plus `.doctrine/state/slice/022/` exist on disk and are UNCOMMITTED: staging and committing belong to the operator.
- research artefact `research/research.md` (gitignored, disposable) with its baseline restamped after planning.
- ✓ **PHASE-01** (uncommitted): `dev-envs/flake.nix`, `dev-envs/flake.lock`, `dev-envs/stub-project/flake.nix`. Seven outputs on `x86_64-linux` (both systems evaluate), `checks.stub` green and red under the right mutation, `checks.quotient-forms` green. Nothing consumes it yet; no `stub-project/flake.lock`.
- ✓ **PHASE-02** (uncommitted): `envrc/dev-envs.sh` + `envrc/dev-envs-test` (14 checks), `bin/dev-envs-forms` + `bin/dev-envs-forms-test` (23 checks). Shellcheck clean; neither suite builds a form, jail or `pi`, and the linker's suite refuses if the real `nix` would be used.
- ✓ **PHASE-03** (uncommitted): `justfile` — two `dev-envs#checks` builds and the two bash suites in `test`, plus the sharpened `dev-envs/flake.lock` guard (red on an absolute path node and on a `file:` URL, green on the real lock, mutation reverted byte-identically); `README.md` § Jailed Agents — producer/consumer split, joining steps, form workflow, degrade-to-less.

### Learned
- `mem.fact.flakes.relative-path-input-lock` — a relative `path:` input locks relatively … and its `narHash` is a load-bearing **sentinel**, not the fixture's hash (extended in PHASE-01).
- `mem.fact.flakes.jail-launcher-indirection` — a gateway jail is a wrapper that `exec`s the real launcher; composition is rendered in the inner one, and `builtins.readFile` is what puts it in a sandbox.
- `mem.pattern.doctrine.design-run-mechanics` — sections render in stored order, a section cannot be deleted, a checkpoint must dispose an inquiry and create a record, and a record's kind fields live under `facet`.
- `mem.fact.quotient.form-family-api` — `mkFormFamily` takes `packages`, `quotientFormFamily` forwards unrecognised arguments, `checkFormFamily` exists at the pinned `v0.6.0`; confirmed on a built form — and **the project link must name the form wrapper `bin/quotient-<c>`, not the launcher** (extended in PHASE-02).
- `mem.fact.flakes.confined-session-ro` — this session's read-only git dir and cache; **extended in PHASE-03**: every `$HOME` path except `~/flakes` is read-only, `GIT_CEILING_DIRECTORIES=/home/david` blinds git inside `~/flakes`, a project's gate needs a writable export of the same commit, and a nested jail needs a `HOME` shim for the gateway key file and the persisted home.
- `mem.fact.flakes.drv-gate-aborts-at-home` — `just drvs` stops at `homeConfigurations` (`elfutils-0.195` on `aarch64-darwin`); the other five groups taken through the same `_drvs` sub-recipe with the same `local_override` are stable and comparable.
- `mem.fact.nix.flakeref-no-tilde` — `path:~/…` reaches nix with a literal `~` and fails; write the ref quoted, `"path:$HOME/…"`, and the `#` needs no escaping either (F-5).

### Open
- DEC-099 — the first export contract; superseded by DEC-106, kept as the record of why it was wrong.
- DEC-100 — the project input and the read-only override discipline.
- DEC-101 — the consumer's single jail record.
- DEC-102 — forms built by the consumer, linked on the host.
- DEC-103 — the stub project as the contract's executable form.
- DEC-104 — the repo gates and the sharpened lock guard.
- DEC-105 — degrade to less environment, never to a different one.
- DEC-106 — the revised export contract.
- No QUE / ASM / CON outstanding: the three empirical uncertainties are carried in § Review passes and settled in PHASE-01 by VA-3.
- **ISS-022** — `features/session/snooze-nag-test` fails on HEAD (the script draws the whole ladder), so `just test` cannot be green end to end. Found by PHASE-03; not this slice's to fix. Related: SL-022.
- **ISS-023** — `just drvs` aborts at `homeConfigurations` (`elfutils-0.195` unavailable on `aarch64-darwin`), hiding five groups. Found by PHASE-03; evidenced around, not fixed. Related: SL-022.
- **VH-1a ✓ (operator, 2026-11-03)** — Smut's `.envrc` cut over to `use_dev_envs`; operator: "cutover worked". The join is proven in anger in a real checkout.
- **VH-1b ✓ (operator, 2026-11-03)** — `bin/dev-envs-forms` + `quotient allow` + a `read` delegate in a Smut checkout; operator: done. Not itemised (capability, identity, delegate output) — that detail is the operator's to give, and the agent does not invent it. **All PHASE-03 criteria are now evidenced.**
