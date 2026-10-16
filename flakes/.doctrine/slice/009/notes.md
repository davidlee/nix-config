# Notes SL-009: VM enablers and agents onto the tree (RFC-001 W6 + W2)

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-17 · PHASE-02 complete · f1d4ca64

### Produced
- research round (`research/research.md`, gitignored) → slice rescoped (user agreed)
- design locked (e670e193); RV-019 concluded, 3 findings fixed
- minted: DEC-037..041
- plan P1–P4 (6de5cfc3, 81bfb5cf); PHASE-01 landed (d7860ab5): § PHASE-01 below
- ISS-010 (emacs-overlay re-lock on every lock write), found in PHASE-01
- RV-020 (PHASE-01 code review): done, 6c20495e
- PHASE-02 landed (f1d4ca64): § PHASE-02 below; IMP-010 resolved in code (close at reconcile)

### Learned
- mem.fact.flakes.override-records-in-lock — lock-writing commands record overrides; git+file vs path:
- mem.fact.doctrine.design-review-route — route major findings before review-disposed
- mem.fact.flakes.fmt-relock — corrected: unpinned nested override re-resolves on every lock write (ISS-010)
- mem.pattern.flakes.drv-gate — extended: record dev checkout state per snapshot; compare old/new trees back to back
- mem.fact.nix.lazy-error-context — addErrorContext misses lazily forced option errors

### Open
- reconcile list: design.md § Code impact and docs → Records at reconcile; plus DEC-034 stub set gains oubliette; design.md "three verbs" typo
- oubliette's local HEAD drops `target` / `goad-walk`: once pushed and re-locked, flake.nix's two follows lines go (not this slice's change unless it lands first)
- user's `push-local` recipe still uncommitted in justfile (left to the user)
- VH-1 (Draupnir: drvs, probe, isolation) can run now
- PHASE-03 baseline: `~/.cache/sl009/p2/after` (retake immediately before editing, per EN-1)

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

## PHASE-01 — dev checkouts and the lock (2026-10-16)

Snapshots: `~/.cache/sl009/p1/{base,A,B,absent}` (drvs, drvs-sets, probe,
checkouts = HEAD + dirty state of each listed checkout). Agents were committing
in `~/dev/oubliette` throughout: HEAD 61701fe (base, A) → 1284c5a (B, absent)
→ 09f4df8 (coverage), dirty at every snapshot. The other four were clean at
their origin rev the whole time.

| run | vs | diff | attribution |
|---|---|---|---|
| A (justfile + script) | base | Sleipnir system: `capsule-*` only. Sleipnir home: panopticon pkg + units, satan-patcher unit, `.manpath` | home: path: → git+file drops ignored files (expected, design P1 row). system: oubliette lock pinned 1a27efc-dirty; override now reads 61701fe-dirty |
| B (declarations + re-lock) | A | Sleipnir system: `capsule-*` only; home identical | oubliette moved 61701fe → 1284c5a |
| absent (`FLAKES_DEV=/nonexistent`) | B | Sleipnir system: `capsule-*` (+`capsule-adopt`) only; home, darwin, packages, legacyPackages identical | oubliette lock = origin 61701fe (clean) vs local 1284c5a-dirty. Every clean checkout gives the same drvs from GitHub |
| coverage | base | all six `Sleipnir+…` | oubliette drift: back-to-back runs of the pre-phase tree (scratch copy, old lock) and this tree against the same checkout state are identical |

- Lock guard red on the pre-relock lock (`just test`: "flake.lock locks a
  local source"), green after. Re-lock revs = local HEAD = origin for goad,
  panopticon, satan-patcher, satan-attrd; oubliette = origin 61701fe.
- The re-lock also bumped `emacs/emacs-overlay`; pinned back to 3d05567 with
  `nix flake lock --override-input emacs/emacs-overlay github:…/3d05567…`
  (a github node, not a local one). Pre-existing: any lock write re-resolves
  it (ISS-010).
- isolation passes; negative control (home base imports
  `inputs.goad.homeManagerModules.default`) fails both targets at that line;
  reverted.
- With the override, oubliette 1284c5a+ warns "override for a non-existent
  input 'target' / 'goad-walk'": its new HEAD dropped both inputs. When that
  work is pushed and re-locked, `flake.nix`'s two follows lines go.
- justfile committed from a filtered copy: the user's `push-local` recipe
  stays unstaged.

## PHASE-02 — validate meta.nix (2026-10-17)

Snapshots: `~/.cache/sl009/p2/{base,after}` (drvs, drvs-sets, checkouts).
Checkouts unchanged between them (oubliette 9654a71 with `host/services.nix`
modified; the other four clean at their locked revs). drvs and drvs-sets
identical. `just gate` and `just coverage` green.

- **Validation is strict on purpose.** Module option values are lazy, so
  `addErrorContext` around the evalModules result alone does not name the file
  for a missing `system`: the throw happens later, when the field is forced,
  outside the context. `host-meta.nix` `deepSeq`s the config inside the
  context. Checked by eye: unknown key, wrong type and missing option all
  name the file.
- VA-1: `kind = "nixso"` in `hosts/Draupnir/meta.nix` (temporary edit,
  reverted) fails `nix eval .#homeConfigurations` with
  "- In `hosts/Draupnir/meta.nix': "nixso"", and fails
  `nixosConfigurations.Sleipnir` too (the `hosts` deepSeq).
- Tests mutation-checked: replacing the enum with `str` and bool with
  `anything` reds testMetaUnknownKindFails and testMetaHomeTypeFails.
- `checks.factories`' `classesOf` fixtures go through the validator (they
  lacked `home`, which `classesOf` now reads directly).
- justfile gains one line (`checks.host-meta` in `test`), as EX-1 requires;
  committed from a filtered copy so `push-local` stays unstaged.
- Slip: `nix fmt -- <files>` (no `--no-write-lock-file`) re-locked
  emacs-overlay (ISS-010). Lock restored from HEAD before commit; gate re-run
  green on it. drvs were unaffected: the after snapshot equals base, which was
  taken on the pristine lock.
