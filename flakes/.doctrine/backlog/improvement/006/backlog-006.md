# IMP-006: Make default selection lean

MULTIHOST S7. After the migration preserves each host's effective selection, flip defaults so a host that says nothing gets a lean baseline, and make every host's selection explicit. A deliberate behaviour change, separate from identity-preserving slices (ADR-001 §7). Sleipnir then turns off what is unused (sway, niri, KDE, qemu, ROCm, Blender, …).

W3 slices discharge this incrementally: tree features default off (SL-005 design sec-5), so each migration makes a host's selection explicit.

SL-006 completes W3: every former flag is a tree feature, default off, and
Sleipnir's selection is explicit.
