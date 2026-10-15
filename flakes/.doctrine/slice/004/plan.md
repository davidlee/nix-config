# Implementation Plan SL-004: Darwin standalone Home Manager and unified pkgs factories

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML. Use this for the plan's rationale and sequencing.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

The design (locked) has one rule: a factory supplies host identity plus one
injected module, and the evaluator builds pkgs. The plan reaches it in steps
that each leave the `just drvs` gate either identical or changed only where
the design says it changes.

```
PHASE-01 gate + agents override + baseline     drvs: lines added only
PHASE-02 shared pieces, NixOS + Linux home     drvs: identical
PHASE-03 darwin: check red -> fix; Draupnir    drvs: Linux identical, darwin changes
PHASE-04 homeModule (gate-conditional)         drvs: identical, or revert
PHASE-05 justfile activation + README          drvs: identical
PHASE-06 cut-over on Draupnir (human)          F-1 Mac half, F-4
```

## Sequencing & Rationale

- **Gate first.** DEC-018 wants the new outputs covered before anything moves,
  so PHASE-01 only adds coverage. The `agents` override (RV-009 F-1) lands
  here too: every later Mac evaluation needs it, and adding it to Linux home
  must itself be shown drv-neutral against a snapshot taken before the edit.
- **Refactor before behaviour change.** PHASE-02 is everything that must not
  change any derivation. It leaves `mkDarwin` alone: adding `platformModule`
  there while it still passes a prebuilt `pkgs` would mix the refactor with
  the ISS-004 fix and invite an interaction between `nixpkgs.hostPlatform`
  and a supplied `pkgs`. All darwin work is in PHASE-03, against a clean
  baseline.
- **Darwin is one phase.** Removing `pkgs` from `mkDarwin`, dropping embedded
  Home Manager, the rename and the new home all change the same output, so
  splitting them would mean diffing intermediate darwin states nobody will
  run. The check is written first and observed red against today's
  `mkDarwin`, then against three more named wrong candidates (RV-009 F-3).
- **homeModule apart.** The design puts it in its phase 3 but makes it
  gate-conditional and independently revertable. Its own phase keeps a
  failed gate from entangling the darwin diff, and makes the fallback a
  clean decision point.
- **Docs and justfile last.** The per-OS flake ref and `hostname -s` only
  matter on the Mac; README must describe the final shape. The `agents`
  override is not here: it is already in PHASE-01.
- **Cut-over is the user's.** PHASE-06 is human-verified on Draupnir and is
  where RV-009 F-1 (Mac half) and F-4 are demonstrated.

## Notes

- Lint is `just gate` (treefmt check: alejandra, statix, deadnix; then
  `just test`), added by CHR-010 after the design locked.
- New files need `git add -N` before `just drvs` sees them
  (`mem.fact.flakes.git-add-n`); the worktree is `$HOME`, so stage by path.
- Another agent is burning down backlog chores in the same worktree. Commit
  SL-004 work by explicit path; re-check `git log -- <paths>` for drift on
  design-target files before each phase.
- Instrument-routed review findings and where they land: RV-009 F-1 →
  PHASE-01 EX-2/EX-3 and PHASE-06 EX-1; F-3 → PHASE-03 EN-2/EX-1; F-4 →
  PHASE-06 EX-2/EX-3.
