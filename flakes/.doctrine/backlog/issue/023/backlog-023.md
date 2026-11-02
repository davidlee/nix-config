# ISS-023: just drvs aborts at homeConfigurations (elfutils on aarch64-darwin)

`just drvs` — the host-drift gate — cannot complete on this checkout, so it can
only be used group by group. Measured 2026-11-02 (SL-022 PHASE-03):

```
nixosConfigurations.Sleipnir /nix/store/fp2y9mw…-nixos-system-Sleipnir-26.11.20261027.31ecbac.drv
error: Refusing to evaluate package 'elfutils-0.195' … because it is not
       available on the requested hostPlatform: aarch64-darwin
       … while evaluating homeConfigurations."david@Draupnir".activationPackage
error: recipe `_drvs` failed on line 192 … recipe `drvs` failed on line 144
```

`set -euo pipefail` then hides `darwinConfigurations`, `packages`,
`legacyPackages` and `templates`. The pin is the locked nixpkgs
(`26.11.20261027.31ecbac`); whether the darwin home genuinely pulls `elfutils`, or
a re-resolved input (`emacs-overlay` HEAD is re-resolved at evaluation time) brings
a newer one, is not settled here.

Workaround used, and recorded as a memory
(`mem.fact.flakes.drv-gate-aborts-at-home`): run each group through the same
`_drvs` sub-recipe with the same `local_override` string, which yields stable
comparable lines for the other five groups.

Related: SL-022 (notes § PHASE-03) — EX-6 was evidenced that way.
