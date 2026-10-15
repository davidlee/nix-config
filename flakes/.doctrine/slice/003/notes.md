# Notes SL-003: Feature shape: area files and self-named features

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Design review passes (2026-10-15)

The shape (DEC-015) had one external adversarial pass before the slice
opened: an online agent's critique, adjudicated point by point in session
(accepted: unit framing, threshold as guidance, exclusion contract wording,
move ≠ literal cut-paste, dual provenance, softened asset rule; rejected:
inline/spilled equivalence test, which would only test `import`).

No further adversarial pass proposed. Residual risk is mechanical and is
caught by gates, not review: `_file` reaching a derivation (the `just drvs`
gate), and the resolver's short-circuit for unnamed features (its own test).
A further pass would probe only those two, and the gates already do.

## PHASE-01 (2026-10-15)

- Gates: `just drvs` identical to the pre-edit capture (Sleipnir, home,
  darwin); `just test` exit 0; `just coverage` evaluates (warnings are
  pre-existing upstream: mpd rename, `or` identifier); `nix fmt` 0 changed.
- Real provenance strings: `features/session.nix:20 (session.snooze#nixos)`,
  `features/virt/capsule.nix:35 (virt.capsule#nixos)`. Lix 2.95: stripping
  `toString ./.` from `unsafeGetAttrPos` paths works, from both a `path:` flake
  and the checks build.
- Unnamed feature: a missing `name` aborts uncatchably (`tryEval` misses a
  missing-attribute error), so the `unnamed` check runs alone, before every
  other structural check and the option tree.
- **VT**: `verify-vt 3` reports VT-1..4 UNATTRIBUTABLE (ISS-005, as SL-002).
  Judged by agent: every keyword present, files in the PHASE-01 commit.
- History: snooze's `home.nix`/`nixos.nix` are not followed into
  `session.nix` by `git log --follow` (content merged into a new file). The
  scripts kept history via `git mv`. Accepted: old halves are reachable at
  863f8748.

## Audit (RV-007, 2026-10-15)

- Red-first evidence (F-7): after the test reshape and before the resolver
  change, evaluation aborted at `features.nix:36` (`descriptor = f.value`).
- Fix in audit (F-4, fbb27f68): a non-record feature (a bare path) gets its own
  message with an `(import …)` hint. Pure Nix cannot assert a throw's message
  (`tryEval` drops it), so the test asserts rejection and the text was checked
  by hand.
- Plan lessons (F-3, F-7): test a VA grep against the expected end state;
  make red-first an exit criterion.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: <yyyy-mm-dd> · <PHASE-NN | stage> · <head-commit>

### Produced

### Learned

### Open
