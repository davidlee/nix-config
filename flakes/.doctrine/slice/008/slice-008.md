# Home base / personal split (RFC-001 W5)

## Context

RFC-001 W5 (MULTIHOST S5). SL-007 (W4) classified the NixOS side into base,
feature, machine config and host config. The home side is still flat:

```
today                                         target (shape settled in design)
hosts/Sleipnir/home.nix                       hosts/Sleipnir/home.nix
  ├─ profiles/linux-desktop.nix  (a bundle)     ├─ <home base>          every home
  │    ├─ modules/home/shared/*                 └─ identity + host-only bits
  │    └─ modules/home/linux/*   (GUI apps,     features/<area>.nix     homeManager halves:
  │                              alarm, …)        linux desktop apps, personal tools
  ├─ satan, satan-patcher, satan-attrd,         features/profiles/personal.nix
  │  behaviour, nudge, goad, walker,              selects the personal features
  │  sleipnir-doctor, eca, chatgpt              hosts/Sleipnir/features.nix
  └─ modules/home/shared/cli.nix                  imports personal (+ workstation)
darwin/home.nix  (Draupnir's home base)       darwin home base on the same pattern
```

Why now: W7 (`nixosvm`, a headless aarch64 guest) needs a home that is
"the base" and nothing more, and must never reach the local-path inputs
(panopticon, satan-patcher, satan-attrd, goad; RFC-001 § Local-path
inputs). Today a home without the personal modules cannot be written down.

`profiles/linux-desktop.nix` is an import bundle named "profile". RFC-001
reserves "profile" for `features/profiles/*` (modules that select features);
a bundle is a *base*. It goes.

Precedent: SL-007 — DEC-027 (the base is a plain import list, imported by
the host, no switch, no factory change), DEC-028 (placement), DEC-024
(profile vs host selection), ADR-002 D3 / REV-006 (a record may import
modules it owns), and its gate and phase pattern (design.md § Phases and
verification).

## Scope & Objectives

Settled in design (2026-10-16):
- DEC-030: platform scope.
- DEC-031: home base.
- DEC-032: feature taxonomy by function. Settles IMP-016.
- DEC-033: personal profiles and features.
- DEC-034: home verification.
- DEC-035: ADR-002 D5 wording.
- DEC-036: cli packages filtered by availability.

1. **Platform scope** (DEC-030; answers QUE-001).
   - A feature record may carry `platforms`: a list of system strings, in the
     `meta.platforms` style.
   - The resolver receives the host's `system` and refuses a selected
     feature that does not support it.
   - Governance changes: REVs on ADR-002 (D1, D4, and D5 per DEC-035) and on
     ADR-005 D6. DEC-006 is edited.
2. **Home base** (DEC-031).
   - `modules/home/default.nix` is the base. It holds the shells, shpool,
     home-manager, and the base cli: the shell-ux and zsh buckets plus core
     userland, git and gnupg included.
   - Two platform layers, `modules/home/linux/default.nix` and
     `modules/home/darwin/default.nix`, each import the base. Each host's
     `home.nix` imports one layer.
   - `profiles/` and `darwin/home.nix` are removed.
3. **Features by function** (DEC-032).
   - Every remaining home module and every `modules/shared/cli/_packages`
     file becomes a feature in a functional area: editor, notes, dev, docs,
     data, files, net, web, system, text, security, media, graphics, comms,
     fun, terminal, and ai (claude-desktop).
   - `apps.cad` becomes `graphics.cad`.
   - `desktop.core` gains a home half for the ISS-008 items:
     tailscale-systray, swaybg, systembus-notify.
   - walker becomes `shell.walker`.
4. **Personal** (DEC-033).
   - New areas `satan` and `attention`, plus `audio.alarm`.
   - Three profiles: `personal` (portable: the editors and the cli
     features), `personal-linux` and `personal-darwin`.
   - Sleipnir imports `personal-linux`. Draupnir gains a `features.nix`
     that imports `personal-darwin`.
   - sleipnir-doctor becomes Sleipnir host config.
   - New `requires` edges:
     - `satan.patcher` and `satan.attrd` → `services.postgresql`;
     - `satan.harness` → `editor.emacs`.
5. **Verification** (DEC-034).
   - A new target, `coverage."home@aarch64-linux"`, and `just coverage`
     learns to handle home targets.
   - A committed isolation check: the local inputs are overridden to a stub
     flake.
   - Resolver tests for platforms, the profiles, and Draupnir's selection.
6. **Behaviour phase** (DEC-036 and others).
   - cli package lists are filtered with `lib.meta.availableOn`, plus an
     explicit `brokenOn` list. Draupnir gains packages.
   - The NixOS `isx86` guards are replaced the same way.
   - The doctor pins its Python interpreter.
   - `break-remind` is deleted.
7. **Docs.** Update the README, the RFC-001 W5 row, DEC-024's darwin
   consequence, and the comment in `workstation.nix`.

**Identity.** Through the migration phases, both hosts keep their effective
selection and their packages. Only list order may change, and the gate must
prove each reorder harmless. Content changes happen only in the behaviour
phase. Phasing is in design.md.

## Non-Goals

- **Agents (W2).** `eca.nix`, `chatgpt.nix`, the agents overlay and
  `registry.agents` stay where they are. The two files are the named
  exception to "`modules/home` holds only the base".
- **goad on darwin** (IMP-023): the launchd half and an input the Mac can
  fetch.
- **Headless concerns (W7).** W7 creates `headless.nix` if it needs one. The
  emacs flavour for a headless guest is W7's too: nox, `EDITOR` over SSH, the
  aarch64 cache.
- **The NixOS `linuxSystem` cli bucket** stays in the NixOS base. Only its
  guards change.
- **Local overrides and the lock**: ISS-003, ISS-006, IDE-002 (W6 / W8).
- **ISS-007**: both atuin workarounds are kept.
- **Other open items**: ISS-002 (the doctor's panopticon source), IMP-003,
  IMP-022, IMP-006.
- **W9**: per-host overlays, and the doctor's name.

## Open questions

OQ-1..OQ-7 were resolved in design, as inq-1..12 of the design run and
DEC-030..036.

## Risks / assumptions

- Feature halves append after host modules (DEC-007): moving home modules
  into features reorders merged lists. Accepted per phase via the gate, as
  in SL-006/SL-007 (deviation from ADR-002 D5).
- Home and darwin drv lines move with `emacs-overlay` re-resolution: take
  baseline and after-snapshots close together (RFC-001 working rules).
- New files invisible until `git add -N` (`mem.fact.flakes.git-add-n`).
- `hosts/Draupnir` cannot be switched from here; darwin changes are
  evaluation-checked only (drvs gate), switched later by the user.
- HYP-001 (resolver suffices) gets another data point; record at close.

## Verification / closure intent

- Per phase: `just drvs`, `drvs-sets`, `probe`, `coverage`, `gate`, each
  compared with the previous phase; ordering-only diffs proven by probe /
  `nix-diff`; collision-winner flips → stop and `/consult`.
- Resolver tests (`features-test.nix`) red first for each new feature and
  for the personal profile's selection.
- Negative controls (one-off): deselecting each new feature removes its
  signature from the closure (not just the option).
- Close: `profiles/` gone; every `modules/home/**` file is in the base, a
  feature, host config or parked; the home base target evaluates on
  aarch64-linux; the isolation check passes; `just gate` green; README and
  RFC-001 current.

## Summary

## Follow-Ups
