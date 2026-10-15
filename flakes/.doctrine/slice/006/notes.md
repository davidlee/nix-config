# Notes SL-006: Legacy flags to feature tree: the rest of W3

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Design review (2026-10-16)

RV-013: one adversarial pass (Opus subagent; user's choice of lane), 11
findings (1 blocker, 3 major, 7 minor), all fixed in design and re-verified by
the reviewer; the whisper-cpp overlay repair (F-1) evaluated against the
pinned nixpkgs.

**Further review passes: none needed before lock.** The pass covered every
section and its fixes were re-checked. What a further pass would probe, and
where it is cheaper to probe it instead: whether the new probe measures
(udev rules dir, session desktops, fontconfig, ports) catch a flipped winner
— proven empirically by phase 1's baseline and gate, not by more reading;
and the phase-4 desktop diff, the largest surface — covered by the audit.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: <yyyy-mm-dd> · <PHASE-NN | stage> · <head-commit>

### Produced

### Learned

### Open
