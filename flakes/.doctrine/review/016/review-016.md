# Review RV-016 — reconciliation of SL-007

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

Conformance audit of SL-007 (NixOS base / host split), PHASE-01–06, commits
0a7458d5..9fe49432 in the main worktree (capsule-driver run; no dispatch
candidate surface). Lines of attack:

1. **Classification invariant** (design § Shape, DEC-027): every NixOS piece in
   exactly one of base / feature / machine / host. `modules/nixos/` holds only
   `default.nix`, its 16 imports and the two parked files; no base module reads
   the feature selection (ADR-001).
2. **Configuration identity** for P1–P5 (design § Phases and verification): each
   phase's gate diff within its allowed row; order-only diffs proven by nix-diff.
   Evidence: orchestrator hand-backs, `notes.md` Gate snapshots,
   `~/.cache/multihost-gate/sl007/*`.
3. **P6 behaviour changes** equal exactly the design § Behaviour changes table;
   kernel `.config` identity before dropping the Rust patch.
4. **Governance**: REV-006 approved and applied to ADR-002 D3 with the README
   own-file rule worded the same; POL-001 (no new private identifiers);
   design § Code impact "governance at close" obligations.
5. **Scope**: `doctrine slice conformance` undeclared/undelivered leads
   (read through ISS-005's `flakes/` prefix misattribution).
6. **Mechanical checks re-run by the auditor**: `just gate` (exit 0),
   `doctrine slice verify-vt` (all keywords present), the design close grep
   (no hits), `ls modules/nixos`, the VA-4 removal grep.

## Synthesis

**Closure story.** SL-007 delivered the four-class split the design drew. The
base is `modules/nixos/default.nix` (16 imports, DEC-027); `modules/nixos/`
holds only it, its imports and the two parked files. Machine-bound pieces sit
in `hosts/Sleipnir/machine.nix` and site, account and tuning pieces sit beside
`config.nix` (`dns.nix`, `oom.nix`). Everything optional is a feature: the new
`desktop.core` and `desktop.greeter`, the `compositor` and `shell` areas,
`audio.pipewire`, four `hardware.*` records and `services.postgresql`. P1–P5
preserved Sleipnir's configuration. Every gate diff was within its phase's
row, and each order-only diff was proven with nix-diff and sorted `__json`
comparisons. P6 applied exactly the behaviour table: Sleipnir's package set
went from 570 to 565, and the kernel `.config` was byte-identical with and
without the Rust patch, so dropping it gives the cached `linuxPackages_latest`.
REV-006 was approved by the user and applied, so ADR-002 D3 and the README's
own-file rule now say the same thing. The auditor re-ran `just gate` (exit 0),
`verify-vt` (every keyword present), the design close grep (no hits) and the
VA-4 removal grep.

**Findings.** None blocks closure. One code finding was fixed during the audit
(F-1, a comment). Three are reconcile writes (F-2 design §7 wording, F-5
selectors, F-6 governance). F-3 is aligned, and F-4 belongs to ISS-005.

**Standing risks.**
- The mechanical conformance and VT attribution signals are blind in this
  repo until ISS-005 is fixed. This audit read them by hand.
- `compositor.cosmic` hides two negative controls (it turns on rtkit and
  bluetooth upstream). This was accepted in the design, pending cosmic's
  removal.
- `hosts/Sleipnir/oom.nix` names this host's UID and compositors (IMP-022).
- `dns.nix` holds a Private profile hostname until IMP-002 replaces it.

**Tradeoffs accepted.**
- Order of merged lists is not preserved, a deliberate deviation from
  ADR-002 D5 that every phase's gate proved harmless.
- Evidence for the `dev` group and the duplicate ports is option-level only,
  because neither leaves a trace in the build (F-2).

## Reconciliation Brief

### Per-slice (direct edit)
- **F-2 — design.md § Behaviour changes**, "expected effect" column:
  - postgresql row: "`allowedTCPPorts` loses the duplicates at option level;
    the rendered nftables ruleset is unchanged (NixOS deduplicates)".
  - dev row: "option-level only: `extraGroups` loses `dev`; the group never
    existed, so no build artefact changes".
- **F-5 — selector registry (the change that matters):**
  `doctrine slice selector add SL-007` with `SATAN.md` and
  `modules/home/linux/sleipnir-doctor.nix` as `design-target` (pointer
  updates for moved files). Mirror both in design.md § Code impact.

### Governance/spec (REV)
- **F-6 — RFC-001:** W4 row → done. W5 note: follow the base pattern
  (DEC-027: an import list, not a feature or a profile).
- **F-6 — DEC-016:** choice text drops `features` from
  `specialArgs = {inputs username hostname features}`. Selection is resolved
  outside the evaluations (ADR-001), so there is no `features` argument.
- **F-6 — DEC-024:** consequences refreshed. A host importing `workstation`
  now also gets `desktop.core` and `audio.pipewire`, both NixOS-only, so the
  profile is Linux-only (ADR-005 D6). Replace "fonts and dictate only".
- **F-6 — IMP-004:** status → done at `/close` (the prune landed in
  PHASE-06, commit 9fe49432).
