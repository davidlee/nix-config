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
fresh-as-of: 2026-10-16 · ready (design locked, plan authored) · 164ffce7

### Produced
- DEC-023, DEC-024, DEC-025 (accepted; shape SL-006)
- RV-013 (design review, concluded; F-1..F-11 verified)
- ISS-008 (niri home half / umbriel coupling; sleipnir-doctor wpmPython)
- IMP-004 notes (fold-in narrowed to waybar; prune list)

### Learned
- (none recorded yet; candidate memory at close: whisper-cpp now takes its
  ggml backend from llama-cpp — pin ROCm targets via llama-cpp.override)

### Open
- IMP-003 (jackaudio), IMP-004 (prune), IMP-016, ISS-008, QUE-001
