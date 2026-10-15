# Review RV-014 — reconciliation of SL-006

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

Conformance audit of SL-006 (games, ai, audio, services, apps, desktop and
fonts to the feature tree; legacy flag machinery retired). Surface reviewed:
the primary tree, commits 605b5208..d63c6ef5 (driven by /capsule-driver, not
/dispatch — no candidate branch).

Lines of attack:
- Path conformance (`slice conformance`), read past the ISS-005 `flakes/`
  prefix misattribution.
- Every plan EX-/VT-/VA- criterion against code and gate evidence
  (`~/.cache/multihost-gate/sl006/{baseline,phase-01..05}/`).
- Design invariants: verbatim moves, area order, host vs profile selection,
  `requires`, own-file and asset rules, RV-013 fixes honoured (F-1 speech
  overlay, F-10 header).
- Gate rule: drv and probe changes only where nix-diff proves order-only;
  any accepted deviation from the "identical" wording.
- Stale references to deleted modules anywhere tracked under `flakes/`.
- Reconcile obligations the design schedules (ADR-001, ADR-005, RFC-001,
  IMP-003, IMP-004, IMP-006).

Evidence run at audit: `just gate` rc 0; `doctrine check gate` rc 0;
`just coverage` six targets evaluate; close grep (`git grep`, tracked,
excluding `.doctrine/`) empty.

## Synthesis

SL-006 delivered what its locked design asked: games, ai, audio, services,
apps and desktop (with fonts) are features under `features/`, every body moved
verbatim, the speech overlay repaired exactly as RV-013 F-1 agreed, and the
legacy flag machinery (`modules/features.nix`, the `features` specialArg,
import-gating) is gone. All 5 phases met their criteria; four criteria were
met differently, each for a reason recorded in notes.md:

- PHASE-01 EX-7: home lines moved only through emacs-overlay drift, proven
  by pinning the overlay.
- PHASE-03 EX-6 / VA-1, PHASE-04 EX-4 / VA-1: `.manpath` moved, accepted as
  nix-diff-proven order-only (F-1).
- PHASE-05 EX-6: close grep run as `git grep` over tracked files (F-6).

Evidence re-run at audit: `just gate` rc 0, `doctrine check gate` rc 0,
`just coverage` (six targets evaluate, including the new `Sleipnir+speech`
and `Sleipnir+sunshine`), close grep empty. Path conformance is clean once
read past ISS-005's `flakes/` prefix: every touched path falls under a
design-target selector except DICTATE.md, `sleipnir-doctor.nix` (comment
only) and the IMP-004 body — each a pointer or note the design or plan
required (lead 9 of the evidence sweep).

No blockers. Fixed at audit: SATAN.md stale path (F-3), IMP-004 body
(F-5), README example comment (F-7). Captured as owned work: CHR-013
(dictate docstring, F-4), IMP-019 (gate tooling, F-8).

Standing risks:
- The gate's order-only acceptance rests on nix-diff reading, not on
  comparing built content; IMP-019 would make the probe say so mechanically.
- The emacs-overlay is unpinned under `home_override`; until IMP-019, every
  home comparison needs a manual pin.

Tradeoffs accepted: the README keeps the `### Feature flags` title because
`hosts.nix:13` cites it; the resolver error now says "is also an outer
option" (DEC-025: keep the check, reworded). Both are open to the human.

Process note: lifecycle status was never advanced during the capsule run;
moved ready → started → audit at audit. Capsule-tier routing friction is in
observations 01a13ffa and 01a1419f (a named orchestrator becomes a teammate
whose children cannot hand back to it).

## Reconciliation Brief

### Per-slice (direct edit)
- design.md § Gate and probe (F-1): accept a changed built artefact when
  nix-diff proves the change order-only; name `.manpath` (man-cache over
  man-paths) as the case met in PHASE-03 and PHASE-04.
- design.md § Phases and verification (F-6): test name
  `testSleipnirLeavesOff` → `testOffFeatures` (non-vacuous; absorbs SL-005's
  podman tests).
- design.md § Retiring the machinery / close grep (F-6): `grep -r` →
  `git grep` over tracked files under `flakes/`, excluding `.doctrine/`.
- design.md § Code impact and docs (F-6): the IMP-004 note was written in
  PHASE-04 (plan EX-5), and PHASE-04 removed the README flag table, gating and
  Overrides examples ahead of PHASE-05.

### Governance/spec (REV)
- ADR-001 D2 (F-2): "While the legacy flags remain…" and the closing
  `specialArgs.features` sentence become history — REV modify.
- ADR-005 D1 (F-2): drop the "Transitional" clause — REV modify.

### Backlog / RFC notes (direct edit, per design § At reconcile)
- RFC-001 W3 row (F-2): records SL-006; W3 done.
- IMP-003 (F-2): gamemode and caddy done; jackaudio remains.
- IMP-006 (F-2): W3 complete.
- IMP-004: fold-in note already written in PHASE-04; prune remains (F-5).

## Reconciliation Outcome

User agreed every item at reconcile (2026-10-16).

### Direct edits applied
- design.md § Gate and probe: nix-diff-proven order-only change to a built
  artefact is accepted; `.manpath` named (F-1).
- design.md § Phases and verification: `testSleipnirLeavesOff` →
  `testOffFeatures` (F-6).
- design.md close grep: `git grep` over tracked files under `flakes/` (F-6).
- design.md § Code impact and docs: IMP-004 note and README flag removal
  landed in PHASE-04 (F-6).
- RFC-001 W3 row: SL-006 recorded, W3 done (F-2).
- IMP-003: gamemode and caddy done, jackaudio remains (F-2).
- IMP-006: W3 complete (F-2).
- README `### Feature flags` → `### Features`; `hosts.nix:13` citation
  follows (user decision at reconcile). `#### Feature tree` kept: ten
  `features/*.nix` headers cite it.

### REVs completed
- REV-005 (`reconcile-sl-006`): done — ADR-001 D2 and its specialArgs
  paragraph, ADR-005 D1's transitional clause amended to the post-flag state
  (F-2). Both rows landed by hand; rationale and before/after in
  revision-005.md.

### Decided, no write
- Resolver error "is also an outer option": kept (user, per DEC-025).

`just gate` rc 0 after the edits. Reconcile pass complete — handoff to /close.
