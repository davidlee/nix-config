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

## Audit (RV-008, 2026-10-15)

- Independent pass; RV-007 evidence. Code review by a fresh agent, malformed
  inputs probed by execution. 8 findings, 7 fix-now (0237ff67), 1 to brief.
- `badRecords` became `badShapes`: area shape, string name, `requires` list
  of strings, all checked alone before anything that reads them.
- testProvenance checks the content of the line `_file` names (not its
  number): robust to edits, red on a wrong line (mutation-checked) or an
  absolute path.
- User decision: keep area `{ name; value; }` pairs.
- Skill/CLI drift: /audit prescribes a `verified` disposition the CLI lacks;
  `aligned` + brief used.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-15 · audit (RV-008 done; handoff to reconcile) · 0237ff67

### Produced

DEC-015 (accepted) · RV-006 (design pass, waived) · RV-007 (audit pass 1) ·
RV-008 (audit pass 2, 8 findings verified; its brief supersedes RV-007's) ·
IMP-013 · commits df85b6b5, bc08438b, c693a33b, fbb27f68, ce91ecc8, 0237ff67.

### Learned

No new memory: the tryEval limit is already held
(mem_01a13e129e64705d91fb05f77f97ba7e). Plan lessons in § Audit (RV-007).

### Open

- RV-008 § Reconciliation Brief: not yet executed.
- ISS-005, CHR-010 (tooling; tolerated, RV-007 F-1, F-2).
- IMP-013 (single tree walk).
