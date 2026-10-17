# Notes SL-012: Transient breakage workarounds with removal checks

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-17 · design locked, slice at plan · a393d52f

### Produced
DEC-052 DEC-053 DEC-054 DEC-055 DEC-056 DEC-057 · RV-025 (concluded, 8 fixed) ·
design.md (locked, run rev 31) · 28861d6c (click-threading overlay removed) ·
mem.fact.nix.lock-node-names · mem.fact.flakes.nom-darwin-sh

### Learned
mem.fact.nix.lock-node-names (RV-025 F-5) · mem.fact.flakes.nom-darwin-sh
(F-7, F-8) · research X-3 (fixes land without version bumps)

### Open
- chore for shell_cmds + yEd probes: file at P2 (design sec-4)
- improvement: stable is nixos-24.11, EOL: noted in design sec-7, not filed
- at reconcile: DEC-053 path (workarounds/, not overlays/), DEC-036 rename

## Design triage (2026-10-17, exploring)

Open questions: design run inq-1 … inq-6 (`doctrine design tree SL-012`).

Constraining governance (research Thread 1): DEC-016 (fix overlays beside
consumer; user: may be amended), ADR-003 (two pins: nixpkgs, nixpkgs-home),
DEC-036 (skip list owner), ISS-004 (darwin overlays only via modules),
ADR-005 (coverage targets carry unselected features' packages).

Shaping evidence (research X-3, X-4): both real cases were fixed with no
version change, so the cache probe is the signal. kokoro is absent from
stable 24.11, so stable is not the default replacement.

Risks: a cached-but-permanent skip (binutils-wrapper) would fire a naive
check; offline runs must not fail; overlay from config must not depend on pkgs
(cycle); dry-run before every switch doubles evaluation time.

Assumptions: a workaround is pin-wide, not host-specific (an overlay on a
package outside a closure is free, by laziness). system-switch already pipes
through nom (`run.sh`), which shows planned builds and names a failed drv.

Done ahead of the mechanism: 28861d6c (click-threading overlay); kokoro
re-enabled by the user.
