# Notes SL-010: Base tidy: optional pieces out of modules/ (RFC-001 W9)

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-17 · ready (pre-PHASE-01) · 6f4b21c0

### Produced
- DEC-042, DEC-043, DEC-044 (accepted; shape SL-010)
- RV-022 (design review pass; adversarial lane waived)
- design.md (locked r32), plan.toml PHASE-01..05

### Learned
- HM tailscale-systray is PartOf/WantedBy graphical-session.target (inert headless)
- Draupnir logs straight into nu (user chsh'd); darwin layer PATH block is live

### Open
- IMP-001 closes with PHASE-04
- PHASE-04 VH-1 (user, after switch)

## Design triage (2026-10-17)

Source: research/research.md (threads 1–2, X1–X5, D-a..D-f).

**Settled by the user (2026-10-17):** option 1 (optional pieces only; base
stays); parked modules move to `parked/` at the flake root, incl. shpool
(IMP-001); OQ-1 cli.nix split as proposed; OQ-2 avahi feature required by
`services.printing`; OQ-4 nix-ld stays base. darwin/ out of scope.

**Open shaping questions** (design inquiries):
- system packages → nixos halves of existing features vs home packages (X1)
- tailscale tray placement once tailscale leaves the base (X2)
- rust-motd and root's helix: stay base? (D-d)
- name/selection of the sandbox record (bubblewrap, distrobox)
- sysprof placement; nix-search-tv option placement (X4)
- one DEC amending DEC-027 + DEC-031 (D-f)

**Risks:** drv identity (ordering diffs need proof); Sleipnir must select
avahi explicitly (requires never auto-selects); dns.nix depends on avahi.

**Assumptions:** HM's tailscale-systray unit is bound to the graphical
session, so it is inert headless (verify in design).

**Constraining governance:** DEC-027, DEC-031, ADR-001 D4, ADR-002, ADR-005,
DEC-030; RFC-001 working rules.

## PHASE-01 baseline (EN-2)

Date 2026-10-17; tree HEAD 18f3142c5b1aca3762a345f70b0c433b7eafbce0.
justfile/pi settings.json user edits present, not staged.

| checkout | HEAD | porcelain -uno |
|---|---|---|
| oubliette | 63cc360b9c42aa4e531f4bccd53a46ff48f14eae | clean |
| goad | 250b8ed9cf6f4cda9879fc45b2b3ceb2d52ea987 | clean |
| panopticon | a6648a46e4f8de08f9d841163f1bb30c5750581d | clean |
| satan-patcher | 4efa20542b77d4aad83079da267121a38b08e94f | clean |
| satan-attrd | c8fd7eb51aeada64571270c98f94a30fb7337036 | clean |

Evidence:
- .doctrine/slice/010/evidence/p1-drvs-before.txt sha256 6fd1affde81c482449cc094a02c3e1d8f230c7e1ee3334d7501e7c53d5124175
- .doctrine/slice/010/evidence/p1-drvs-sets-before.txt sha256 52d35a0652b852e4b26abca6fc9c14de951c5670c3068f2051eab8be476493ba

## PHASE-01 result

- Checkout HEADs/status after: identical to baseline.
- drvs diff: empty (sha256 6fd1affd... identical). drvs-sets diff: empty (52d35a06... identical). Evidence: evidence/p1-drvs-after.txt, p1-drvs-sets-after.txt.
- just test: green. just coverage (incl. isolation): green. flake.lock: no diff.
- VA-1: modules/home/linux holds only default.nix; modules/nixos has no hyprland/kmscon; modules/treefmt.nix.txt absent; git ls-files parked = hyprland.nix, kmscon.nix. Stale-reference grep (non-.doctrine): empty.
- Changed paths: R modules/nixos/{hyprland,kmscon}.nix -> parked/; D modules/home/linux/{helix,slk,bough}.nix, modules/treefmt.nix.txt; M modules/home/linux/default.nix, hosts/Sleipnir/config.nix, .doctrine/slice/010/notes.md; optional evidence/p1-*.txt.
