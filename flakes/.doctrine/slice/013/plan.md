# Implementation Plan SL-013: Jailed pi and emacs devshell jails via the LLM gateway

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML. Use this for the plan's rationale and sequencing.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

Six phases follow the design's rollout (sec-5). Three land code in this repo;
three are operations on the host, the other repos and the shared pi home,
driven mostly by the user.

```
PHASE-01 data move (agents/gateway.nix)   ─┐ code, ~/flakes,
PHASE-02 pi gateway mode (bind, tests)     ├ off by default:
PHASE-03 template + README; push          ─┘ just drvs unchanged through 02
PHASE-04 rotate · clean pi home · issue pi key     user: 1Password, sudo
PHASE-05 cut over: switches, emacs, doctrine, settings.json
PHASE-06 live checks (VH)
```

## Sequencing & Rationale

**Code before operations.** Gateway mode stays off unless a consumer passes
`gateway`, so PHASE-01..03 change nothing any host or devshell runs (slice
R1: thirteen direnv devshells build live `agents`). `just drvs` is the check:
PHASE-01 is a pure move and PHASE-02 adds a mechanism no host selects, so both
must leave every drvPath unchanged. A changed drvPath in either phase is
a defect, not noise.

**PHASE-01 before PHASE-02.** The pi bind reads the served models from
`agents/gateway.nix`, so that file and its root consumers move first, and the
move is proven neutral on its own before anything new is added.

**Push at PHASE-03's end.** The Emacs and doctrine flakes re-lock `agents`
from the remote, so the push has to come before PHASE-05. It is outward-facing:
the user gives the go-ahead.

**Rotate before cutover (PHASE-04).** POL-001 r6, "on a leak, rotate first",
and the inq-9 order: the stored `deepseek` key has been readable by every
specDev jail. Removing the stored copies in the same step leaves no live copy
of the old key. Unmigrated jails keep working: `op run` feeds the new key
to the env-keyed `deepseek` provider.

**settings.json moves at the cutover (PHASE-05), not before.** Changed earlier
it would only redirect unmigrated jails onto pi's silent fallback (design
sec-5).

**No root switch, if the gate holds.** With every host derivation unchanged
through PHASE-02, the root's eca and gateway records need no switch at the
cutover; PHASE-05 switches only what `just drvs` says changed.

**Live checks last (PHASE-06).** They need the switched host, the key and the
migrated jails together.

## Notes

- **Execution mode.** PHASE-01..03 suit capsule workers (code and tests in
  `~/flakes`). PHASE-04..06 need the user for 1Password, sudo, switches, pushes
  and commits in other repos; a worker prepares and checks, and the user acts.
- **Test fixture gap.** `jailed-agents-test.nix`'s `fakeAgents` has no `eca`
  (or `zerostack`, `dirge`); the no-bind-without-pi case needs a fake `eca`.
- **Tracked files.** `agents/gateway.nix` must be `git add`ed before any flake
  evaluation sees it. direnv's `path:` override sees it untracked, so a
  direnv devshell can pass while `just test` fails (slice R2).
- **Research drift.** `doctrine slice research 13` flags drift caused only by
  the design work (scope edits, design.md added); the research claims that
  turned out wrong were corrected in the records (inq-9).
- **Out-of-repo work.** Emacs and doctrine edits are commits in their own repos;
  shared pi home edits are commits in the home repo by explicit path. None is
  covered by this repo's `just test` (slice R3), so PHASE-05 verifies them by
  building.
