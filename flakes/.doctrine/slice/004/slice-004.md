# Darwin standalone Home Manager and unified pkgs factories

## Context

Three open items touch the same code: the per-kind factories in `hosts.nix`
and darwin's wiring in `darwin/default.nix`. The user merged them into one
slice (2026-10-15, in session: "CHR-003: let's pull it in. one slice.").

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

1. **Darwin home goes standalone.** `homeConfigurations."david@<host>"` is
   produced for darwin hosts too, by the same `mkHome`. `darwin/home.nix`
   becomes the host's home entry (location is a design question). The
   embedded `home-manager.darwinModules` block is removed. `classesOf`
   gives darwin `["darwin" "homeManager"]`, so darwin gets `homeManager`
   projection.
2. **Darwin owns its overlays.** `mkDarwin` stops passing a pre-built
   `pkgs`; the direnv and lix-tools fixes move into a `darwin/` module as
   `nixpkgs.overlays`, matching how NixOS hosts do it.
3. **One `importPkgs` helper and one `commonArgs` builder** in `hosts.nix`.
   `agentsOverlay` is bound once. `legacyPackages`/`packages` move out of
   `flake.nix` beside the helper, leaving `flake.nix` as inputs + templates.
4. **Activation**: `justfile` home recipes work for the Mac (`home-switch`,
   `home-build` by `hostname`); `darwin-switch` no longer activates home.
   README § Bootstrap macOS and § Feature flags updated.
5. **Governance**: amend ADR-003 (both platforms standalone); supersede or
   amend DEC-001's "embedded HM gets no projection" consequence. Resolves
   IMP-012, ISS-004, CHR-003.

## Non-Goals

- Migrating any shared home module into the feature tree (the next slice,
  which this unblocks).
- Changing NixOS or Linux home behaviour. Linux outputs must keep identical
  derivations (`just drvs`), except where CHR-003 is a pure refactor that
  should also be identical.
- Platform metadata on features (QUE-001).
- Bumping any input pin.

## Affected surface

`hosts.nix`, `flake.nix`, `darwin/default.nix`, `darwin/home.nix`, a new
`darwin/` overlay module (name: design), `hosts/Davids-MacBook-Pro/`
(a `home.nix` entry, possibly), `justfile`, `README.md`, `features-test.nix`
only if `classesOf` behaviour is tested there.

## Risks & assumptions

- **Mac userland changes pin.** Embedded HM uses darwin's `pkgs`
  (`nixpkgs`); standalone uses `nixpkgs-home`. Today both track
  nixos-unstable but are locked separately, so Mac home packages may change
  version. Accepted as the point of IMP-012; noted for the cut-over.
- **Profile path changes.** Without `useUserPackages`, home packages move
  from `/etc/profiles/per-user/$USER` to `~/.nix-profile`. The nushell PATH
  hack in `darwin/home.nix` lists both; check it still holds.
- **Cut-over on the Mac is one-way-ish.** The first `darwin-switch` without
  embedded HM, then the first standalone `home-switch`, must run in order
  without leaving the user without a shell profile. Needs a written cut-over
  procedure; executed by the user on the Mac.
- **Verification from Linux is evaluation only.** Darwin and Mac home
  derivations evaluate on Sleipnir (confirmed: `darwinConfigurations.
  Davids-MacBook-Pro.system.drvPath` evaluates), but activation can only be
  checked on the Mac.
- **lix-tools overlay** pulls `prev.lixPackageSets.stable`; the darwin
  system keeps `nix.enable = false` (installer-managed Lix). Moving the
  overlay must not change which nix the Mac uses.

## Open questions (for design)

- Where the darwin home entry lives: keep `darwin/home.nix` imported from
  `hosts/<mac>/home.nix` (symmetric with Linux), or move it.
- Should the `darwin`-only system packages (`darwin/packages.nix`) partly
  move to home now that the Mac has a home pin? Default: no (non-goal
  unless trivially required).
- Exact shape of `commonArgs`: does darwin get `stable` (likely yes, for
  symmetry) and lose `pkgs` as a specialArg (yes, that is ISS-004)?

## Verification / closure intent

- `just drvs`: NixOS and Linux home derivations identical before/after.
  Darwin system derivation changes (expected; HM removed); new
  `homeConfigurations."david@Davids-MacBook-Pro"` evaluates.
- A darwin module setting `nixpkgs.overlays` takes effect (eval check: an
  overlaid attr is visible in `config` / `pkgs`).
- `just test` passes; `classesOf` change covered.
- Mac home package set equals today's embedded set, modulo pin
  (`drvs-sets`-style comparison of package names).
- User performs the cut-over on the Mac (VH, verified by human).

## Summary

## Follow-Ups
