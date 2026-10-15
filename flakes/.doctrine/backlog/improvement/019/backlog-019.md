# IMP-019: Gate probe: pin emacs-overlay, normalise .manpath, target coverage homes

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Friction from SL-006's gate (RV-014 F-8; `bin/gate-probe`, `just probe`):

- `emacs/emacs-overlay` is unlocked under `home_override`, so home lines
  drift mid-capture (PHASE-01: b58afd9 → 08c72b0). Every later phase had to
  re-evaluate with `--override-input emacs/emacs-overlay <rev>`. Pin it in
  the gate's overrides.
- Any `home.packages` reorder moves `.manpath` (man-cache over man-paths),
  so `home-files-links` reports a change that is order-only (RV-014 F-1).
  Measure `.manpath` by content, or by its sorted man-paths inputs.
- `just probe` hard-codes Sleipnir; home mode cannot target a `coverage.*`
  configuration.
- Update `mem.pattern.flakes.drv-gate` to name `just probe` and the pin.
