# SL-007 notes

## Design triage (2026-10-16)

Evidence: `research/research.md` (✓ rows load-bearing).

**Organising principle** (user, 2026-10-16): the structure of options (and
so of files) is the most important interface. A thing is its own feature
when it is cohesive and one would plausibly switch it on or off
independently; the taxonomy must make IA sense — limited depth, roughly
consistent granularity.

**Constraining governance**: ADR-001 D1–D7, ADR-002 D1/D5/D7, ADR-004 D1–D3,
ADR-005, DEC-004, DEC-005, DEC-007, DEC-011, DEC-015, DEC-016, DEC-019,
DEC-021, DEC-023, DEC-024, DEC-025; memories `mem.pattern.flakes.drv-gate`,
`mem.fact.nix.merge-order`, `mem.fact.nix.systempath-collision-first-wins`,
`mem.fact.nix.sudo-rule-order`, `mem.fact.nix.verify-closure-not-option`,
`mem.fact.flakes.git-add-n`.

**Shaping decisions to make**: base shape/name/content; desktop foundation
granularity; hardware placement (incl. radeon); audio foundation; services
and apps placement (postgresql, avahi, 1Password, dev libs); host / machine /
site split (network, nix tuning, stateVersion, kernel patch, swapfile,
rtcwake); base verification on aarch64; defects with the IMP-004 prune;
phasing.

**Risks**: merged-list reorders and `systemPackages` collision flips
(13 duplicates listed in research); a fat base; aarch64 eval breakers in
base candidates (cpuid, x86info, Rust kernel patch).

**Assumptions**: SL-006 gate + `just probe` carry over; W7 is headless
aarch64 under UTM.

**Open questions**: as above; QUE-004 stays W7's.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-16 · design inquiring (rev 13, all inquiries resolved) · 8d8ed761 + this commit

### Produced
- DEC-026 (desktop/compositor/shell taxonomy), DEC-027 (NixOS base), DEC-028 (placement)
- RFC-001 updated (W3 done, W4 next); IMP-022 (oom per host), CHR-014 (i2c)
- research/research.md (gitignored)

### Learned
- nixpkgs enables kernel Rust by default ≥ 6.12 on x86_64/aarch64 (`rustByDefault`,
  kernel/common-config.nix); a `features.rust` kernelPatch only forces a custom
  (uncached) kernel build. Candidate memory after P6 verifies it.

### Open
- IMP-004 (prune, P6), IMP-017, IMP-002, IMP-003, ISS-008, QUE-001, QUE-004
