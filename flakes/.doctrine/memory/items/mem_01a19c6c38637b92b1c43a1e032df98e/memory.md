Measured 2026-11-02 (SL-022 PHASE-03) on this checkout. `just drvs` prints
`nixosConfigurations.Sleipnir …` and then stops: `justfile:144` fails evaluating
`homeConfigurations."david@Draupnir".activationPackage` because `elfutils-0.195`
is "not available on the requested hostPlatform: aarch64-darwin" in the pinned
nixpkgs. `set -euo pipefail` means `darwinConfigurations`, `packages`,
`legacyPackages` and `templates` never run.

For a before/after drift gate, run each group through the same `_drvs` sub-recipe
with the same overrides — `ov=$(just --evaluate local_override 2>/dev/null |
tail -n 1)`, then `just _drvs <output> '<pick>' "$ov"` — which yields stable,
comparable lines for the other five groups (byte-identical across a phase that
touched only `justfile`, `README.md` and `dev-envs/`). Point `XDG_CACHE_HOME` at a
writable directory or nix dies writing `fetcher-cache-v1.sqlite`.