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
