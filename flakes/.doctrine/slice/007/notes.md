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

## Review passes (2026-10-16)

RV-015: agent self-pass, 4 findings (F-1..F-4), all fixed and verified.
A further hostile pass would probe: negative-control signatures that another
module also sets (rtkit, bluetooth, portals under cosmic/kde), so a control
passes vacuously; aarch64 breakers beyond cpuid/x86info in the base closure;
the record-imports-modules form for desktop.core against ADR-002 D1/D7 and
the README "own file" rule; and what config.nix still imports flat during
P1–P4 (interim states the phase table does not draw).

RV-015 second pass (run rev 36→38): agent pass on those probes (F-12..F-14)
plus a user-relayed external agent pass (F-6..F-11, F-15). F-6 (major):
user chose to revise ADR-002 D3 → REV-006 (proposed, applied in P3). F-15
contested (drvs-sets counts duplicates). Concluded; all verified.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-16 · design locked (run rev 40); plan PHASE-01..06, slice ready · d3d90c6b

### Produced
- DEC-026 (taxonomy; amended: greeter has no requires, host defaultSession), DEC-027 (NixOS base), DEC-028 (placement), DEC-029 (ControlD DNS → hosts/Sleipnir/dns.nix, POL-001)
- design.md (sec-1..9); RV-015 (two passes: F-1..F-5, F-6..F-15)
- REV-006 (ADR-002 D3: big record may import its own modules; SL-007 related)
- plan.toml / plan.md (PHASE-01..06); ASM-001 (aarch64 eval suffices for W4)
- IMP-016 note: candidate `gui` area (user)
- SL-007 governed_by POL-001; references IMP-002
- RFC-001 updated (W3 done, W4 next); IMP-022 (oom per host), CHR-014 (i2c)
- research/research.md (gitignored)

### Learned
- nixpkgs enables kernel Rust by default ≥ 6.12 on x86_64/aarch64 (`rustByDefault`,
  kernel/common-config.nix); a `features.rust` kernelPatch only forces a custom
  (uncached) kernel build. Candidate memory after P6 verifies it.
- `services.displayManager.defaultSession` is asserted against installed session
  names (nixpkgs display-managers/default.nix:196); noctalia-greeter does not read it.
  Any negative control that deselects the named compositor must null it.
- nixpkgs cosmic.nix enables bluetooth, avahi (mkDefault) and rtkit, so those
  feature switches leak while cosmic is selected.
- `drvs-sets` counts list entries including duplicates (justfile `_drvs`).

### Open
- Next: /phase-plan PHASE-01 (baseline capture first)
- IMP-004 (prune, P6), IMP-017, IMP-002, IMP-003, ISS-008, QUE-001, QUE-004
