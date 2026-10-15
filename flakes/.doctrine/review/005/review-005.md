# Review RV-005 — reconciliation of SL-002

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

<!-- Pre-reading + lines of attack: what this review is probing, the invariants
     it must hold the subject to, and where the bodies are likely buried. Seeded
     at `review new`; the reviewer fills it before raising findings. -->

Mode: conformance. Surface: `git diff 4e451ad3..5f672bdb` on main (not
dispatched; no candidate branch).

Lines of attack:

1. **Ownership.** Every capsule piece lives in `features/virt/capsule.nix`.
   None is left in `network.nix`, `security.nix`, `user.nix` or Sleipnir's
   `config.nix`. `nftables.enable` stays host-wide (design sec-3).
2. **Identity.** Every configuration's drvPath matches the baseline, except
   Sleipnir. Sleipnir differs only in `sudoers-in`, by the rtcwake/nft rule
   swap that sec-4 allows. HEAD reproduces the gated capture.
3. **Selection.** Sleipnir selects capsule by a plain definition (DEC-011),
   and `testSleipnirSelectsCapsule` guards it.
4. **Off case.** The negative control and the mutation check are recorded
   (notes, PHASE-01).
5. **Hygiene.** No path names `modules/nixos/capsule.nix`. deadnix and
   statix are clean. `flake.lock` is untouched.
6. **Deviations** from the handover: two commits, comment drift.

## Synthesis

SL-002 delivers what the design asked for. All 13 sec-6 paths changed and
nothing else did. The feature file holds all five pieces: the perimeter
modules, the port, the table, the sudo rule and `assigner`. The base
modules hold none of them, and `security.nix` dropped its `username`
argument. HEAD's `just drvs` matches the after-capture exactly. Only
Sleipnir differs from the baseline, by the one allowed sudoers reordering,
which is safe because the two commands are disjoint and both rules render
after the root/%wheel rules. The checks behind the off case — red/green,
mutation and negative control — were run in PHASE-01 and recorded in the
notes. This audit re-ran the identity gate and the tests, and did not re-run
those three checks.

Four findings, none blocking. F-1 and F-2 are tooling gaps that other items
own: ISS-005 (path roots) and CHR-010 (`just gate`). Because of them, the
mechanical conformance and VT signals cannot speak for this slice, so they
were replaced by agent judgement and the project's own nix gates. F-3 and
F-4 are deviations that match the design's intent.

Standing risks:
- If ISS-005 stays open, every slice in this repo audits with red
  conformance and gets judged by hand. The longer that runs, the more
  likely a real undeclared path is missed.
- HYP-001 (whether a feature can use the composition slot of ADR-004
  D2–D3) is still not tested by any slice. RFC-001 W2/W3 carries it.
- The out-of-repo stale path at `~/dev/oubliette/README.md:242` remains.

Tradeoffs accepted: the move is two commits so history follows; there is
no `flake.coverage` target for capsule while Sleipnir selects it
(ADR-005).

## Reconciliation Brief

No finding needs a spec or governance change: F-1 and F-2 are tolerated,
and F-3 and F-4 are aligned.

### Per-slice (direct edit)
- None required. design.md sec-3/sec-6 stay accurate: `git mv` was used,
  and the commit count was never specified (F-3).

### Governance/spec (REV)
- None.

### Knowledge records to settle (not REV; `doctrine knowledge settle`)
- DEC-010..014 are still `proposed`. The implementation confirms each of
  them as built: virt area and single file; selection in Sleipnir's own
  features.nix; ownership of the four pieces with `nftables.enable`
  host-wide; plain sudo priority; real-tree test, drv gate and one-off
  negative control. Reconcile should accept them.
- HYP-001 stays `proposed` (not exercised; carried to RFC-001 W2/W3).
