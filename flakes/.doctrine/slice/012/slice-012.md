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
workaround entry (data)
   │
   ├──> overlay: replacement for every consumer (transitive, e.g. click-threading)
   │
   └──> removal check (just test, after just update):
          unstable's own outPath on cache.nixos.org?  ──yes──> FAIL "remove <entry>: <reason>"
          version != brokenAt?                         ──yes──> warn
```

## Scope & Objectives

1. **Workaround registry.** One plain-data list. Each entry names the attribute
   path, the reason with a backlog id, the version at breakage (`brokenAt`), and
   the replacement: `stable`, a last-known-good unstable rev, or a patch function.
2. **One overlay built from it**, wired in `hosts.nix` for nixos, darwin and home
   pkgs. It loads `inputs.stable` itself, because `stable` is not a pkgs
   attribute (`hosts.nix:16`, mem.fact.nix.callpackage-autoargs).
3. **Removal check:** a `just` recipe that runs in `just test` and after
   `just update` / `update-local`. For each entry it fails when unstable's
   unpatched derivation is on cache.nixos.org. Eval-time `lib.warn` when the
   version moves past `brokenAt`. Builds and switches never fail on it.
4. **Existing cases:** done ahead of the mechanism. click-threading's overlay
   was removed (28861d6c, unpatched build is cached), and kokoro is cached and
   re-enabled by the user (research X-3). Neither needs an entry.
5. **Naming:** rename `features/cli-broken.nix` to say what it is (per-platform
   skips for the cli availability filter). Update `available.nix`, the README,
   the profile and host comments, and DEC-036's path reference.
6. **Transient entries in the skip list** (atuin, shell_cmds, yEd) get the same
   removal check, or move to a form that has it (OQ-2).
7. **Pre-build list** (user, 2026-10-17): before `system-switch` /
   `home-switch` (and on demand), print what the build will compile locally:
   `nix build --dry-run`'s "will be built" set, minus trivial config
   derivations (etc, activate, units, registry json). When a build fails, the
   culprit is almost always in that list. It shares the cache-query code with
   the removal check. Note the difference: dry-run counts the local store as
   well as the caches; the removal check asks cache.nixos.org alone.

## Non-Goals

- Retiring ISS-007's other workaround site, unless the design folds it in.
- Bumping `stable` off 24.11 (EOL). Note it, and leave it for a backlog item.
- A date-based expiry in eval (impossible in pure eval). A recipe-side date
  backstop only if the design wants one.
- Fixing kokoro upstream.

## Affected surface

- `overlays/` (new registry and overlay; `click-threading-fix.nix` removed)
- `hosts.nix` (overlay wiring)
- `features/cli-broken.nix` (renamed), `features/available.nix`
- `justfile` (`test`, `update`, `update-local`, the new check recipe)
- `README.md`, `features/profiles/personal-darwin.nix`,
  `hosts/Draupnir/features.nix` (comments), DEC-036

## Risks & assumptions

- A Python package taken from `stable` carries its own interpreter. That is fine
  as a leaf app, but it breaks inside a python env. The replacement kind has to
  fit the case.
- No cache entry does not mean "still broken" (not built yet, unfree). The check
  fails only on a positive signal: present means fixed.
- The check needs network. It must degrade to a warning when offline, not fail.
- Computing unstable's unpatched outPath must not evaluate the overlay (use
  `inputs.nixpkgs.legacyPackages` directly, or the overlay's `prev`).

## Open questions

DEC-016 ("local fix overlays sit beside their consumer") may be amended if the
design needs it (user, 2026-10-17). Research X-1 offers a way to keep it.

- OQ-1: Where does the registry live? `overlays/workarounds.nix` (it patches pkgs,
  not features) or `features/`?
- OQ-2: One registry for both kinds (replace everywhere vs skip on one platform,
  each kind permanent or transient), or two lists sharing one removal check?
- OQ-3: The new name for `cli-broken.nix`, e.g. `unavailable.nix` (the
  complement of `available.nix`) or `platform-skips.nix`.
- OQ-4: The last-good-rev mechanism: an extra flake input per entry, or
  `builtins.fetchTarball` with a hash?

## Verification intent

- The removal check fails on a fixture entry whose unstable package is cached,
  and passes on one whose package is not (behaviour test, network stubbed).
- `just test`, `just coverage` and `just drvs` stay green. Sleipnir and Draupnir
  drvPaths are unchanged apart from the intended replacements.
- `rg cli-broken` finds nothing outside history and closed slices.

## Summary

## Follow-Ups
