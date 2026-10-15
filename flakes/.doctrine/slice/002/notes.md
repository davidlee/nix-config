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

## PHASE-01 execution (2026-10-15)

Baseline and after-captures: `.doctrine/state/slice/002/{baseline,after}/`
(runtime). Inputs held: oubliette 1a27efc6 (dirty), flake.lock sha
528ed051 (user's uncommitted edit) unchanged throughout.

- **Red**: with the tree entry in place and no selection, `just test` failed
  on `testSleipnirSelectsCapsule` with `[false false]`, an assertion failure,
  not an eval error. **Green** after the selection line.
- **Mutation**: selection line commented out → red `[false false]`; restored.
- **Gate**: `just drvs` differs only in `nixosConfigurations.Sleipnir`;
  home and darwin identical. `just drvs-sets` identical. Sleipnir's sudoers
  differs only by the rtcwake rule and the nft rule changing places (design
  sec-4). nix-diff of the two toplevels: the only differing leaf is
  `activate → etc → sudoers → sudoers-in`.
- **Negative control** (`feature.virt.capsule.enable = false`, reverted):
  the toplevel drvPath evaluates; sudoers has 0 `capsule-forward` lines;
  `firewall.interfaces ? "vm-capsule"`, `nftables.tables ? capsule-forward`,
  `users.users ? assigner` and `services ? capsule-perimeter` are all false.
- **Hygiene**: `nix fmt` changed nothing; deadnix and statix are clean on the
  touched files; no repo path names `modules/nixos/capsule.nix`.
- An extra comment in `features/virt/capsule.nix` explains why the sudo rule
  is at plain priority (the design said only that there is no `mkAfter`).
- **VT**: `verify-vt 2` reports VT-1..5 UNATTRIBUTABLE: the files are
  git-root-relative (ISS-005). Judged by agent instead: every keyword is
  present, and every file is in 9b5dbf79 / 5f672bdb.
- **Two commits**: 9b5dbf79 is the pure move, with Sleipnir importing the
  new path, so `git log --follow` reaches capsule's earlier history.
  Absorbing the pieces more than doubles the file, which drops git's rename
  similarity below 50%, so a single commit would have cut that history.
  5f672bdb wires the feature. HEAD's `just drvs` matches the gated capture.
- `.doctrine/doctrine.toml` gained `[reservation] allow-local-fallback` while
  the work was running, from outside this session. It is left uncommitted:
  the user's call.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-15 · closed (done) · DEC-010..014 accepted

### Produced
- SL-002 scope, design (sec-1..6) and RV-004; RFC-001 W1 is now designed
- minted: CHR-011 — repoint the ADR citations of MULTIHOST.md
- out-of-repo follow-up: `~/dev/oubliette/README.md:242` names the old capsule path
- PHASE-01: feature.virt.capsule (9b5dbf79 move, 5f672bdb wiring); plan 18bb8bcf/c1ce8759
- minted: CHR-012 — one file per feature (snooze fold, ADR-002 D3)
- RV-005 — SL-002 audit: 4 findings (F-1/F-2 tolerated, ISS-005/CHR-010; F-3/F-4 aligned); brief: settle DEC-010..014, no REV
- accepted: DEC-010..014 (reconcile, RV-005); slice closed 5d310c7c

### Learned
- mem.fact.nix.sudo-rule-order — plain extraRules always follow nixpkgs' root/wheel rules
- mem_01a13da6b8d075b49d87683632a39b43 — id-minting hang variant: SSH via port 443 + BatchMode

### Open
- CHR-012 — follow-up before the next slice (W2): snooze to one file; tighten ADR-002 D3
- HYP-001 — composition slot (ADR-004 D2–D3) not exercised here; carried to RFC-001 W2/W3
