# NixOS base / host split

## Context

RFC-001 W4. With W3 done (SL-005, SL-006), selection is one mechanism: the
feature tree. But `hosts/Sleipnir/config.nix` still imports ~30
`modules/nixos/*.nix` flat, without saying which are the **base** (what every
NixOS host imports unconditionally), which are optional (desktop-shared and
other features), and which belong to Sleipnir alone. A second NixOS host
(W7, the headless aarch64 `nixosvm`) cannot take "the base" while the base is
not written down.

```
today                                    target
hosts/Sleipnir/config.nix                hosts/Sleipnir/config.nix
  ├─ hardware-configuration, machine       ├─ hardware-configuration, machine
  ├─ ~30 modules/nixos/*.nix (flat)        ├─ <the NixOS base>          (every NixOS host)
  └─ overlays (llama-prism, …)             └─ Sleipnir-only modules
                                         features/  desktop-shared + other optional
                                         hosts/Sleipnir/features.nix  selects them
```

User (2026-10-16): take W4 now, IMP-004's prune included.

## Scope & Objectives

Settled in design (2026-10-16): DEC-026 (desktop taxonomy), DEC-027 (base
shape), DEC-028 (placement), DEC-029 (ControlD DNS under POL-001).

1. **Classify** each module in `modules/nixos/` (and each import in
   `hosts/Sleipnir/config.nix`) as one of:
   - **base** (DEC-027) — `nix` (with lix), `user`, `ssh`, `cli`, `locate`,
     `maintenance`, `env`, `boot`, `kernel`, `avahi`, cargo/build libs, and
     the generic halves of `security`, `network`, `programs`;
   - **feature** (DEC-026, DEC-028) — `desktop.{core,greeter,fonts}`,
     `compositor.{sway,niri,cosmic,kde,mango,umbriel}`, `shell.noctalia`,
     `audio.pipewire`, `hardware.{bluetooth,qmk,tablet,logitech}`,
     `services.postgresql`; `services.webserver` gains ports 80/443;
   - **machine config** (DEC-019, DEC-028) — radeon (+ video group), kernel
     blacklist, i2c, the `enp8s0` profile, nix jobs/cores/MemoryHigh, swapfile;
   - **Sleipnir host config** (DEC-028) — `system.stateVersion`, `oom.nix`,
     ControlD DNS (`hosts/Sleipnir/dns.nix`, DEC-029), `gai.conf`, overlays,
     the rtcwake sudo rule.
2. **Express the base** (DEC-027): `modules/nixos/default.nix`, an import
   list, imported by each NixOS host's `config.nix`. Not a profile; no
   factory change. `modules/nixos/` then holds only the base (plus parked).
3. **Split mixed modules**: `programs`, `security`, `network`, `1password`,
   `util`, `env`, `kernel`, `lib`, `keyring` — generic halves to the base,
   desktop halves to `desktop.core`, machine/host parts as above.
4. **Move** the optional modules onto the feature tree (DEC-015 shape).
   `desktop.core` is selected by the workstation profile; the rest by
   `hosts/Sleipnir/features.nix` (DEC-024). Sleipnir's effective selection
   is unchanged. **Rename** `feature.desktop.<wm>` → `feature.compositor.<wm>`
   and `noctalia` out of niri's record into `shell.noctalia` (DEC-026).
5. **Base evaluation target** (DEC-027): an evaluation-only aarch64-linux
   configuration importing only the base (coverage style); `cpuid`/`x86info`
   guarded to x86. The only new coverage target.
6. **Behaviour-change phase** (own phase, not set-preserving): IMP-004 prune
   of `wayland_packages.nix` (`wob`, `i3status`, `wf-config`,
   `gnomeExtensions.appindicator`, `marble-shell-theme`); duplicate
   `sway-easyfocus` (RV-014 F-5); keyring `greedt` typo; postgresql's stray
   80/443; undefined `dev` group; helix from nix-ld libs to systemPackages;
   drop the Rust `kernelPatch` (kernel `.config` compared identical first).
7. README: host/base/feature description and tree listing, per phase.

Phasing (user, 2026-10-16): P1 base · P2 machine + host · P3 desktop,
compositor, shell · P4 audio, hardware, services · P5 aarch64 base target ·
P6 behaviour changes. Detail in design.md.

## Non-Goals

- Home side: home base / personal split is W5.
- Agents (`registry.agents`, overlay) are W2; `nix.nix` keeps the registry
  until then.
- Per-host overlays into their features (W9), unless design finds the move
  falls out of a module it already touches.
- Lean default selection (IMP-006); new hosts (W7) — the aarch64 base
  target is an evaluation only, not a host. W7 decides the VM's DNS.
- IMP-002 (private input, ControlD rotation): DEC-029 moves the value as-is.
- Desktop behaviour: ISS-001, IMP-005, ISS-008 (CPT-001).
- Parked modules (`hyprland`, `kmscon`) stay parked.

## Affected surface

`modules/nixos/**`, `hosts/Sleipnir/{config,machine,features,dns}.nix`,
`features/**` (new `compositor` and `shell` areas, new records),
`features/profiles/**`, `flake.coverage` (aarch64 base target),
`features-test.nix`, `modules/shared/cli/_packages/system.nix`, `README.md`;
ADR-002 D3 via REV-006 (a big record may
import modules of its own, for `desktop.core`). `hosts.nix` gains only the
aarch64 base coverage target; its factories do not change (DEC-027). POL-001 governs what the moved files may carry.

## Risks and assumptions

- **Ordering.** Moving imports reorders merged lists
  (`mem.fact.nix.merge-order`) and can flip a `systemPackages` collision
  winner (`mem.fact.nix.systempath-collision-first-wins`). Gate with
  `just drvs` / `drvs-sets` / `just probe` (`mem.pattern.flakes.drv-gate`);
  pin with `mkBefore`/`mkAfter`/`hiPrio` where order is semantic.
- **Base too fat.** A base that drags desktop or Sleipnir-only pieces makes
  `nixosvm` (headless, aarch64) pay for them; a too-thin base duplicates
  imports across hosts. Classification is judged against W7's needs.
- Assumes the SL-005/SL-006 gate method and `just probe` carry over
  unchanged; IMP-019 (probe pin, `.manpath`) may bite again.

## Verification / closure intent

- Structural phases: Sleipnir system drvs identical or proven
  ordering-only; probe (packages, groups, link maps) identical;
  `just coverage` evaluates every off feature and the aarch64 base
  target; one negative control per newly-featured module; `just gate` green.
- Behaviour-change phase: probe diff equals exactly the listed changes.
- At close: every `modules/nixos/*.nix` is base (or parked), and every other
  piece is a feature, machine config or Sleipnir host config; the base is
  named in one place; RFC-001 W4 and IMP-004 updated; REV-006 applied;
  DEC-024's consequences refreshed (the workstation profile is Linux-only).

## Summary

## Follow-Ups

- IMP-022 — oom tuning per host.
- CHR-014 — i2c investigation.
- IMP-002 — retargets `hosts/Sleipnir/dns.nix` (DEC-029).
