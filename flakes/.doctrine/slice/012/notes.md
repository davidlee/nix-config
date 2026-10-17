# Notes SL-012: Transient breakage workarounds with removal checks

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: <yyyy-mm-dd> · <PHASE-NN | stage> · <head-commit>

### Produced

### Learned

### Open

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
