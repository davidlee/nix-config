# ISS-024: ccache fails to evaluate on aarch64-darwin: elfutils (Linux-only) in its build inputs

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

## Observed (2026-11-03, SL-023 PHASE-01 EN-2 baseline)

`homeConfigurations."david@Draupnir"` fails to evaluate: `ccache-4.14.2`
(listed in `dev.tools` through `available`) carries `elfutils-0.195` in its
`nativeBuildInputs`, and elfutils' `meta.platforms` excludes aarch64-darwin.
`availableOn` sees only ccache's own platforms, so the filter passes it. The
nixpkgs-home pin's `ccache.drvPath` fails on aarch64-darwin by itself;
`sccache` and `mold` evaluate. `just drvs` and `just coverage` (isolation)
fail on Draupnir.

## Workaround

`ccache` in `features/platform-skips.nix` (aarch64-darwin), with a manual
probe in `workarounds/default.nix`: the cache cannot answer a package that
does not evaluate.

## Done when

`nix eval nixpkgs-home#legacyPackages.aarch64-darwin.ccache.drvPath` (or the
equivalent at the current pin) evaluates: remove the skip entry and the probe.
