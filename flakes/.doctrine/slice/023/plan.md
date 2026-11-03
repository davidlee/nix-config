# Implementation Plan SL-023: Layered dev-env consumer, carried to Doctrine

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML. Use this for the plan's rationale and sequencing.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

Eight phases across three repositories and the host. The first three build
the `~/flakes` side bottom-up along DEC-108's dependency arrow (host facts →
jail library → consumer). The fourth runs Doctrine's additive changes and the
fleet move. The fifth is the fidelity gate. The sixth subtracts. The seventh
proves behaviour and retires the symlink. The eighth writes the durable spec.

```
PHASE-01 host facts ─> PHASE-02 library ─> PHASE-03 consumer ──┐
                                                               ├─> PHASE-05 diff ─> PHASE-06 subtract ─> PHASE-07 behaviour ─> PHASE-08 spec
PHASE-04 Doctrine step 1 ─> fleet ─> Doctrine step 3 ──────────┘
```

PHASE-04 depends on nothing in PHASE-01..03 and may run beside them; it is
ordered fourth only so one worker holds one repository at a time.

## Sequencing & Rationale

- **Bottom-up in `~/flakes`.** Each layer reads only the one below it, so each
  phase ends green on its own: PHASE-01's facts are inert until PHASE-02 reads
  them, and PHASE-02's library change is invisible to the consumer until
  PHASE-03 uses it.
- **The Mac lands with the host facts** (DEC-116 depends only on them).
- **The diff after all of DEC-112** (RV-046 F-2). Before step 3 the consumer
  would still carry the crane `doctrine`; after the subtraction Doctrine's
  jails are gone. PHASE-05 sits between and names the compared revision.
- **The live shell builds against the in-tree library** (DEC-120, a post-lock
  amendment carried in notes). `use_dev_envs` and `bin/dev-envs-forms`
  override `agents` as the root `justfile` does, so PHASE-02's change reaches
  Doctrine's shell without a push or re-lock; PHASE-06/EN-2 is superseded.
- **The symlink last** (RV-046 F-1). Removing `~/.local/bin/doctrine` before
  codex re-bakes breaks codex's MCP server; PHASE-07 orders re-bake, verify,
  remove.
- **The spec last** (DEC-118), so it records what PHASE-07 verified.

## Notes

- Operator acts the phases name and do not perform: switches (PHASE-01),
  pushes and commits in every repo, `quotient allow` per form (PHASE-06),
  removing the symlink (PHASE-07).
- Tests live where the repo already runs them: `hosts.nix` `checks.factories`
  for home and PATH evaluation asserts; `agents/jailed-agents-test.nix`;
  `dev-envs` checks (a new `dev-env-test.nix` for `checkDevEnv`, wired as a
  check); `envrc/dev-envs-test`.
- Every jail or form rebuild needs a fresh `quotient allow` (DEC-115): the
  machine forms after PHASE-02's switch, Doctrine's and Smut's forms in
  PHASE-06.
- Checked at planning (2026-11-03): no `~/dev` project sets rustflags in
  `.cargo/config*`, so the host-wide `CARGO_BUILD_RUSTFLAGS` (DEC-114)
  overrides nothing; `/srv/fleet` pins `github:davidlee/doctrine/edge`, so
  DEC-112 step 1 must be pushed before step 2; `/srv/fleet` and Doctrine each
  carry an uncommitted change of the user's that phase commits must not sweep in.
- Execution-time checks carried from the design land as exit criteria:
  quotient's form check on the `$HOME` PATH entry and the mold flag (PHASE-02
  EX-5, via `checks.quotient-forms`), sccache in forms (PHASE-07 EX-2), nested
  bwrap (PHASE-07 EX-1), the stale follows (PHASE-06 EX-5).
