# Review RV-010 — reconciliation of SL-004

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

<!-- Pre-reading + lines of attack: what this review is probing, the invariants
     it must hold the subject to, and where the bodies are likely buried. Seeded
     at `review new`; the reviewer fills it before raising findings. -->

Mode: conformance (self-audit). Surface: primary tree (`~/flakes`, worktree
`$HOME`) at `256da104`; not a dispatched slice.

Lines of attack:

1. **Derivation identity** (the slice's main invariant): Sleipnir system and
   home, `packages`, `legacyPackages` probe and `templates` identical to the
   PHASE-01 baseline; darwin changes only by key/content; `david@Draupnir`
   new. Re-run `just drvs` and diff against `~/.cache/sl-004/baseline-drvs`
   and `p05-drvs`.
2. **The rule (DEC-016)**: every factory passes `args` + one injected module;
   no factory builds pkgs except mkHome's bare base; `stable` is a module
   argument only; `agentsOverlay` bound once.
3. **ISS-004 check is real**: `checks.factories` reads module `pkgs`, is
   non-vacuous, covers `classesOf`; RV-009 F-3 controls recorded.
4. **Standalone Draupnir home (DEC-017)**: host entry, darwin home base,
   embedded HM gone, backup policy kept, PATH hack.
5. **Activation and docs**: justfile per-OS flake ref, `hostname -s`, agents
   override everywhere; README cut-over matches what actually happened on
   Draupnir (PHASE-06).
6. **Conformance**: touched paths vs `design-target` selectors (judged by
   agent; the registry misattributes under the `flakes/` prefix, ISS-005).
7. **Design/governance drift**: design.md vs code; ADR-003, ADR-001,
   DEC-006/007, RFC-001 still describe embedded darwin HM.
8. **RV-009 instrument-routed findings** (F-1, F-3, F-4) and F-10 settled by
   phase evidence.

Evidence run in this audit: `just gate` green (resolver tests,
`checks.factories`, script tests, treefmt incl. statix/deadnix);
`just drvs` → `~/.cache/sl-004/audit-drvs`; `just coverage` evaluates.

## Synthesis

**Closure story.** SL-004 delivered what the design locked. The factories now
follow one rule (DEC-016): `args` (identity) plus one injected module;
nix-darwin and Home Manager build their own pkgs, so a darwin-module overlay
reaches module `pkgs` (ISS-004), proven by `checks.factories` against four
named wrong candidates (RV-009 F-3). Draupnir has a standalone home
(DEC-017, IMP-012) and the embedded block is gone. `stable` is a module
argument; `agentsOverlay` is bound once; `default.nix` is deleted; the drvs
gate covers `packages`, `legacyPackages` and `templates` (CHR-004).

```
hosts/<h>/meta.nix ─> args + platformModule ─> lib.nixosSystem / darwinSystem  (evaluator builds pkgs)
                  └─> args + homeModule     ─> homeManagerConfiguration       (bare nixpkgs-home base)
checks.factories: probe overlay → ? Draupnir → classesOf → david@Draupnir
```

The main invariant held: at `256da104`, `just drvs` is identical to the
PHASE-01 baseline for every Sleipnir output, `packages`, `legacyPackages` and
`templates`; darwin changed by key and content; `david@Draupnir` is new and
moved after PHASE-05 only by the ISS-007 atuin carve-out. `just gate` and
`just coverage` green. The cut-over ran on Draupnir and was user-confirmed.
RV-009 is now done (F-1, F-3, F-4, F-10 verified from phase evidence).

**Findings.** Eight, none blocking. Two fixed during the audit (F-1 lifecycle
status, F-4 README atuin line). Four are per-slice design drift for reconcile
(F-3 atuin carve-out, F-5 cut-over lessons, F-6 equivalent forms) plus the
planned governance REV (F-8). Two tolerated: F-2 (conformance registry
misattribution, ISS-005) and F-7 (cut-over ran out of order).

**Standing risks.**

- The documented manual step 2 (`nix-env --set` + `result-darwin/activate`)
  was never executed (F-7). Only matters for a second darwin cut-over.
- Every Mac evaluation depends on `agents_override` until ISS-006 is fixed.
- atuin is off on darwin in two places (ISS-007); restoring must undo both
  and README step 4.
- `just test`/`gate` cannot run on the Mac (IMP-015).
- ADR-005 D6 weaker on darwin: a Linux-only `homeManager` half selected on
  Draupnir is not refused (QUE-001).

**Tradeoffs accepted.** Mac userland now follows `nixpkgs-home` (same rev
today; drift accepted by the user). The staged rollback was replaced by the
real, unplanned one (F-7).

## Reconciliation Brief

### Per-slice (direct edit)

- **F-3** design.md sec-3 (Draupnir): add a bullet — atuin is off on darwin
  pending ISS-007: `programs.atuin.enable = lib.mkForce false` in
  `darwin/home.nix`, and atuin Linux-only in
  `modules/shared/cli/_packages/shell-ux.nix` `common` (position kept, Linux
  drvs unchanged). No selector change (ISS-007 owns shell-ux.nix).
- **F-5** design.md sec-4 (cut-over): `sudo darwin-rebuild
  --list-generations`; note that between steps 2 and 3 nothing provides `nu`
  and `/etc/profiles/per-user/david/bin/nu` is gone, so terminals started
  earlier must be relaunched and the login hook must resolve nu by PATH
  (`command -v nu >/dev/null && exec -l nu`); step 4 drops atuin. Mirror
  README § Bootstrap macOS.
- **F-6** design.md sec-2 item 5: `homeModule = system: …`; item 6:
  `classesOf = meta: [meta.kind] ++ lib.optional (meta.home or false)
  "homeManager"` (kind values are the class names); sec-4 drvs
  `legacyPackages` pick guards `lp ? stdenv` (aarch64-darwin key is empty).

### Governance/spec (REV)

- **F-8** one REV:
  - ADR-003 §Context/§Decision: both platforms run Home Manager standalone,
    separate pins and activation; remove "on Linux", "Darwin continues to
    embed Home Manager", and the REV-001 paragraph on embedded darwin HM
    receiving no projection.
  - ADR-001 §Context: three evaluations per host, standalone Home Manager on
    both platforms.

### Other records (direct edit at reconcile)

- **F-8** DEC-006, DEC-007 wording ("or darwin" → darwin [+ homeManager];
  drop "no embedded-HM hook"). DEC-001 unchanged (DEC-017 already replaces
  its deferral consequence).
- **F-8** RFC-001: where-things-stand diagram; W5 unblocked, citation RV-001
  F-7; W8 (ISS-004, IMP-012 done); W9 (CHR-003 done).
- **F-8** IMP-010: drop the obsolete darwin `home` remark.
- DEC-016 consequences: the homeModule gate passed (PHASE-04, drvs identical); drop the fallback as live, record the outcome.

### At close (not reconcile)

- Resolve IMP-012, ISS-004, CHR-003, IMP-009, CHR-004. ISS-005, ISS-006,
  ISS-007, IMP-014, IMP-015, QUE-001 stay open.

## Reconciliation Outcome

User agreed the full set in session (2026-10-15, "agreed").

### Direct edits applied

- design.md sec-2 items 5-6, sec-4 drvs `legacyPackages` pick → match code (F-6).
- design.md sec-3: temporary darwin atuin carve-out, both sites, ISS-007 (F-3).
- design.md sec-4: `sudo` on `--list-generations`; nu/`$SHELL` hand-over
  paragraph; step 4 without atuin (F-5).
- DEC-006 alternatives and body, DEC-007 body (factory module lists as of
  DEC-016), DEC-016 consequence (homeModule gate passed), IMP-010 (darwin
  `home` remark dropped), RFC-001 (where-things-stand, SL-004 done bullet,
  IMP-012 blocker edge, W5, W8, W9) (F-8).

### REVs completed

- REV-003 (`reconcile-sl-004`): done — ADR-003 §Context/§Decision/
  §Verification and ADR-001 §Context describe standalone Home Manager on
  both platforms (F-8). Rationale in revision-003.md.

### Withdrawn / tolerated

- F-2: tolerated — conformance registry misattribution (ISS-005).
- F-7: tolerated — cut-over ran out of order; manual step 2 unexecuted.
- F-1, F-4: fixed during audit.

Reconcile pass complete — handoff to /close.
