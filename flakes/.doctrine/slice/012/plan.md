# Implementation Plan SL-012: Transient breakage workarounds with removal checks

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML. Use this for the plan's rationale and sequencing.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

Five phases, in the order of design sec-6. Each ends green on `just test`,
`just coverage` and `just drvs`. Every phase but PHASE-04 is drv-neutral.

```
PHASE-01 rename ──> PHASE-02 probes + check ──> PHASE-03 lastGood ──> PHASE-04 will-build, nom ──> PHASE-05 README
 (neutral)            (neutral)                   (neutral)             (homes + nom)                (neutral)
```

## Sequencing & Rationale

- **Rename first.** The probes' `sites` name `features/platform-skips.nix`,
  so the file must already carry that name. The rename is mechanical and
  drv-neutral, a clean baseline for everything after it.
- **Probes before lastGood.** Every lastGood use needs a probe (sec-3), and
  lastGood's flake check joins `checks.<system>.workarounds`, which PHASE-02
  creates.
- **will-build and nom last among code.** They are the only phase that changes
  a drv (both homes gain `nix-output-monitor`). Kept apart, that diff is easy
  to read against the drv gate.
- **README last.** It describes the finished mechanism once, not in pieces.

Departures from the design's file list and phase table (plan-level, within
scope; each recorded for /reconcile):

- **README path references and the availableon-limits memory move to
  PHASE-01.** Then no commit leaves a stale path. PHASE-05 keeps only the new
  § Workarounds.
- **DEC-036 and DEC-053 text is left to /reconcile.** These are accepted
  decisions, which the reconcile surface writes. sec-6 placed them in P5.
- **Probe tests live in `workarounds/probes-test.nix`.** The check in
  `probes.nix` calls it with the resolver, the same way `host-meta-test.nix`
  serves `checks.host-meta`. sec-7 placed the tests inside `probes.nix`.

## Notes

- RV-025 has no finding routed `demonstrate`, `probe` or `control`. All eight
  were fixed in prose. The criteria cite the ones that shape a test.
- Premises re-checked against the tree at plan time: every path in sec-7
  exists, or is new as the design says. home-manager forwards `--log-format`.
  `meta.unfree` exists (`yed` true, `hello` false).
- `update-home` names `antigravity-nix`, which is not an input. Nix only
  warns, so it is out of scope here.
