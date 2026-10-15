# Review RV-003 — reconciliation of SL-001

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

<!-- Pre-reading + lines of attack: what this review is probing, the invariants
     it must hold the subject to, and where the bodies are likely buried. Seeded
     at `review new`; the reviewer fills it before raising findings. -->

Mode: conformance (self-audit; raiser `auditor`, responder `author`).
Surface: main worktree at `5ba01615` (not dispatched). SL-001 commits
84d77e11, 20a0bfa3, da8e70d8, d19a1d45, b4f42cf2 (`git diff
bf2eb570..5ba01615 -- flakes/`).

Invariants held (design sec-3/4/6, plan EX/VT/VA):
- resolver is a pure function of `{tree, classes, modules}`; never forces or
  applies an unselected class value; every failure throws; `flags` hides
  the selection; projection in index order;
- one shared selection per host; coverage off every switch path and
  outside `just drvs`;
- every configuration's drvs identical to the EN-2 baseline;
- slice tests 1–9 each have evidence (design sec-6 mapping).

Lines of attack:
- path conformance: `slice conformance` is unusable (ISS-005, git root
  `~` vs doctrine root `~/flakes`), so map touched paths onto selectors by
  hand;
- VT attribution: `verify-vt` reports UNATTRIBUTABLE (same cause); check
  keywords against code by agent;
- design drift: RV-002 repairs (F-1/F-2/F-5 structural checks, F-6 shared
  `nixos_pick`, F-4 paired twins) vs design sec-3/4/6; known slip in sec-6
  runner path;
- governance: DEC-009 ADR amendments still pending; HYP-001 outcome;
- gates re-run now: `just test`, lint, `just drvs`/`drvs-sets` vs
  baseline, `just coverage`.


## Synthesis

SL-001 delivers what its design promised. The resolver contract, the factory
wiring with one shared selection per host, the two migrated features, the
`workstation` profile, the coverage target and the docs are all in place.
Every slice test has evidence:

| slice test | evidence (this pass unless noted) |
|---|---|
| 1, 2 | testProfileSelectsSnooze, testHostOverrideWins, testMacSelectsNothing |
| 3 | testPrerequisiteOffFails (+ twin), testUnknownPrerequisiteFails; home-only control observed in PHASE-01 (RV-001 F-3) |
| 4 | testUnselectedNotForced |
| 5, 6 | `just drvs` / `drvs-sets` identical to EN-2 baseline, all four configurations |
| 7 | `just coverage`: one drvPath, ≠ Sleipnir toplevel |
| 8 | testNowhereToLandFails (+ twin) |
| 9 | testListOrder |

No code defect was found. All six findings are records that lag the code
(F-1..F-4) or tooling (F-5, F-6):

- The RV-002 repairs (closed descriptor key set, dotted-name refusal, named
  duplicates, shared `nixos_pick`, paired-twin tests) improved the code past
  the design. The user assented to them. The design and ADR-002 must catch up
  at reconcile.
- DEC-009's ADR amendments were always meant for reconcile; they are
  listed below with the RV-002 additions.
- ISS-005 makes `slice conformance` and `verify-vt` unusable for this repo.
  The hand mapping is complete, but the mechanical check stays unavailable
  until ISS-005 is fixed.

**Standing risks.**
- Merge order: a feature that contributes to shared lists, moved to factory
  depth, can reorder them (design sec-5). Snooze had none, so the gate
  stayed identical. The next migrations must not assume the same.
- Darwin's embedded Home Manager gets no projection (DEC-001). This blocks
  migrating any shared home module until IMP-012 lands.
- Feature completeness (each feature selected by some host or coverage
  target) is checked only by eye (design sec-8).

**HYP-001.** No SL-001 test needed graph traversal or automatic selection,
so HYP-001 is not refuted. Per design sec-8, `/close` records this as
supporting evidence and HYP-001 stays `proposed`. The pilot had no
prerequisites or integrations, so it cannot confirm HYP-001.

**Process note.** The audit skill names a `verified` disposition for items
delegated to reconcile, but the CLI accepts only aligned / fix-now /
design-wrong / follow-up / tolerated. F-1..F-4 are disposed `aligned` (the
code is correct) with responses citing this brief. This is drift in the
doctrine framework, not in the project.

## Reconciliation Brief

### Per-slice (direct edit)
- F-1 · design.md sec-3: steps 1 and 4, the flowchart's structural node,
  the sketch and the invariants. Add the closed descriptor key set
  (`nixos homeManager darwin requires`), the refusal of `.` in area or
  feature names, and named duplicates. All structural errors throw one
  `feature tree is malformed:` bullet list before any selection check.
  Replace `allUnique` in the sketch with the `duplicates` form.
- F-1 · design.md sec-2 descriptor table: state that any other key fails
  resolution on every host.
- F-2 · design.md sec-6: runner imports `./features-test.nix`. Add to the
  T-table testPrerequisiteOnPasses, testFalseAssertionFails,
  testUnknownDescriptorKeyFails and testDottedNameFails, and the convention
  that each failing fixture is paired with a passing twin (tryEval loses
  the message).
- F-3 · design.md sec-4: the `coverage` recipe uses the shared `nixos_pick`
  (agents registry pinned), the same pick as `drvs`.
- No selector change: conformance is red only because of ISS-005 (F-5).

### Governance/spec (REV)
- F-4 · DEC-009 amendments (design sec-8 table), unchanged:
  - ADR-001 D4: an unselected prerequisite of a selected feature is an
    error however it came to be off; the resolver never selects anything.
  - ADR-001 D2, ADR-002 D2: `feature.<area>.<name>.enable` beside the legacy
    flags; `specialArgs.features` carries the legacy flags only.
  - ADR-002 D1: optional descriptor key `requires`.
  - ADR-002 D2: index files are `{ name; value; }` lists rooted at
    `features/default.nix`, two levels deep.
  - ADR-002 D1, ADR-003: darwin's embedded Home Manager gets no projection
    until a feature needs it.
  - ADR-005 D1: transitional; binds only features in the tree.
  - ADR-005 Verification: targets live in `flake.coverage`, run by
    `just coverage`.
- F-4 · added by RV-002:
  - ADR-002 D1: the descriptor key set is closed; area and feature names
    may not contain `.`.
  - ADR-002 D4: structural checks (names, key names, `requires` paths) read
    every descriptor, selected or not, and fail every host. Reading key
    names forces no class value, so the exclusion boundary holds.
- After the REV: put ADR-001..005 to the user for acceptance (DEC-009).

### Added in pass 2
- F-7 · flag at a feature path: fixed in code (b454d50c); mirrored in
  design sec-3/sec-6, README § Feature tree, and ADR-001 D2 / ADR-002 D4
  through the REV.

## Reconciliation Outcome

User assent 2026-10-15: +1 to the brief, with the external reviewer's two
changes (enforce the flag/feature collision; ADR-003 wording), and
"happy to accept the ADRs once we're done … with doctrine adr status".

### Direct edits applied
- design.md sec-2: closed descriptor key set (F-1).
- design.md sec-3: flowchart, step 1, sketch, invariants. Five structural
  checks and one `feature tree is malformed:` error; sketch matches
  features.nix (F-1, F-7).
- design.md sec-4: `coverage` uses the shared `nixos_pick` (F-3).
- design.md sec-6: runner `./features-test.nix`; T3p, T10k, T10d, T10f
  and T12 added; the pass/fail pairing convention stated (F-2, F-7).
- design.md sec-7: tests T1–T12.
- README.md § Feature tree: flag collision is a structural error (F-7).

### REVs completed
- REV-001 (`reconcile-sl-001`): done. ADR-001 D2/D4/trailing, ADR-002
  D1/D2/D4, ADR-003 Decision, ADR-005 D1/Verification amended (F-4, F-7).
  Rationale in revision-001.md.

### Governance acts
- ADR-001..005 → accepted by `doctrine adr status`, on the user's
  direction (DEC-009's acceptance step, no REV by user choice).

### Tolerated
- F-5: ISS-005 tooling; manual conformance mapping in the finding.
- F-6: stale immutable VT keyword `allUnique`; intent covered by
  testDuplicateNamesFail.

Reconcile pass complete — handoff to /close.
