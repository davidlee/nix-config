# Notes SL-010: Base tidy: optional pieces out of modules/ (RFC-001 W9)

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: <yyyy-mm-dd> · <PHASE-NN | stage> · <head-commit>

### Produced

### Learned

### Open

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
