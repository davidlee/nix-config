# Notes SL-009: VM enablers and agents onto the tree (RFC-001 W6 + W2)

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-16 · design locked · e670e193

### Produced
- research round (`research/research.md`, gitignored) → slice rescoped (user agreed)
- design locked, design.md rev 28 (e670e193); RV-019 pass 1 (GPT) concluded, 3 findings fixed
- minted: DEC-037 dev checkouts; DEC-038 remote declarations + lock; DEC-039 meta schema; DEC-040 overlay scope; DEC-041 agents area
- prerequisite done by user: `just push-local` (all five ~/dev repos pushed); `push-local` recipe in justfile uncommitted (user's)

### Learned
- mem.fact.flakes.override-records-in-lock — lock-writing commands record overrides; git+file vs path:
- mem.fact.doctrine.design-review-route — route major findings before review-disposed

### Open
- (none minted) reconcile list: design.md § Code impact and docs → Records at reconcile
- ~/dev/oubliette has a dirty tracked file: P1 equality proof attributes it (RV-019 F-1)

## Design triage (2026-10-16, design run exploring)

Source: `research/research.md` (X-1..X-7, deltas 1–8). Rescope agreed by user.

- **Shaping decisions (proposed, to lock in design):**
  - Dev checkouts are a property of the machine running `just`, not of the
    Nix host config → one justfile table guarded by existence; IDE-002 not
    adopted.
  - Every input declared by remote URL; lock never written with overrides.
  - Agents overlay scoped to its one consumer (`legacyPackages`); no
    selection-driven overlay, no resolver change (DEC-025 untouched).
  - `agents` area: registry (nixos), eca (homeManager, linux), chatgpt
    (homeManager; package available on aarch64-darwin, so no `platforms`).
- **Constraining governance:** ADR-001 (closing para, D7), ADR-002 D1/D4/D5,
  ADR-004 D2–D6, ADR-005 D1/D6, DEC-006, DEC-016 (amend), DEC-018, DEC-024,
  DEC-030, DEC-031, DEC-034, ISS-006 direction, POL-001.
- **Risks:** callPackage auto-args on overlay removal; home `.manpath` hash
  moves on reorder (masked-diff proof); `--override-input` given twice for one
  input (isolation's stub vs a dev override) — precedence unverified, avoid by
  construction; push of five `~/dev` repos (all ahead of origin) is an
  outward-facing prerequisite for phase 1.
- **Assumptions:** git+file overrides of a clean checkout at the pushed rev
  give the same source as `github:` at that rev (tracked files only) → drvs
  identical with and without the override.
- **Answered:** OQ-5 (no private repos), OQ-6 (overrides are recorded by
  lock-writing commands).

## Design review passes

- RV-019 pass 1 (2026-10-16): adversarial review by GPT (gpt-6-sol, read-only
  Codex task). Three findings (F-1 major, F-2/F-3 minor), all fixed in
  design.md rev 28 and verified. It confirmed by probe: the jq lock guard
  flags exactly the six local nodes and skips root/follows; evalModules
  errors are catchable and name `_file`; feature halves receive `inputs`.
  It could not run nix builds (no daemon socket).
- A further pass would probe only what evaluation can show: whether removing
  the overlay changes any drv (P3), and whether git+file changes panopticon's
  or satan-*'s consumers (P1). Both are settled by each phase's drv gate, not
  by more review, so no further pass is planned.
