# Darwin standalone Home Manager and unified pkgs factories

## Context

Three open items touch the same code: the per-kind factories in `hosts.nix`
and darwin's wiring in `darwin/default.nix`. The user merged them into one
slice (2026-10-15, in session: "CHR-003: let's pull it in. one slice.").
After research (`research/research.md`) the user folded in IMP-009 and
CHR-004, chose to import `modules/home/shared/default.nix` on the Mac, and
approved deleting `default.nix` (2026-10-15: "1. yeah 2. I'd pull it in …
3. yeah 4. yes, deleted code is the best code.").

```
today
mkNixos   lib.nixosSystem      modules set nixpkgs.overlays (+ agents, mkAfter)
mkHome    homeManagerConfiguration  pkgs = import nixpkgs-home { 3 overlays }
mkDarwin  pkgs = import nixpkgs { direnv-fix, lix-tools }   ← fixes live here
          darwinSystem { pkgs; specialArgs.pkgs }           ← ISS-004
            └─ darwin/default.nix
                 └─ HM darwinModule, useGlobalPkgs/useUserPackages  ← IMP-012
                      └─ darwin/home.nix (modules/home/shared/*)
```

- **IMP-012**: Linux runs Home Manager standalone (own pin `nixpkgs-home`,
  `home-switch` without sudo); darwin embeds it. ADR-003's reasons for the
  standalone shape (fast userland fixes, aggressive home pin) apply equally
  to the Mac. Embedded HM also gets no projected `homeManager` modules
  (DEC-001), which blocks every shared-home feature migration (RV-001 F-7).
- **ISS-004**: `mkDarwin` builds `pkgs` itself and passes it both to
  `darwinSystem` and as a specialArg, so `nixpkgs.overlays` set in a darwin
  module has no effect. The darwin package fixes are hard-coded in the
  factory instead of living in `darwin/`.
- **CHR-003**: `import <nixpkgs-ish> { system; allowUnfree; overlays }`
  appears four times; `agentsOverlay` is bound twice (`flake.nix`,
  `hosts.nix`); specialArgs differ per kind for no stated reason (darwin has
  `pkgs`, lacks `stable`).

## Scope & Objectives

Settled by DEC-016, DEC-017 and DEC-018 (design inquiry, 2026-10-15).

1. **Darwin home goes standalone** (IMP-012, DEC-017). One `mkHome` builds
   `homeConfigurations."david@<host>"` for every host with `meta.home`;
   `classesOf` reads `meta.home` for both kinds. `hosts/Davids-MacBook-Pro`
   becomes `hosts/Draupnir` (`home = true`, new `home.nix` mirroring
   Sleipnir's); `darwin/home.nix` becomes the darwin home base and imports
   `modules/home/shared` + `shared/cli.nix`; the embedded Home Manager block
   leaves `darwin/default.nix`.
2. **Evaluators build pkgs; factories inject one module** (ISS-004, IMP-009,
   CHR-003, DEC-016). specialArgs are `{inputs username hostname features}`
   for every kind. NixOS and darwin get `nixpkgs.hostPlatform = meta.system`
   plus a `mkAfter [agents]` overlay; home gets its overlays and
   `allowUnfree` as a module (conditional on the gate). `stable` becomes a
   module argument (`_module.args.stable`) set by the injected module, never
   a `pkgs` attribute (RV-009 F-2); its call sites are unchanged.
   `agentsOverlay` is bound once. No `importPkgs` helper.
3. **Dead overlays deleted**: darwin direnv `doCheck` (obsolete; defeated
   the binary cache) and lix-tools (no consumer).
4. **Outputs and gate** (CHR-003, CHR-004, DEC-018): `legacyPackages` and
   `packages` move into `hosts.nix`; `default.nix` deleted; `just drvs`
   covers `packages`, `legacyPackages` (probe) and `templates`.
5. **Activation**: per-OS flake ref in the justfile, darwin recipes default
   to `{{host}}`, `host := hostname -s`; every Mac evaluation overrides the
   `agents` input to the checkout (RV-009 F-1; lock drift is ISS-006).
   README § Bootstrap macOS gives the cut-over: build both artifacts first,
   activate prebuilt paths, recover forward (RV-009 F-4, F-8, F-9).
6. **Verification**: permanent evaluation-only check (`checks.factories`)
   that a darwin-module overlay reaches the `pkgs` modules receive, that
   `Draupnir` exists, and that `classesOf` reads `meta.home`
   (RV-009 F-3, F-5); `testMacSelectsNothing` fixture updated.
7. **Governance**: one REV at reconcile amends ADR-003 (three darwin
   passages) and ADR-001 §Context; DEC-006/DEC-007 wording edits; RFC-001
   direct edit. DEC-017 replaces DEC-001's projection-deferral consequence
   (DEC-001's choice stands). Resolves IMP-012, ISS-004, CHR-003, IMP-009,
   CHR-004.

## Non-Goals

- Migrating any shared home module into the feature tree (the next slice,
  which this unblocks).
- Changing NixOS or Linux home behaviour. Linux outputs must keep identical
  derivations (`just drvs`), except where CHR-003 is a pure refactor that
  should also be identical.
- Platform metadata on features (QUE-001).
- Bumping any input pin.
- Draupnir's nix settings, caches and `darwin/nix-core.nix` (IMP-014).

## Affected surface

`hosts.nix`, `flake.nix`, `default.nix` (deleted), `darwin/default.nix`,
`darwin/home.nix`, `hosts/Davids-MacBook-Pro/` → `hosts/Draupnir/` (with a
new `home.nix`), `features-test.nix`, `justfile`, `README.md`,
`overlays/agents.nix` (comment). `checks.factories` lives in `hosts.nix`.

## Risks & assumptions

- **Mac userland changes pin.** Embedded HM uses darwin's `pkgs`
  (`nixpkgs`); standalone uses `nixpkgs-home`. Both are locked to the same
  rev today, so no shift at cut-over; later drift accepted by the user
  ("versions shifting i can deal with").
- **Profile path changes.** Without `useUserPackages`, home packages move
  from `/etc/profiles/per-user/$USER` to `~/.nix-profile`. The nushell PATH
  hack in `darwin/home.nix` lists both; check it still holds.
- **Cut-over on the Mac is one-way-ish.** The first darwin activation
  without embedded HM, then the first standalone home activation, must run
  in order without leaving the user without a shell profile. Both are built
  before either activates; recovery is forward (standalone activation), with
  a switch-generation last resort that reverts the hostname. Executed by the
  user on the Mac, online (Homebrew runs on activation).
- **`agents` is locked to a Linux path** (ISS-006). Every Mac evaluation
  depends on the justfile override until the lock is fixed.
- **Verification from Linux is evaluation only.** Darwin and Mac home
  derivations evaluate on Sleipnir (confirmed: `darwinConfigurations.
  Davids-MacBook-Pro.system.drvPath` evaluated before the rename), but activation can only be
  checked on the Mac.
- **lix-tools overlay** is deleted; it has no consumer, and the darwin system
  keeps `nix.enable = false` (installer-managed Lix; see IMP-014).
- **Home module overlays** (DEC-016) assume Home Manager re-instantiating
  pkgs from module config yields identical Linux home derivations; the gate
  decides, with the factory-overlay fallback.

## Open questions (for design)

All settled: DEC-016, DEC-017, DEC-018.

## Verification / closure intent

- `just drvs`: NixOS, Linux home, `packages`, `legacyPackages` probe and
  `templates` identical before/after. Darwin system derivation changes
  (expected; HM removed, hostname); new `homeConfigurations."david@Draupnir"`
  evaluates.
- A darwin module setting `nixpkgs.overlays` takes effect (eval check: an
  overlaid attr is visible in the `pkgs` argument modules receive; red
  against today's mkDarwin).
- `just test` passes; `classesOf` change covered.
- Draupnir home package names equal today's embedded set except the
  expected delta: `home-manager` CLI, hm-session-vars, `EDITOR`/`VISUAL`;
  direnv and mise come from cache.nixos.org.
- Permanent check: a darwin-module overlay reaches darwin pkgs.
- User performs the cut-over on the Mac (VH, verified by human).

## Summary

## Follow-Ups
