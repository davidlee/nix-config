# Notes SL-002: Capsule onto the feature tree

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Origin

RFC-001 W1. Scoped, researched and designed on 2026-10-15, in the same
session that closed SL-001 and retired MULTIHOST.md (d2b787b5).

- Research: `research/research.md` (runtime, gitignored). Both threads were
  run by the orchestrator; the project defines no research agents.
- Design run `dr-01a13e3f…`, locked at revision 35. The adversarial pass
  RV-004 (a fresh subagent) evaluated the design's edits in a scratch copy:
  - only `sudoers-in` differs, by the sec-4 swap;
  - the new test fails then passes as specified;
  - the negative control is clean.

  Five minor findings, all fixed.
- The run reports RV-004 as STALE. The pass was concluded before the fixes
  were redeclared, and the user disposed it as conducted.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-15 · design locked · d2b787b5 (+ the SL-002 design commit after it)

### Produced
- SL-002 scope, design (sec-1..6) and RV-004; RFC-001 W1 is now designed
- minted: CHR-011 — repoint the ADR citations of MULTIHOST.md
- out-of-repo follow-up: `~/dev/oubliette/README.md:242` names the old capsule path

### Learned
- mem.fact.nix.sudo-rule-order — plain extraRules always follow nixpkgs' root/wheel rules
- mem_01a13da6b8d075b49d87683632a39b43 — id-minting hang variant: SSH via port 443 + BatchMode

### Open
- DEC-010 — feature.virt.capsule, single file, virt appended
- DEC-011 — Sleipnir selects it in its own features.nix
- DEC-012 — ownership of the four pieces; nftables.enable stays host-wide
- DEC-013 — sudo rule at plain priority
- DEC-014 — verification: real-tree test, drv gate, one-off negative control
- CHR-012 — follow-up before the next slice (W2): snooze to one file; tighten ADR-002 D3
- HYP-001 — composition slot (ADR-004 D2–D3) not exercised here; carried to RFC-001 W2/W3
