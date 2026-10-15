# Notes SL-001: Snooze pilot: first feature under the typed outer resolver

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Origin

Preflight session 2026-10-15 synthesised `brief.features.local.md` (web-agent
architecture brief) and MULTIHOST.md into direction v2, reviewed adversarially
by a second agent; dispositions in `review.features.local.md` (local,
untracked — reference only, not authority; ADRs supersede it).

Scope selectors were written as `flakes/...` (git root is `~`, worktree of
`~/.cfg`); unverified whether doctrine resolves them against `~` or
`~/flakes`. Check at first conformance run.
**Answered 2026-10-15** by `doctrine slice selector doctor 1`: selectors
resolve against `~/flakes`, so the `flakes/` prefix matched nothing. All
selectors were re-added root-relative. The four flakes memories still carry
`scope.paths: [flakes/]`, which needs fixing the same way (open).

## Design triage (2026-10-15)

Research: `research/research.md` (runtime, gitignored). The design run's
inquiry graph `inq-1`–`inq-10` holds the questions below.

- **User decisions:**
  - Darwin takes no snooze. An outer profile selects it, and the Mac imports
    no profile. `mkDarwin` projects the `darwin` class only.
  - The namespace is `feature.<area>.<name>.enable`.
  - Snooze goes in area `session`.
  - openrgb (`hardware`, off on Sleipnir) is also migrated, to give test 7 a
    real off feature.
- **Agent proposals (in the design):**
  - Index files are lists of `{name; value}`, with a root `features/default.nix`.
  - Profiles live in `features/profiles/`.
  - A prerequisite is a `requires` list on the descriptor. An unselected
    prerequisite is an error however it got there.
  - The resolver is a pure function of `{tree; classes; modules}`. It
    resolves once per host and throws on a failed assertion.
  - `specialArgs.features` exposes the legacy flags only.
  - Coverage targets go in `flake.coverage`, run by `just coverage`.
- **Risks:**
  - Ordering: the snooze halves move to factory depth. Snooze has no shared
    lists, so this is expected to be identical; the gate decides.
  - The snooze script and its test must move together.
  - New files must be `git add -N`'d.
- **Assumption:** openrgb's area-index position (`hardware` before `session`)
  matches its current position in the gated NixOS list (`config.nix:78`
  before `:82`).
- **Governing:** ADR-001 to ADR-005 (proposed), HYP-001, and research
  Thread 1. Amendment candidates are R1–R6 in the research.

## PHASE-01 evidence (2026-10-15)

- Red: `just test` against the old `features.nix` failed with
  `cannot coerce a set to a string` (old `lib: hostname:` arity). Green
  after the rewrite.
- Mutations, each reverted: dropping the uniqueness check, the assertion
  enforcement, or the `selected` filter in projection each turned the
  suite red.
- Identity gate: `just drvs` and `just drvs-sets` identical to the EN-2
  baseline for all four configurations (also after the `configure`
  refactor). Override inputs as at baseline: oubliette `1a27efc6` (dirty,
  one doctrine toml), agents/emacs clean at `bf2eb570`.
- RV-001 F-3 control: with `assertions = [{assertion = false; message =
  "control";}]` in `hosts/Sleipnir/features.nix`, evaluating
  `homeConfigurations."david@Sleipnir".activationPackage.drvPath` alone
  failed with `feature selection failed:` / `- control`. Line reverted.
- `perSystem.nix` takes `lib` from flake-parts' module args; the resolver
  tests pass under it.

## PHASE-02 evidence (2026-10-15)

- Red: T1/T2 (`testProfileSelectsSnooze`, `testHostOverrideWins`) failed
  as an eval error (`features/profiles/workstation.nix` missing) before the
  tree and profile existed. Green after.
- Identity gate: `just drvs` and `just drvs-sets` identical to the fresh
  pre-phase snapshot and to the EN-2 baseline, all four configurations. The
  merge-order risk (snooze halves moved to factory depth) did not
  materialise: no ordering-only diff to explain.
- VA-2: no reader of `features.snooze` / `features.hardware.openrgb` in
  `hosts/` or `modules/`; `features.hardware.microcode` still found.
- Moves done with `git mv`, so history follows; new files `git add -N`'d.

## PHASE-03 evidence (2026-10-15)

- Red: `just coverage` failed (`does not provide attribute … coverage`)
  before the output existed. Green: one line,
  `coverage.Sleipnir+openrgb /nix/store/sfs4can8…-nixos-system-Sleipnir…drv`,
  differing from Sleipnir's toplevel.
- The drvPath difference alone is weak evidence (coverage does not pin the
  agents registry), so openrgb was checked directly:
  `services.hardware.openrgb.enable` is true in the coverage target, false
  in `nixosConfigurations.Sleipnir`.
- `just drvs` still identical to the EN-2 baseline; switch recipes untouched.
- README Feature flags restructured (legacy flags / feature tree / coverage),
  darwin claim corrected, snooze paths current; MULTIHOST.md S7 annotated.

## Code review RV-002 (2026-10-15)

External raiser Codex (gpt-6-sol); 7 findings, all fix-now by user assent
("agreed"). Repairs add to design sec-3's structural checks, for reconcile
to fold into design and ADR-002 (DEC-009 path):
- unknown descriptor keys fail resolution (F-1): a misspelt class key
  otherwise drops that half silently;
- `.` in an area or feature name fails resolution (F-2): paths are
  dot-joined;
- the duplicate-name error names the duplicates (F-5).
README now says structural errors in the tree fail every host (F-3).

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-15 · started, PHASE-01..03 completed, RV-002 done, pre-audit · 01e1a71e (harvest commit follows)

### Produced
- ADR-001..005 — composition direction (8fb3b0b3)
- SL-001 scope (f870a4cb); DEC-001..009; design locked (be2b2bb4); plan (436b8ce3, 573d5720)
- research round — `research/research.md` (runtime)
- design run: 10 inquiries, design.md sec-1..8; self-review RV-001
- PHASE-01 84d77e11 · PHASE-02 da8e70d8 · PHASE-03 d19a1d45 · RV-002 repairs b4f42cf2
- RV-002 — code review (Codex raiser), 7 findings verified, synthesis 01e1a71e
- minted: DEC-001..009, IMP-012, CHR-009, ISS-005
- earlier: ISS-001..004, IMP-001..011, CHR-001..008, IDE-001

### Learned
- mem.fact.flakes.selector-root
- mem.fact.doctrine.reservation-fallback
- mem.fact.nix.merge-order
- mem.pattern.flakes.drv-gate
- mem.fact.flakes.git-add-n
- mem.fact.flakes.fmt-relock
- mem.fact.nix.tryeval-scope (new)
- EVD-001 — coupling survey
- CPT-001 — desktop session model

### Open
- HYP-001 — record SL-001 result as evidence at close (design sec-8)
- DEC-009 — ADR amendments by revision at reconcile; plus RV-002 additions to sec-3 (notes § Code review RV-002)
- ISS-005 — delta paths vs doctrine root; verify-vt/conformance unattributable for SL-001
- IMP-012 — darwin standalone Home Manager
- CHR-009 — memory scope paths
- QUE-001 — platform scope declaration
- QUE-002 — CLI tiers (deferred)
- QUE-003 — launcher source (out of scope)
- QUE-004 — Mac VM shape (out of scope)

## Design review (2026-10-15)

Self-review pass on RV-001 (ledger: `doctrine show RV-001`). If a further
adversarial pass is run (e.g. astra), it should probe:
- whether a profile layer plus `requires` is enough for the next migrations,
  without auto-selection (HYP-001);
- the merge-order argument for moving modules up the import tree, for
  features that do touch shared lists;
- whether `flake.coverage` and `checks.features` stay off every switch path;
- the darwin asymmetry (DEC-001, IMP-012).
