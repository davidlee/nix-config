# Implementation Plan SL-005: Legacy flags to feature tree: hardware, virt, app formats

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

Four phases, one commit each, in the design's commit order (design sec-1):

```
PHASE-01 hardware ─> PHASE-02 virt ─> PHASE-03 podman ─> PHASE-04 apps
 machine.nix          qemu, docker      podman off,        non-nix-packages
 + gate probe         groups, rootful   exclusive with     duplicates out
                      assertion         docker, coverage
 └── each phase gated against the previous phase's snapshot ──┘
```

Only PHASE-03 changes behaviour (DEC-022: Sleipnir loses podman). Every other
phase must prove Sleipnir's effective configuration unchanged.

## Sequencing & Rationale

- **Probe first.** The design's gate (sec-7) needs measures `just drvs` does
  not give: the unique package set, effective groups, kernel params, root
  mount options and the system-path link map. Writing them once as
  `gate-probe.sh` keeps four phases comparable and survives a context
  handover. It lives in the slice directory: it is slice evidence tooling,
  not flake code. The baseline is taken before any flake edit.
- **hardware first.** Smallest, no tree feature, no resolver change; it proves
  the probe on a phase whose only expected change is kernel-param order.
- **virt before podman.** The docker/podman exclusivity assertion cannot land
  while `podman.nix` is still unconditional, or the virt commit fails. Docker
  moves first (still sharing `bin/docker` with podman's shim; docker wins by
  position, which the link map pins), then PHASE-03 removes podman and adds
  the assertion together. Evidence that docker keeps winning in PHASE-02: a
  module appended at top level (as tree features are) lists its packages at
  position 333 of Sleipnir's systemPackages, ahead of the shim at 335
  (extendModules probe, 2026-10-15). The link-map check confirms it.
- **apps last.** Independent of the others; it adds a new area, which touches
  projection order (appended after virt, so existing order is unchanged).
- **Red first.** Each feature phase extends `testSleipnirSelectsMigrated` (or
  its podman-absent counterpart) before the records exist.
- **Docs travel with code.** Each phase edits the README rows it retires, so
  every commit is self-consistent.

## Notes

- RV-011 F-8 (route `control`) is transcribed into every phase's gate
  criterion as the link-map check.
- One-off evals (negative controls, guards) are not committed; their outputs
  are summarised in `notes.md`.
- `git add -N` every new file before evaluating (flakes see tracked files
  only); git operations are scoped to `flakes/` (the worktree is `$HOME`).
