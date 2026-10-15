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

1. **Classify** each module in `modules/nixos/` (and each import in
   `hosts/Sleipnir/config.nix`) as one of:
   - **base** — every NixOS host (candidates: `nix`, `user`, `ssh`, `cli`,
     `locate`, `maintenance`, `lib`, `util`, `security`, `env`, `boot`?,
     `kernel`?, `network` base, `oom`);
   - **feature** — optional, selected per host (candidates: the
     desktop-shared modules `wayland`, `wayland_packages`, `greeter`, `qt`,
     `x11`, `xdg`, `keyring`, `umbriel`, `audio`, `bluetooth`, `avahi`,
     `keyboard`; `1password`; `postgresql`);
   - **machine config** — bound to Sleipnir's parts, into
     `hosts/Sleipnir/machine.nix` (DEC-019) (candidates: `radeon`,
     `network`'s `enp8s0` profile);
   - **Sleipnir-only** — host-specific but not hardware.
   The candidate lists are a starting point; design settles each one.
2. **Express the base** — decide its shape (one import list per kind, a
   module, or other). An open question in RFC-001 that also shapes W5.
3. **Split mixed modules**: `programs.nix` (nix-ld libraries, 1Password,
   thunar, foot, zsh, rust-motd, dconf), `1password.nix` (CLI vs GUI and its
   browser list), `network.nix` (base vs the `enp8s0` profile), and any
   others classification turns up.
4. **Move** the optional modules onto the feature tree (DEC-015 shape),
   selected by Sleipnir through profiles or `hosts/Sleipnir/features.nix`
   (DEC-024), so Sleipnir's effective selection is unchanged.
5. **IMP-004 prune** (a behaviour change, its own phase, not set-preserving):
   drop entries nothing uses from `wayland_packages.nix` — `wob`,
   `i3status`, `wf-config`, `gnomeExtensions.appindicator`,
   `marble-shell-theme` — and the duplicate `sway-easyfocus` in
   `features/desktop/sway.nix` (RV-014 F-5). Design confirms each is unused.
6. README: host/base/feature description and tree listing updated.

## Non-Goals

- Home side: home base / personal split is W5.
- Agents (`registry.agents`, overlay) are W2; `nix.nix` keeps the registry
  until then.
- Per-host overlays into their features (W9), unless design finds the move
  falls out of a module it already touches.
- Lean default selection (IMP-006); new hosts (W7).
- Desktop behaviour: ISS-001, IMP-005, ISS-008 (CPT-001).
- Parked modules (`hyprland`, `kmscon`) stay parked.

## Affected surface

`modules/nixos/**`, `hosts/Sleipnir/{config,machine,features}.nix`,
`features/**` (new areas or records), `features/profiles/**`, `hosts.nix`
(if the base is injected by the factory), `features-test.nix`, `README.md`.

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
  `just coverage` evaluates every off feature; one negative control per
  newly-featured module; `just gate` green.
- IMP-004 phase: probe diff equals exactly the pruned packages.
- At close: every `modules/nixos/*.nix` is base, feature, machine config or
  Sleipnir-only, and the base is named in one place; RFC-001 W4 updated.

## Summary

## Follow-Ups
