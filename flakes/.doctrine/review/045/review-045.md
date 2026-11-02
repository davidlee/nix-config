# Review RV-045 — reconciliation of SL-022

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

<!-- Pre-reading + lines of attack: what this review is probing, the invariants
     it must hold the subject to, and where the bodies are likely buried. Seeded
     at `review new`; the reviewer fills it before raising findings. -->

**Subject.** SL-022 — the layered dev-env consumer (`dev-envs/`, `envrc/dev-envs.sh`,
`bin/dev-envs-forms`), its join to `just test`, and the proof against an unmodified
Smut. Three phases complete; the operator has since done VH-1 in anger.

**What this pass asks.** Not "does the code work" — the phases proved that — but
"does the delivered thing match what the design and plan said it would be, and is
every divergence dispositioned". Facet `reconciliation`, subject rung 1 (the
slice), self-audit (one agent driving both roles).

**Lines of attack.**

1. **Conformance.** Nine `design-target` selectors against what git actually
   touched. `doctrine slice conformance 22` reports `unavailable — no recorded
   source deltas`: the registry resolves into the home repo's git common dir,
   which is read-only in the auditing session, so `record-delta` cannot run. The
   same comparison is therefore run by hand against the single commit that landed
   the slice (`c8aa633b`, parent `ca2257cc`).
2. **Design drift.** Where implementation and `design.md` disagree, and which side
   is right. Two are known from PHASE-01/02 (the stub check's gateway-wrapper
   indirection; the quotient form's link target). Any command in the design that
   cannot run as written is a third, sharper class.
3. **The gate.** `doctrine check gate` — does the repo's own gate certify the
   merged state, including the four new `test` lines?
4. **Pre-existing failures.** Which reds are the slice's, which are inherited, and
   is each owned somewhere durable rather than in a conversation.
5. **The operator's acts.** VH-1 was performed by the operator. Their report is
   the evidence; nothing here may restate it as the agent's own observation.

**Invariants this pass holds the slice to.**

- `dev-envs/flake.lock` keeps the published `agents` flake; every local override is
  read-only (`--no-write-lock-file`) and never enters a committed lock. A relative
  path node (the stub) is legitimate; an absolute one is not.
- The project keeps its pins: the consumer composes `packages.<system>.dev-tools`
  and adds nothing to it, so `dev-tools.drvPath` is unchanged by consumption.
- The consumer sits outside every host and home evaluation — it cannot move
  `just drvs`.
- No `follows` on any input, no extras file, no second jail, no form derivation in
  the jail's package list.
- Absence of the personal layer degrades to the project's own devshell; a *broken*
  personal layer stays loud rather than silently different.

## Synthesis

**Closure story.** SL-022 delivered a consumer flake that takes a project's
`packages.<system>.dev-tools` and builds the shell, the jail and the quotient forms
around it, without the project knowing anything about agents. Three phases, each
green on its own, and a proof against an unmodified Smut checkout: the machine
produced the same `dev-tools` derivation from both sides
(`3mwyi9mlbv6w60iwsrd91f82dfnczcq2-smut-dev-tools.drv`), the project's own gate ran
green inside the consumer's jail with `rustc`, `just` and `mold` resolving out of
that same bundle, `jailed-pi` started in `/workspace/smut` and answered through the
gateway, and the operator has since cut a real checkout over to `use_dev_envs` and
linked and approved forms by hand.

This pass added no new behaviour to the slice; it interrogated what shipped. Two
divergences had already been found empirically during implementation, both with the
code right and the design text stale — the stub check's gateway-wrapper indirection
and the quotient form's link target. A third, sharper class turned up: two of the
design's own commands cannot run as written, because a flakeref does not expand `~`.
That same defect reached the README and was found in anger by the operator, which is
the strongest evidence available that the design text is a live artefact and not a
historical record.

Every finding is terminal; none is a blocker. Nothing in SL-022 makes the tree less
safe to ship than it was: the slice adds files, four `test` lines and one lock guard,
and touches no host or home evaluation.

**Conformance.** `doctrine slice conformance` is unavailable (See F-6), so the same
comparison was run by hand against the single commit that landed the slice:
nine declared design-target selectors, nine delivered, zero undeclared code paths,
zero undelivered selectors. The remaining 26 paths in that commit are the slice's
own `.doctrine/**` records.

**Standing risks.**

- **The host-drift gate is blind.** `just drvs` cannot complete (ISS-023), so five
  of its six groups are unchecked by the standard command. EX-6's evidence is a
  per-group substitution, which is comparable run to run but is not the gate anyone
  will run next time.
- **Form approval is hand-only and identity-pinned.** Every rebuild that changes a
  form's output is a new identity; an unapproved rebuild refuses `form-unapproved`.
  That is deliberate, and it means a toolchain bump is a two-step operator ritual.
- **VA-3 was proven under a `HOME` shim.** The unshimmed launch was proven to refuse
  correctly (empty gateway key file), and the jail was proven to start and answer
  under a shim holding a key for the same gateway. What was never exercised is an
  unshimmed launch with a properly issued `pi` key — that path is the operator's
  normal one and has since worked in anger via VH-1.
- **Linux-only coverage.** The four new `test` lines are `uname -s` gated, and the
  consumer defines no Darwin outputs by design, so the Mac path is the `|| use flake .`
  fallback — asserted by the bash suite, never exercised on a Mac.
- **One commit for three phases.** The delta registry cannot attribute paths to a
  phase even once writable (F-6).

**Tradeoffs consciously accepted.**

- The stub's `probe` survives even though nothing greps it: DEC-103's rationale
  (a fixture that lets the check accept either rendering) outlived the mechanism.
- `--override-input agents` appears only in the read-only `just test` recipes. A
  local `agents/` edit therefore reaches `just test` but not the direnv path until
  the consumer is relocked — the same discipline as the root flake's `tree_override`.
- Gate parity was proven in a writable export of the same commit, because the
  checkout itself is read-only in the auditing session. Same commit, same project
  input, same environment; only the mount changed.
- The README join example ships quoted (`"path:$HOME/flakes/dev-envs#jail"`) rather
  than terse, because the terse form is not portable to the author's own shell.

**Where the bodies would be buried, if anywhere.** The two claims that would hurt
most if wrong — that `quotientFormFamily`'s `packages` really is a form's PATH, and
that the jail renders the project bundle into the launcher — were both settled
empirically in PHASE-01 against built artefacts, not argued from signatures. Both
stand.

**For the reader.** Three Doctrine sources carry the reasoning this pass leaned on:
`doctrine show DEC-100` (the project input and the read-only override discipline —
why no override may reach a committed lock), `doctrine show DEC-104` (the repo gates
and the sharpened lock guard — why this lock needs a different rule from the root's),
and `doctrine show RV-044` (the locked design review this audit reconciles against).
The two backlog items it raised are `doctrine show ISS-022` (resolved) and
`doctrine show ISS-023` (open).

## Reconciliation Brief

The design document is **materialised** by its run (`notes.md` § Working notes), so
none of these are hand edits to `design.md`: each goes through the design run
(`doctrine design apply` for section text, then `doctrine design materialise`; use
`doctrine design adopt` only if the file was edited outside the run).

### Per-slice (design run)

- **design.md § The flake, in full — F-1.** Rewrite the `checks.stub` description to
  the shipped mechanism: `packages.jail` is the gateway wrapper
  (`agents/gateway-jail.nix` `wrap`), which `exec`s the real launcher; the bundle is
  rendered in the inner launcher, so the check follows exactly one `exec`, resolving
  the target through `builtins.readFile` because a store reference is not a build
  input. `needles = [devTools]` alone — the bundle is rendered as its own `/bin`,
  never flattened members, so the stub's `probe` stays as the contract's fixture and
  is not a needle. (The rationale in § The stub project survives unchanged.)
- **design.md § Quotient forms — F-2.** Replace the link target
  `bin/jailed-quotient-<c>` with `bin/quotient-<c>`: the family member is
  `writeShellScriptBin "quotient-<c>"`, which execs the launcher from a *different*
  derivation, and quotient's `probeProjectForm` requires an executable regular file,
  so the design's target is dangling (`quotient/docs/nix-forms.md:95-131`). Keep the
  sentence that a rebuild changing the output is a new form needing re-approval.
- **design.md § Verification — F-3.** Replace every `git+file:~/dev/smut` with
  `git+file:/home/david/dev/smut` (or `$(git rev-parse --show-toplevel)`) in the
  pin-fidelity, gate-parity and jail bullets, and state once that a flakeref does not
  expand `~` — the commands as written cannot run, which is how the same trap reached
  the README.

### Governance/spec (REV)

- **None.** No ADR, policy, standard, spec or requirement is contradicted by what
  shipped. DEC-099…DEC-106 are this slice's own decision records and already read
  correctly (DEC-099 is superseded by DEC-106 by design, not drift).

### Off-surface, owed before closure

- **F-6 (fix-now, mechanical).** Run three `doctrine slice record-delta` calls from a
  writable tree — PHASE-01/02/03 each `--start ca2257cc --end c8aa633b` — so
  `conformance` stops reading clean-by-absence. Coarse by construction: one commit
  carries all three phases. Not a document edit, so not a brief item above.

## Reconciliation Outcome

Basis: RV-045's brief, approved by the operator ("go" on the three named design
items), plus one mechanical item the audit marked off-surface.

### Direct edits applied

`design.md` is materialised and its run is `locked`, and the engine rules on the
instrument: `doctrine design adopt` refuses with *"run is locked; adopt refuses. To
correct a run still governing execution, regress to reviewing first; **at reconcile,
edit design.md directly and do not adopt**."* So the three corrections are direct
edits to the document, as the reconcile surface prescribes, with no run re-baseline.

- **design.md § The flake, in full — F-1.** The `checks.stub` sketch now describes
  the shipped mechanism: `packages.jail` is the gateway wrapper, the bundle is
  rendered in the inner launcher, so the check follows exactly one `exec` and
  resolves it through `builtins.readFile` (a store reference is not a build input);
  `needles = [devTools]` alone, with the stub's `probe` named as the contract's
  fixture. The elided `runCommand` body is marked as elided.
- **design.md § Quotient forms — F-2.** Both the prose and the linker sketch: a
  family member is two derivations, the link target is `<result>/bin/quotient-<c>`
  (the wrapper), the launcher is a different store path, and linking the launcher is
  dangling and refused as `form-invalid`. The re-approval-on-rebuild paragraph is
  unchanged.
- **design.md § Verification — F-3.** The pin-fidelity and gate-parity commands now
  use `$HOME` inside double quotes (`"path:$HOME/flakes/dev-envs#…"`,
  `"git+file:$HOME/dev/smut"`), plus one paragraph stating that a flakeref does not
  expand `~`, that an unquoted `#` is a glob in an `extendedglob` zsh, and that a
  bare argument may keep `~` because there the shell expands it.

The rest of the design document is untouched; no section was added, removed, or
reordered, and no inquiry, review pass or decision record was disturbed.

### REVs completed

- **None.** The brief carries no governance/spec item: no ADR, policy, standard,
  spec or requirement is contradicted by what shipped. DEC-099…DEC-106 are this
  slice's own decision records and read correctly as written (DEC-099 superseded by
  DEC-106 by design, not by drift).

### Withdrawn / tolerated

- **None.** Every finding was terminal before this pass (7 verified), and each
  disposition stands as recorded — remediation is recorded here, never by mutating a
  finding.

### Carried to close (not a reconcile write)

- **F-6 (`fix-now`).** Three `doctrine slice record-delta` calls from a writable
  tree — PHASE-01/02/03 each `--start ca2257cc --end c8aa633b` — so `slice
  conformance` stops reading clean-by-absence. Not a document edit, and not
  reachable from the auditing session (the registry lives in the home repo's
  read-only git dir).
- **The landing commit.** Every artefact of this pass (design.md, notes.md, the RV
  ledger) is in the working tree uncommitted; staging and committing are the
  operator's, as throughout this slice.

Reconcile pass complete — handoff to /close.
