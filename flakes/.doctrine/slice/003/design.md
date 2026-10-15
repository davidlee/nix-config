<!-- doctrine:section sec-1 -->
## Shape

DEC-015 (accepted) fixes the shape; this section states it as the resolver sees it.

```
features/default.nix   [ { name = "<area>"; value = import ./<area>.nix; } … ]   areas, in order
features/<area>.nix    [ <feature> … ]                                             features, in order
<feature>              { name; nixos?; homeManager?; darwin?; requires?; }         inline record, or
                       (import ./<area>/<name>.nix)                                a spilled one
```

- `name` is required and is the feature's identity; the address is `<area>.<name>`.
- Class values are inline modules by convention. A path is not refused (refusing would force the value, ADR-002 D4), but the shape never uses one.
- Spilled files hold the whole record, all halves together.
- Assets sit beside the area file in `features/<area>/`, named for their feature.
- Moving a feature between files changes no host, profile or other feature. Relative paths inside it may change.

<!-- doctrine:section sec-2 -->
## Resolver (`features.nix`)

Only the record shape changes; selection, checks, projection order and the result are untouched.

1. **Records.** An area's `value` is the feature list itself: `descriptor = f`, `name = f.name`. Was `f.name` / `f.value`.
2. **Allowed keys.** `[ "name" "nixos" "homeManager" "darwin" "requires" ]`.
3. **Shapes first.** `badShapes` checks, on its own and before anything that reads them: each area is `{ name = <string>; value = <list>; }`; each feature is a record (a path gets an `(import ./<area>/<name>.nix)` hint) with a string `name`; `requires` is a list of strings. It short-circuits the remaining structural checks, because those (and the option tree) read names, lists and `requires`, and a missing attribute or type error aborts uncatchably. The remaining checks add: names are non-empty and dot-free (`badName`). (Audit RV-007 F-4, RV-008 F-3, F-5.)
4. **Option tree** built from `f.name` per area, as now.
5. **Exclusion contract** (ADR-002 D4, reworded): descriptors may be inspected during selection; unselected class implementations and their package expressions are never forced by resolution or projection. The resolver reads only key names, `name`, `requires`, and attribute positions.

<!-- doctrine:section sec-3 -->
## Provenance

Each projected module carries both where the feature lives and which feature it is:

```
_file = "<flake-relative file>:<line> (<area>.<name>#<class>)"
        features/session.nix:20 (session.snooze#nixos)
```

- Position: `builtins.unsafeGetAttrPos "name" f`. Reads the position of the `name` attribute; forces no class value (verified, research.md Thread 2).
- Relative: `lib.removePrefix "${toString ./.}/" pos.file`. `features.nix` sits at the flake root, so `./.` is the same source tree the area files come from. Relative, for readable errors. This holds for records written in this flake; a record from elsewhere (a flake input) keeps its absolute path, as `removePrefix` leaves a non-match unchanged. Position follows `name`, so records are written literally by convention: one built by a helper reports the helper's line. (RV-007 F-5, F-6; RV-008 F-4.)
- Null position (a record built where Nix keeps no position): `unknown` in place of `file:line`.
- One helper, `origin`, computes the prefix; the format is defined in one place.

<!-- doctrine:section sec-4 -->
## Tests (`features-test.nix`)

- `feat name d` becomes `d // { inherit name; }`; `area` unchanged. Fixture trees keep their structure.
- Modules are identified by the logical part of `_file`, through one helper: `logical = m: head (match ".*\\((.*)\\)" m._file)`. Expected values become `a.x#homeManager`, `session.snooze#nixos`, `virt.capsule#nixos`.
- Carried over unchanged in intent: order, duplicates, dotted names, unknown keys, unselected-not-forced, requires, flag collision, nowhere-to-land, real-tree selection.
- New:
  - `testUnnamedFeatureFails` — no name, `name = 5`, named twin → `[ false false true ]`.
  - `testEmptyNameFails` — empty area name, empty feature name, twin → `[ false false true ]`.
  - `testMalformedShapeFails` — area without name, non-string area name, non-list area value, string `requires`, `requires = [1]`, twin → `[ false … true ]`.
  - `testNonRecordFeatureFails` — a bare path vs its `(import …)` → `[ false true ]`.
  - `testProvenance` — on the real tree, the file and line in `_file` name the feature, for snooze (inline) and capsule (spilled): relative, exact line, logical path. Checks the line's content, not its number, so edits above a record do not break it.
- Red first: the new tests and the reshaped helper go in before the resolver change.

<!-- doctrine:section sec-5 -->
## Code impact

| path | change |
|---|---|
| `features.nix` | records, allowed keys, unnamed check, `origin` + `_file`; header comment's shape lines |
| `features-test.nix` | `feat`, `logical`, expected tags, two new tests |
| `features/default.nix` | `import ./<area>.nix` |
| `features/hardware.nix` | new: openrgb inline (from `features/hardware/{default,openrgb}.nix`, deleted) |
| `features/session.nix` | new: snooze inline, one header comment for both halves (from `features/session/default.nix`, `snooze/{default,nixos,home}.nix`, deleted) |
| `features/session/snooze-nag`, `snooze-nag-test` | moved from `snooze/bin/` (git mv); script finds itself by dirname, no edit |
| `features/virt.nix` | new: `[ (import ./virt/capsule.nix) ]` (from `features/virt/default.nix`, deleted) |
| `features/virt/capsule.nix` | body wrapped as `{ name = "capsule"; nixos = <module>; }`; comments kept |
| `justfile` | snooze test path (l.42), comment (l.39) |
| `README.md` | § Feature flags › Feature tree (descriptor example, tree diagram, rules), § Snooze paths |

Unchanged: `hosts.nix`, host and profile files, `flake.nix` (its capsule comment path survives), coverage targets.

<!-- doctrine:section sec-6 -->
## Governance and docs

At reconcile, not during execution:

- **One REV** (`doctrine revision`) over ADR-001, ADR-002, ADR-003:
  - ADR-002 D1 shape (`name` required, records); D2 indexes (pairs for areas only; areas list self-named features); D3 granularity (area files, spill by judgement, halves together, assets near); D4 exclusion contract wording; D6 provenance (physical + logical, never a store path).
  - ADR-001..003: MULTIHOST.md citations repointed to RFC-001 and `mem.fact.nix.merge-order` / `mem.pattern.flakes.drv-gate` (CHR-011).
- **RFC-001**: brought current by direct edit (W1 done; W2/W3 start from this shape). No REV.
- **Backlog**: CHR-011 and CHR-012 resolved by SL-003 at close.

<!-- doctrine:section sec-7 -->
## Verification and phasing

Gates, all required:

- `just drvs` identical before/after. Baseline taken before the first edit; new files `git add -N` first (flakes see only tracked files). Any diff is red unless explained; an ordering-only diff needs `nix-diff` proof.
- `just test` green (resolver tests + snooze script tests from the new path).
- `just coverage` evaluates (`Sleipnir+openrgb`).
- `nix fmt` clean; statix and deadnix zero warnings.

Phasing suggestion for /plan: one code phase (resolver, tests and the three migrations land together; the real tree cannot evaluate under the new resolver until migrated), then one docs phase (README, justfile comment, header comments). Governance and RFC-001 follow at reconcile.

