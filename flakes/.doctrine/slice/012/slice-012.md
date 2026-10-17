# Transient breakage workarounds with removal checks

## Context

When an unstable package breaks, the workaround today is ad hoc and records
nothing about when it can go:

- `overlays/click-threading-fix.nix`: a hand-written overlay (`doCheck = false`)
  with no removal condition.
- `features/audio.nix` (`audio.speech`): `python313Packages.kokoro` commented out
  under `# BROKEN - transient python dep issue`. The package disappears without
  trace. Uncommented in the working tree, untested.
- `features/cli-broken.nix` (DEC-036): per-system skips. It mixes permanent
  entries (gtt needs alsa-lib; binutils-wrapper collides) with transient ones
  (atuin uncached, ISS-007; shell_cmds and yEd uncached, SL-008 VH-1). The
  transient ones also need a removal check.
- ISS-007 already names the right signal for "fixed": `nix path-info --store
  https://cache.nixos.org <outPath>`.

Two facts are fixed:

- Flake evaluation is pure. `--override-input` needs no `--impure`, so eval has
  no clock and no network.
- The answer can change only when the lock changes.

```
overlays/workarounds.nix   probes only: {attr, pin, system, issue, reason, sites}
        │
        └──> just workarounds-check (end of update-system / update-home)
               unpatched outPath on cache.nixos.org?
                 cached  ──> "candidate: remove <sites> (<issue>)", exit 1
                 absent  ──> ok
                 unknown ──> warn
fixes: local, beside their consumer (DEC-016), each citing its issue
       last-good: lib lastGood {rev; narHash} attr, for leaf apps
```

## Scope & Objectives

Decisions: DEC-052 … DEC-057 (design run inq-1 … inq-6).

1. **Probe registry** (DEC-053): `overlays/workarounds.nix`, plain data. It
   applies nothing. Fixes stay local and list every site to revert.
2. **lastGood helper** (DEC-054): a locked nixpkgs attr for leaf apps, plus
   `bin/workaround last-good <pin>` to print `{rev; narHash}` from the previous
   committed lock. Libraries get a local patch instead.
3. **Removal check** (DEC-055): a `workaroundProbes` flake output and
   `just workarounds-check`, with three states. It runs at the end of
   `update-system` / `update-home`, and its stubbed behaviour test runs in
   `just test`.
4. **Existing cases:** done ahead of the mechanism. click-threading's overlay
   was removed (28861d6c), and kokoro was re-enabled by the user.
5. **Rename** (DEC-052): `features/cli-broken.nix` becomes
   `features/platform-skips.nix`. Update `available.nix`, the README, the
   profile and host comments, the memory `mem.fact.flakes.availableon-limits`,
   and DEC-036.
6. **Transient skips** (DEC-056): atuin (ISS-007), shell_cmds and yEd get probes
   whose sites name every revert point (for atuin: `modules/home/cli.nix`,
   `modules/home/darwin/default.nix`, the skip list).
7. **Pre-build list** (DEC-057): `just will-build` shows noise grouped, never
   dropped. It runs on demand and after `update-*`. Home builds go through
   `nom`, keeping the exit status. `nix-output-monitor` joins the home base, because the Mac
   has no nom (RV-025 F-7).

## Non-Goals

- Fixing atuin itself (ISS-007), beyond probing it.
- Bumping `stable` off 24.11 (EOL). Leave it for a backlog item.
- Eval-time expiry or version tripwires (research X-3).
- Scanning for fixes that have no probe.

## Affected surface

- `overlays/workarounds.nix` (new), `lib` helper for `lastGood`, `bin/` (check,
  helper, will-build) and their tests
- `hosts.nix` or `overlays.nix` (the `workaroundProbes` output)
- `features/cli-broken.nix` → `features/platform-skips.nix`, `features/available.nix`
- `justfile` (`test`, `update-system`, `update-home`, `home-switch`,
  `home-build`, new recipes)
- `README.md`, `features/profiles/personal-darwin.nix`,
  `hosts/Draupnir/features.nix` (comments), DEC-036, the availableon-limits memory

## Risks & assumptions

- A Python package taken from `stable` carries its own interpreter. That is fine
  as a leaf app, but it breaks inside a python env. The replacement kind has to
  fit the case.
- Cached means it builds, not that a runtime bug is fixed. Runtime probes use
  `signal = manual` (DEC-055).
- No cache entry does not mean "still broken" (not built yet, unfree). Only a
  positive result prompts.
- The check needs network. It reports `unknown` when offline, and it stays out
  of the gate.
- Computing unstable's unpatched outPath must not evaluate the overlay (use
  `inputs.nixpkgs.legacyPackages` directly, or the overlay's `prev`).

## Open questions

All settled at design: DEC-052 … DEC-057.

## Verification intent

- Behaviour tests in `just test`, with `nix` stubbed: the check gives cached →
  exit 1 naming the sites, absent → ok, unknown → warn, and a manual probe is
  listed but never probed. will-build groups the noise and never drops it.
  `lastGood` returns the locked attr.
- `just test`, `just coverage` and `just drvs` stay green. Sleipnir and Draupnir
  drvPaths are unchanged (the probes apply nothing; the rename is
  behaviour-neutral).
- A live `just workarounds-check` against the real probes reports their
  states, today: atuin and shell_cmds probed for aarch64-darwin, yEd manual
  (unfree).
- `rg cli-broken` finds nothing outside history and closed slices.

## Summary

## Follow-Ups
