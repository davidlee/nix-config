# IMP-072: W7 nixosvm: graphical aarch64 NixOS guest for the Mac

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

A host for RFC-001 W7, reshaped by QUE-004: a graphical NixOS guest you
live in on a Mac, under UTM, carried to the work Mac (an M5). Parked until
that machine is provisioned (2026-11-08).

## Known so far

- Backend: QEMU works with virgl-accelerated niri (EVD-006). The Apple
  backend is untested; decide between them first (QUE-004).
- 1:1 Retina needs a fixed niri mode at scale 2 per screen (built-in
  3024x1964); dynamic resize does not work under niri.

## Flake work (evaluation blockers, EVD-005)

```
hosts/nixosvm/{meta,features,config,machine,home}.nix   aarch64-linux, by-label disks
blocker                    where                                   fix
wl-clicker (broken)        features/desktop/core/wayland_packages  platform filter
discord, spotify           comms.chat, media.players               platform-skips or drop
satan.*, satan-attrd       satan area (x86_64-linux only)          off in the VM for now (user)
goad                       attention.goad (x86_64-linux only)      off in the VM for now (user)
zmux                       agents/flake.nix:38 (no aarch64-linux)  add the system in zmux's repo
(unknown)                  anything behind zmux                    re-probe after the zmux fix
```

- `workstation` assumes bare metal: snooze (RTC suspend) and maybe
  dictate do not belong in a guest. Override or split the profile.
- The guest needs a `machine.nix` with no hardware binding (virtio initrd
  modules, fallback EFI path) so one disk boots on either backend and on
  another Mac.
- Unverified: gateway credentials (host + TPM2 encryption) in a guest with
  no TPM, and after a move; `op` on aarch64-linux.
- ASM-003: the employer allows a personal VM. Check before copying it over.
- Revise RFC-001 W7 (headless, SSH-only) to match.
