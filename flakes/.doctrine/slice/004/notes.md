# Notes SL-004: Darwin standalone Home Manager and unified pkgs factories

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-15 · planned (ready, before PHASE-01) · f62fda8c

### Produced
- design locked (run revision 39) after RV-009 (F-1..F-10); plan PHASE-01..06 (commit f62fda8c)
- minted: ISS-006 — agents/dev inputs locked as local paths; DEC-016 amended — stable as module argument

### Learned
- mem.fact.nix.callpackage-autoargs — pkgs attrs leak into callPackage defaulted args; module-arg checks
- mem.pattern.flakes.codex-design-review — running Codex reviews; recording its acts on the RV by proxy

### Open
- QUE-001 — platform scope for features (ADR-005 D6 weaker on darwin)
- RV-009 F-1, F-3, F-4 — instrument-routed; close after phases (PHASE-01/03/06 criteria)

## Design review (RV-009)

2026-10-15. Codex (gpt-6.1-sol) adversarial review, four rounds, findings
F-1..F-10; Claude recorded Codex's acts (its sandbox could not take the
ledger lock). User chose the `stable` module argument over `pkgs.pkgsStable`
(F-2; DEC-016 amended). Lock drift split out as ISS-006.

**Further review passes: none needed before planning.** The last pass
(round 4) concluded with no blocker or major defect, and every later edit is
bookkeeping (routes, scope/selector sync). What remains open is settled by
instruments, not by more design review:

- F-1, F-4 (`demonstrate`): Mac build with the `agents` override; cut-over
  and switch-generation recovery on Draupnir. Criteria on RV-009.
- F-3 (`control`): `checks.factories` must reject four named wrong
  candidates (today's mkDarwin, a leftover `specialArgs.pkgs`, an empty
  darwin set, a `classesOf` that ignores `meta.home`).
- `just drvs` identity for NixOS and Linux home (Codex could not reach the
  Lix daemon; only consumer-level drvPaths were checked).

`/plan` reads the instrument-routed criteria on RV-009 (`doctrine review show
RV-009 -f F-1 -f F-3 -f F-4`).

## Execution

### PHASE-01 (gate coverage and baseline)

Gate artefacts live in `~/.cache/sl-004/`, not the session scratchpad: they
are needed through PHASE-05 and must outlive the session and a reboot.

| file | what |
|---|---|
| `en2-drvs` (+ `en2-head`) | EN-2: `just drvs` before any justfile edit, at `979e83ec` |
| `baseline-drvs` | EX-4: slice baseline; PHASE-02.. diff against it |
| `baseline-darwin-home-pkgs` | EX-4: sorted names of embedded `home-manager.users.david.home.packages` (209), for PHASE-03 EX-6 |

- `agents_override` folded into `system_override` and `home_override`; `test`
  and `gate` builds carry it too (RV-009 F-1, Linux half).
- VA-1: `diff en2-drvs baseline-drvs` shows only added lines (packages,
  legacyPackages, templates). Overriding agents to the same tree moved no
  home or darwin derivation (EX-3).
- Deviation from design sec-4: flake-parts gives every system a key, so
  `legacyPackages.aarch64-darwin` (and `packages.aarch64-darwin`) exist and
  are empty. The legacyPackages pick guards `lp ? stdenv` and prints `none`.
- The justfile does not follow `just --fmt` (2-space recipe bodies, already
  so at HEAD); not part of the gate, left alone.
