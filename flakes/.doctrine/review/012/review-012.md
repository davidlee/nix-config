# Review RV-012 — reconciliation of SL-005

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

<!-- Pre-reading + lines of attack: what this review is probing, the invariants
     it must hold the subject to, and where the bodies are likely buried. Seeded
     at `review new`; the reviewer fills it before raising findings. -->

Mode: conformance, self-audit. Surface: primary tree (`$HOME` worktree),
slice range a2b08b34..a547c452 (four phase commits 715e4012, adc48563,
acb8a403, 3459aa1c).

Lines of attack:
- Identity: every commit leaves Sleipnir's derivations unchanged or
  explained by its design sec-7 row (podman's removal the only behaviour
  change, DEC-022). Evidence: notes.md `## PHASE-0N`, snapshots under
  `~/.cache/multihost-gate/sl005/`.
- Completeness vs scope and design sec-6: six legacy flags gone, no reads
  remain, every listed file touched, nothing unlisted touched.
- Invariants held: rootless-only docker (security.nix assertion);
  docker/podman exclusivity; ADR-005 coverage for the unselected feature;
  ADR-002 D5 area order (appended).
- Design-text truth: where execution showed the design's prose wrong
  (distrobox, closure claims), canon must be corrected.
- Downstream governance: RFC-001 wording (DEC-019 machine config), backlog
  notes promised in design sec-8.
- Conformance algebra (`doctrine slice conformance 5`) read by hand: the
  `flakes/` prefix misattributes every path (ISS-005).

## Synthesis

**Closure story.** SL-005 retired six legacy flags in four commits, each
gated against the one before it (`mem.pattern.flakes.drv-gate`):

```
PHASE-01 hardware → hosts/Sleipnir/machine.nix   kernelParams order only
PHASE-02 qemu, docker → features/virt.nix         order only; groups explained
PHASE-03 podman → off feature (DEC-022)           podman removed; the one behaviour change
PHASE-04 appimage, flatpak → non-nix-packages     2 duplicate entries gone
```

At every step, home, Draupnir, packages, legacyPackages and templates were
unchanged; Sleipnir's sorted package set, groups, kernelParams, root
options and system-path link map matched the design's row exactly. Negative
controls proved each migrated feature is its own switch; guards proved the
rootless-only and docker/podman-exclusive assertions fire. `just gate` and
`doctrine check gate` green at a547c452. No `features.{hardware,virt}` or
`features.apps.{appimage,flatpak}` reads remain.

**Findings.** Six, none blocking. All are text lagging verified behaviour:
two design-prose corrections (F-2 distrobox, F-3 flatpak closure wording),
a selector-registry gap (F-1), RFC-001 wording behind DEC-019 (F-4), backlog
notes the design deferred to reconcile (F-5), and the known ISS-005 tooling
defect (F-6). No code finding: a whole-slice diff read found only verbatim
moves plus the planned assertions and group edits.

**Standing risks.**
- Tree features default off; legacy `virt.qemu` / `apps.*` defaulted on. A
  new NixOS host without `workstation` gets none of them (design sec-5,
  intended; first hit likely W7's nixosvm).
- Sleipnir now has no podman. Restoring it is IMP-018's selection swap,
  not a revert.
- Docker's `enable = false; # security yo` survives inside the feature
  alongside the new assertion: redundant but harmless; left as a verbatim
  move.

**Tradeoffs accepted.** Per-phase code reviews were skipped (verbatim moves,
gate-proven); this audit's diff read stands in for them. Conformance was
read by hand because of ISS-005.

## Reconciliation Brief

### Per-slice (direct edit)
- F-1 — selector registry: `doctrine slice selector add 5 hosts.nix` with
  intent design-target (load-bearing; design.md sec-6 already lists it).
- F-2 — design.md sec-3 (podman bullet) and sec-7 (podman row): distrobox
  also reaches system-path via `modules/nixos/cli.nix` (dev.nix through
  linuxSystem), so it stays in system-path and home; the removed set is
  podman.nix's list less distrobox plus the module's two.
- F-3 — design.md sec-7 check 4, flatpak bullet: "absent from system-path";
  note flatpak stays in the drv closure as a library of plasma-workspace and
  xdg-desktop-portal. Do not edit plan.toml EX-5 (immutable); notes.md
  `## PHASE-04` carries the qualification.
- F-5 — backlog bodies: IMP-003 gains "SL-005: docker and libvirtd done
  (libvirtd now added by virt.qemu; rootless docker needs no group).
  `dev`, `caddy`, `jackaudio` in user.nix name groups absent on Sleipnir."
  IMP-006 gains "W3 slices discharge it incrementally: tree features
  default off (SL-005 sec-5)." Both stay open.

### Governance/spec (REV)
- F-4 — RFC-001: Target shape tree `config.nix` line to name machine config
  (`machine.nix`, DEC-019); W4 row's class "Sleipnir hardware" → "machine
  config"; W7 row "hand-written `hardware.nix`" → `machine.nix`; W3 row
  records SL-005 (hardware → machine config, virt, app formats).
