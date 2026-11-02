# Implementation Plan SL-022: Layered dev-env consumer, proven against Smut

Prose companion to `plan.toml`. Narrative only — no queried data lives here (the
storage rule); the phase list, criteria, verification and links are authored in
the TOML. Use this for the plan's rationale and sequencing.

## Overview

One new subflake (`dev-envs/`) that consumes a project's
`packages.<system>.dev-tools` and produces a dev shell, a jailed `pi`, the
project's Quotient forms, and the pass-through bundle an outside observer can
compare pins with; plus the two host-side entry points that make it reachable
(a direnv helper and a form linker), the gate wiring that keeps it honest, and a
README section that explains the split. Nothing in any host, home or project
evaluation changes.

The design is `design.md` — the flake, the helper, the linker and the stub are
already written there as sketches, so the phases implement rather than invent.

## Sequencing & Rationale

**Phase 1 — the factory alone.** A flake plus its fixture. It ends with
`checks.stub` green and nothing consuming the flake, which is the property worth
most: a failure in phase 3 can then be attributed to the wiring or to the
project, not to the factory. The mutation check (empty the stub's `dev-tools`,
watch the check go red) is what makes the green mean something — a check that
greps a launcher for a store path passes vacuously if the grep is wrong.

**Phase 2 — the two entry points.** Neither touches the flake's outputs, and
both are testable without Nix builds: the direnv helper through stubbed `use` /
`watch_file` (the harness `envrc/agents-test` already uses), the linker through a
fake `nix` on PATH. That is deliberate. A test that really built a form would
build `pi`, the jail closure and quotient, and would take minutes — a test that
expensive gets skipped, and a skipped test is worse than a cheap one that asserts
argv.

**Phase 3 — wiring, then the proof.** The `justfile` lines, the sharpened lock
guard, the README, and only then the evidence against Smut. The proof is last
because it is the only thing that can fail for a reason outside this repo: it
reads a project's pins, runs a project's gate, and depends on a running gateway.
Doing it last means its failure is informative.

The ordering also follows the design's own review note: the two load-bearing
claims (that `quotientFormFamily`'s `packages` builds a form's PATH, and that
`jail.nix` renders the project bundle into the launcher text one of the two ways
`checks.stub` accepts) are falsified or confirmed in phase 1 by building the
launcher and reading it — before anything is built on top of them.

## Notes

**Nothing routed from the design review.** `RV-044` (design, human lane) has zero
findings, so there is no `demonstrate`/`probe`/`control` obligation to transcribe
into a criterion.

**Boundaries a phase may not cross.** No `follows` on any input; no extras file,
project key or second jail; no edit to `envrc/agents.sh`; no tracked file changed
in `~/dev/smut` or under `/srv/fleet`; no form derivation in the jail's package
list; no `path:` override in a committed lock.

**One environment caveat, per phase.** In a confined session `~/.cfg` and
`~/.cache` are read-only, so `git add -N` and commits fail and a git-resolved ref
cannot see a file the session created: phases evaluate through `path:` refs with
`XDG_CACHE_HOME` redirected, and the operator commits. Builds work.

**A single-line design drift.** `design.md` cites the root lock guard at
`justfile:64`; it is at `:65`. The claim is unchanged, so the design was not
reopened; phase 3 cites the real line.
