# QUE-004: What shape is the Mac-hosted NixOS VM?

<!-- Knowledge record body — context, detail, links. The structured, queried
     fields live in the sister `record-NNN.toml`; this prose is free-form and is
     never structurally parsed (the storage rule). -->


## Answers so far (2026-11-08, from the user)

- **Shape:** graphical, lived in as the primary environment. Not headless:
  RFC-001 W7's `headless` profile and SSH-only use no longer fit.
- **Host:** UTM on Draupnir (M2, 32 GB). The VM must move to a new work
  Mac laptop (ASM-003: the employer allows it).
- **Deferred:** `satan.*` and `attention.goad`; they have no aarch64-linux
  outputs (EVD-005).
- **Rosetta:** no known need for x86 binaries.

## Still open

- **Backend:** UTM's Apple Virtualization or its QEMU backend. It hangs on
  GPU acceleration for a Wayland compositor (niri): Apple's virtio GPU has
  been reported falling back to llvmpipe; QEMU offers virgl, experimental.
  The user is testing both on Draupnir with a stock installer.
- **Bootstrap:** stock aarch64 NixOS installer, then build in the guest
  (proposed, not agreed).


## Status: parked (2026-11-08)

Parked until the user provisions an M5 (the work Mac). Resume there.

- **QEMU backend: works.** virgl-accelerated niri; 1:1 Retina with UTM
  native resolution and a fixed niri mode at scale 2 (EVD-006). No dynamic
  resize; clipboard likely broken under Wayland.
- **Apple backend: not tested.** Expected trade-off (inference, not
  measured): lower overhead, virtiofs, Rosetta, and probably the only path
  to nested virtualisation (capsule) on M3+; but reportedly no 3D for Linux
  guests (llvmpipe). Test it on the same install: convert the qcow2 disk to
  raw, attach it to an Apple-backend VM, repeat EVD-006's checks.
- **Also open:** multiple displays (one UTM window per display, one niri
  output each); clipboard bridging under Wayland; per-screen fixed modes.
- **Flake work** (IMP-072): the aarch64 evaluation blockers in EVD-005.
- **Drift:** RFC-001 W7 still specifies a headless, SSH-only guest with a
  `headless` profile. Revise it when this settles.
