# Review RV-008 — reconciliation of SL-003

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

Mode: conformance. An independent second pass, at the user's request; RV-007
(pass 1, by the implementer) is evidence, not the audit. Surface: main tree at
966919fb; code commits bc08438b, c693a33b, fbb27f68.

Invariants (design sec-1..7, DEC-015, ADR-002, ADR-005):

1. Exclusion contract: resolution and projection never force an unselected
   class value or its packages; only key names, `name`, `requires` and
   positions are read.
2. Structural errors are catchable throws with clear messages; no check that
   aborts on bad input runs before the check that rules that input out.
3. Provenance: `_file` is flake-relative `file:line (<area>.<name>#<class>)`
   in real flake evaluation, for inline and spilled features.
4. Pure move: `just drvs` identical to `sl003-before`; projection order kept.
5. Docs (README, header comments) tell the truth about the code.
6. RV-007 dispositions (tolerated F-1/F-3/F-7, aligned F-5/F-6/F-8/F-9)
   still hold.

Code review: delegated to a fresh agent with no implementation context;
malformed inputs probed by execution. Its findings are raised here.

## Synthesis

The implementation matches the design and the shape DEC-015 fixes. Gates,
re-run by the auditor before and after the fixes: `just drvs` identical to
`sl003-before` (4 configs); `just test` exit 0; `just coverage` evaluates;
treefmt, statix, deadnix clean. Real provenance, by execution on git+file and
`path:` refs: `features/session.nix:20 (session.snooze#nixos)`,
`features/virt/capsule.nix:35 (virt.capsule#nixos)`,
`features/hardware.nix:4 (hardware.openrgb#nixos)`.

The exclusion contract holds: unselected features whose every class value is
a `throw` stay unforced; a path class value is accepted and never read.

The defects were all at the edges of the input shape. `badRecords` guarded
the feature record but not the area record or `requires`, so those still
aborted uncatchably (F-3), and an empty name passed the dotted check (F-5).
The fix widens the one guard (`badShapes`) rather than adding a second;
`tree` not being a list stays unchecked, as it is only ever
`import ./features`. `testProvenance` tested the fixture helper's own line
(F-6); it now checks, on the real tree, that `_file` points at the line naming
the feature, for an inline and a spilled record. That test reads the real
tree but stays robust to edits: it checks the line's content, not its number.

RV-007 re-checked: its tolerated (F-1, F-3, F-7) and aligned (F-5, F-6, F-8,
F-9) dispositions hold. Its brief is folded into the one below, which
supersedes it.

User decision (2026-10-15, this session): keep areas as `{ name; value; }`
pairs, not `baseNameOf` paths. Identity is written, never derived from
storage. No change.

Standing risks: provenance is relative only for records written in this flake
(F-4); a feature from a flake input would carry a store path. Stated in code;
ADR-002 D6 should state it too. Tooling: ISS-005 and CHR-010 unchanged.

Process note: the audit skill prescribes a `verified` disposition for
brief-bound findings; the CLI vocabulary has no such value. Used `aligned` +
brief, as RV-007 did.

## Reconciliation Brief

Supersedes RV-007's brief (all its items are carried here).

### Per-slice (direct edit)
- design.md sec-2 item 3 (RV-008 F-2, F-3, F-5): the structural pre-check is
  `badShapes`: area `{ name = <string>; value = <list>; }`, feature a record
  with a string name, `requires` a list of strings; reported alone. Names
  must be non-empty and dot-free.
- design.md sec-3 (RV-008 F-8, RV-007 F-5/F-6): example line `:4` → `:20`;
  position follows `name` (records written literally); relative for readable
  errors, and only for records in this flake (RV-008 F-4) — replace the
  "would churn derivations" rationale.
- design.md sec-4 (RV-008 F-6): testProvenance reads the real tree and checks
  the named line, inline and spilled; new testEmptyNameFails,
  testMalformedShapeFails, testNonRecordFeatureFails.

### Governance/spec (REV)
One REV over ADR-001, ADR-002, ADR-003 (RV-007 F-9, F-5, F-6; RV-008 F-4):
- ADR-002 D1: a feature is `{ name; nixos?; homeManager?; darwin?; requires?; }`,
  `name` a required non-empty, dot-free string; class values inline modules
  by convention.
- ADR-002 D2: `features/default.nix` lists areas as `{ name; value; }` pairs
  (kept by user decision 2026-10-15); each area is one file,
  `features/<area>.nix`, a list of self-named features.
- ADR-002 D3: granularity per DEC-015: halves together; own file by
  judgement (~100 lines prompts it), never split by platform; assets near
  their feature.
- ADR-002 D4: exclusion contract: descriptors may be inspected during
  selection; unselected class implementations and their package expressions
  are never forced by resolution or projection.
- ADR-002 D6: `_file` = "<flake-relative file>:<line> (<area>.<name>#<class>)",
  from the position of `name`; records written literally; relative for
  readability, for records written in this flake.
- ADR-001, ADR-002, ADR-003: MULTIHOST.md citations → RFC-001,
  `mem.fact.nix.merge-order`, `mem.pattern.flakes.drv-gate` (CHR-011).

### Knowledge
- DEC-015 supersedes DEC-003 and DEC-010 (RV-007 F-8): `doctrine supersede`.

### Evidence (direct edit, per user 2026-10-15)
- RFC-001: W1 done; W2/W3 start from the DEC-015 shape; tree diagram
  (`<area>/default.nix`) updated.

### Backlog
- CHR-011, CHR-012: resolved by SL-003 at close.
