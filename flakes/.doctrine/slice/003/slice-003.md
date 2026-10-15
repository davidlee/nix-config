# Feature shape: area files and self-named features

## Context

The feature tree (ADR-002) currently costs a file layout tax per feature: an
area index of `{ name; value; }` pairs (4 lines per entry), and snooze as a
directory of three files, one a 4-line pointer to the other two. Extrapolated
over RFC-001 W3 (legacy flags → tree), that is ~60 feature files, many under
10 lines (`flatpak` 3, `ssd` 4, `rocm` 3), plus an index per area —
re-creating, as layout, the per-file ceremony REFACTOR.md removed.

CHR-012 proposed one file per feature. That still leaves the tiny files. The
user agreed (2026-10-15, in session) a different precedent, reviewed by an
external agent and adjudicated:

- **Feature** — the unit of selection: `{ name; nixos?; homeManager?;
  darwin?; requires?; }`, all halves inline together.
- **Area** — a namespace (`feature.<area>.<name>`) with one file,
  `features/<area>.nix`: a list of features in projection order. Never a
  selection or dependency boundary.
- **Spilled feature** — `features/<area>/<name>.nix`, listed as
  `(import ./<area>/<name>.nix)`, when the author judges it would dominate the
  area file (~100 lines is a prompt to reconsider, not a trigger). All halves
  stay together; never split by platform.
- **Assets** — near their feature; no directory that adds no navigation value.
- **Exclusion contract** — descriptors may be inspected during selection;
  unselected class implementations and their package expressions are never
  forced by resolution or projection.
- **Provenance** — `_file` carries both the physical location (flake-relative
  `file:line`, via `builtins.unsafeGetAttrPos "name"`) and the logical path
  (`<area>.<name>#<class>`). Never an absolute store path: it would churn
  derivations that embed declaration locations.

Moving a feature between files needs no host, profile or other-feature edit;
relative asset paths inside it may need adjusting. No path machinery to avoid
that.

## Scope & Objectives

1. **Resolver** (`features.nix`): areas are lists of self-named features;
   `name` is a required descriptor key; structural checks (missing name,
   duplicate, dotted, unknown key) over it; `_file` provenance as above.
   `features/default.nix` keeps `{ name; value; }` for areas only.
2. **Tests** (`features-test.nix`): reshape fixtures; add a missing-`name`
   failure and a provenance test. Existing order / duplicate / unselected-
   not-forced tests carry over.
3. **Migrate** the three existing features: `features/hardware.nix`
   (openrgb), `features/session.nix` (snooze, both halves inline; scripts
   beside it in `features/session/`), `features/virt.nix` +
   `features/virt/capsule.nix` (spilled). Pure move: `just drvs` identical.
4. **Docs**: README § Feature flags (feature tree) and § Snooze; header
   comments; `justfile` test path.
5. **Governance**: revise ADR-002 D1 (shape), D2 (indexes), D3 (granularity),
   D4 (exclusion contract wording), D6 (provenance). The same REV repoints
   ADR-001..003's MULTIHOST.md citations (CHR-011, folded in by the user
   2026-10-15). CHR-011 and CHR-012 resolve with this slice.
6. **RFC-001** brought current at reconcile by direct edit (evidence, not
   governance: no REV).

## Non-Goals

- Migrating any legacy flag (RFC-001 W3) or other module into the tree.
- ADR-004 composition files / integrations.
- Changing selection semantics, profiles, or host files.
- Enforcing "class values are inline" in the resolver (would force values,
  breaking the exclusion contract); it stays convention.

## Summary

Affected surface: `features.nix`, `features-test.nix`, `features/**`,
`justfile`, `README.md`, ADR-002, CHR-012.

Risks:
- `_file` change alters option-declaration locations; if any build embeds
  them (manual / options.json), `just drvs` diffs. Verify; a flake-relative
  string keeps them stable across commits, but differs from today's string.
  Expected: no feature declares options yet, so no diff. Any diff must be
  explained.
- Moving modules between files must not reorder projection (ADR-002 D5).

Verification: `just test` green (resolver + script tests); `just drvs`
identical to pre-change; `just coverage` evaluates; `nix fmt` clean (alejandra,
statix, deadnix).

## Follow-Ups

- RFC-001 W2/W3 adopt this shape.
