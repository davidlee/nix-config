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
plus openrgb as the off feature that test 7 covers (DEC-008). Every
configuration's builds stay identical. Design decisions: DEC-001 to DEC-009.

1. **Feature tree** (DEC-003).
   - `features/default.nix` lists the areas `hardware` and `session` as
     `{ name; value; }` pairs.
   - Each area index lists its features the same way.
   - Snooze moves to `features/session/snooze/`: its descriptor, the
     `nixos.nix` and `home.nix` halves, and `bin/` with the script and its
     test.
   - openrgb moves to `features/hardware/openrgb.nix`.
   - The first outer profile is `features/profiles/workstation.nix`
     (DEC-004).
2. **Resolver**, `features.nix: lib: { tree, classes, modules }`.
   - Declares `feature.<area>.<name>.enable` per feature, defaulting to
     false (DEC-002).
   - Outer profiles set `mkDefault` values, and hosts import them
     (DEC-004).
   - Generates a `requires` assertion for each prerequisite (DEC-005), and an
     ADR-005 D6 assertion that each selected feature has a module for at
     least one of the host's classes.
   - Enforces all assertions. A failure throws, so nothing in the result can
     be read (DEC-006).
   - Projects per class in list order (DEC-007).
   - Returns `{ flags; modules }`. `flags` holds the legacy flags only.
3. **Factories.** `hosts.nix` resolves each host once, and every factory
   takes that selection as an argument.
   - `mkNixos` and `mkHome` append `modules.nixos` and `modules.homeManager`.
   - `mkDarwin` appends `modules.darwin` only. Darwin's embedded Home Manager
     gets no projection (DEC-001; IMP-012 tracks the alternative).
   - `flake.coverage` holds ADR-005 targets (DEC-008).
4. **Migrate snooze and openrgb** off their old flags and gated imports
   (`modules/features.nix`, `hosts/Sleipnir/{config,features}.nix`,
   `modules/home/linux/default.nix`).
   - Sleipnir imports the `workstation` profile. The Mac imports none, so it
     stops selecting snooze; its effective behaviour does not change.
5. **Tests** (each must fail before and pass after where meaningful):
   1. snooze selected by a profile default; both halves present.
   2. a host override turns it off; both halves leave their evaluations.
   3. a prerequisite that is off for a selected feature fails with the
      resolver's message, including on a home-only build (DEC-005).
   4. an unselected feature whose module `throw`s, and one referencing a
      missing package attribute, leave evaluation untouched (ADR-002 §4).
   5. `just drvs` identical for every configuration, or an ordering-only diff
      that is explained and proven (`drvs-sets`, `nix-diff`).
   6. nixpkgs pins and standalone HM activation unchanged (follows from 5).
   7. one evaluation-coverage target (ADR-005): `coverage."Sleipnir+openrgb"`,
      forced by `just coverage`, outside the switch path and the drvs gate.
   8. a selected feature with no module for any of its host's classes fails
      (ADR-005 D6).
   9. projection follows index list order, not `attrNames` (ADR-002 D5).
   Tests 1–4, 8 and 9 are pure resolver tests in `features-test.nix`, run as
   `checks.x86_64-linux.features` by `just test`. Tests 3, 4, 8 and 9 use
   inline fixtures (DEC-008).
6. **Docs.**
   - Update the README's "Feature flags" section and its snooze paths.
   - Correct the README's darwin `specialArgs` claim (`README.md:84-85`).
   - Update the stale comments in `features.nix`, `modules/features.nix` and
     `hosts.nix`.

## Non-Goals

- Migrating any other feature. The old flag mechanism keeps working for
  everything except snooze and openrgb.
- Lean defaults / default inversion (IMP-006), session identity (ISS-001),
  integrations (ADR-004) beyond what a test fixture needs.
- Platform-scope metadata (QUE-001).
- A tech spec; that follows once the spike locks the structure.
- Reference closure (B) or flake-aspects, unless a test shows A fails.

## Affected surface

- `features.nix`, new `features-test.nix`, `modules/features.nix`,
  `hosts.nix`, `perSystem.nix` (the checks), `hosts/Sleipnir/*`.
- `modules/nixos/{snooze,openrgb}.nix` and
  `modules/home/linux/{snooze.nix,default.nix,bin/snooze-nag*}`, all moved.
- New `features/**`.
- `justfile`: the `test` recipe, and a new `coverage` recipe.
- README.md.

## Risks and open questions

- **Ordering.** Projection moves the snooze halves to factory depth.
  - Snooze contributes to no shared list, so the result is expected to be
    derivation-identical.
  - The `drvs` and `drvs-sets` gates decide (mem.fact.nix.merge-order).
- **Moves.** `bin/snooze-nag` and its test must move together. Update the
  test path in `justfile:40`. New files need `git add -N`.
- Coexistence, profile placement, the test harness and the shape of
  `specialArgs.features` are settled by DEC-002, DEC-004, DEC-008 and
  DEC-006.

## Verification / closure

- Tests 1–9 pass; `just test` stays green; `nix fmt` clean (no
  committed lock drift, mem.fact.flakes.fmt-relock).
- HYP-001 refuted with the failing test named; otherwise the result is
  recorded as supporting evidence and HYP-001 stays `proposed` (design,
  "Governance impact and open items").
- ADR-001 to ADR-005 are amended through a revision at reconcile (DEC-009),
  then put to the user for acceptance.

## Summary

First feature through the new composition path; proves or refutes HYP-001
cheaply, and leaves a concrete pattern for the migration slices.

## Follow-Ups

- Tech spec for composition (absorbs `modules/DESIGN.md`, CHR-001).
- Rebase MULTIHOST S3–S9 into doctrine slices against the locked structure.
