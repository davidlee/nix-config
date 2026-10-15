# Snooze pilot: first feature under the typed outer resolver

## Context

ADR-001..005 (proposed) set the direction for feature composition: selection
resolved outside the NixOS / Home Manager / darwin evaluations by the existing
typed resolver (`features.nix` + `modules/features.nix`), features as plain
data `{nixos?, darwin?, homeManager?}` addressed by attribute path, explicit
area indexes, enforced validation, explicit projection order, evaluation
coverage for off features.

HYP-001 claims that this mechanism is sufficient for the repo's coupling
(EVD-001), with no reference graph or composition library. This slice tests
it on one modest cross-class feature before the larger migrations (capsule,
agents, the desktop and home areas — MULTIHOST S3–S6).

Snooze is the pilot: a NixOS half (`modules/nixos/snooze.nix`, RTC wake timer,
27 lines) and a Home Manager half (`modules/home/linux/snooze.nix`, nag
timer + script, 49 lines), already behind the `snooze` flag, no external
inputs, behaviour tests in `modules/home/linux/bin/snooze-nag-test`.

## Scope & Objectives

Land the minimal outer-composition machinery and migrate snooze onto it,
leaving Sleipnir's builds identical.

1. **Feature tree.** `features/` with one area index (area name decided in
   design) holding `snooze = { nixos = …; homeManager = …; }`; the existing
   module files move there or are referenced from there.
2. **Resolver.** Extend the outer evaluation to:
   - declare one `enable` option per feature in the tree;
   - support outer profiles setting `mkDefault`;
   - declare and **enforce** `assertions` (refuse to return a selection while
     any fail), consumed by every factory in `hosts.nix`;
   - project selected features per class in area-index order.
3. **Factories.** `mkNixos` / `mkHome` / `mkDarwin` import the projected
   modules for their class.
4. **Migrate snooze** off the old flag and gated imports
   (`hosts/Sleipnir/config.nix`, `modules/home/linux/default.nix`).
5. **Tests** (each must fail before and pass after where meaningful):
   1. snooze selected by a profile default; both halves present.
   2. a host override turns it off; both halves leave their evaluations.
   3. an explicit `false` on a prerequisite of a selected feature fails with
      the resolver's message, including on a home-only build.
   4. an unselected feature whose module `throw`s, and one referencing a
      missing package attribute, leave evaluation untouched (ADR-002 §4).
   5. `just drvs` identical for every configuration, or an ordering-only diff
      that is explained and proven (`drvs-sets`, `nix-diff`).
   6. nixpkgs pins and standalone HM activation unchanged (follows from 5).
   7. one evaluation-coverage target (ADR-005) that selects a feature
      Sleipnir has off, forcing its derivation; outside the switch path.
   Tests 3, 4 and 7 use fixture features, not real ones.
6. **Docs.** README "Feature flags" section updated for whatever changes.

## Non-Goals

- Migrating any other feature; the old flag mechanism keeps working for
  everything except snooze.
- Lean defaults / default inversion (IMP-006), session identity (ISS-001),
  integrations (ADR-004) beyond what a test fixture needs.
- Platform-scope metadata (QUE-001).
- A tech spec; that follows once the spike locks the structure.
- Reference closure (B) or flake-aspects, unless a test shows A fails.

## Affected surface

`features.nix`, `modules/features.nix`, `hosts.nix`, `hosts/Sleipnir/*`,
`modules/nixos/snooze.nix`, `modules/home/linux/{snooze.nix,default.nix}`,
new `features/**`, `profiles/**` (outer profiles, if placed there), `justfile`
(coverage target, test recipe), README.md.

## Risks and open questions

- **Coexistence.** During migration, old boolean flags and feature `enable`
  options share one outer evaluation. Design must settle the namespace (e.g.
  is snooze's option still `features.snooze`, or `features.<area>.snooze`?)
  and how host files read both.
- **Profile placement.** Sleipnir has no outer profile today; test 1 needs
  one. Where outer profiles live (`profiles/` already holds HM import lists).
- **Ordering.** Moving snooze's imports out of the host file and
  `home/linux/default.nix` will likely reorder merged lists (systemd units are
  attrsets, so perhaps not). Budget proof work (mem.fact.nix.merge-order).
- **Test harness.** Fixture-based eval tests need a home: `nix eval` checks
  driven from the justfile, or flake `checks`. Must not slow `switch`.
- **`specialArgs.features` shape.** Factories and `home/linux/default.nix`
  read it; the projected-module approach must not break the remaining
  flag-gated imports.

## Verification / closure

- All seven tests pass; `just test` stays green; `nix fmt` clean (no
  committed lock drift, mem.fact.flakes.fmt-relock).
- HYP-001 status set from the result (confirmed, or refuted with the
  failing test named).
- ADR-001..005 amended if the spike contradicts them, then put to the user for
  acceptance.

## Summary

First feature through the new composition path; proves or refutes HYP-001
cheaply, and leaves a concrete pattern for the migration slices.

## Follow-Ups

- Tech spec for composition (absorbs `modules/DESIGN.md`, CHR-001).
- Rebase MULTIHOST S3–S9 into doctrine slices against the locked structure.
