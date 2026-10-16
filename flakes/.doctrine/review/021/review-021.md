# Review RV-021 — reconciliation of SL-009

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

Mode: conformance (self-audit). Subject: SL-009, all four phases, reviewed in
the primary tree at 41c9d906 (+61680d0c, F-1's fix).

Lines of attack:
- Each phase's delivered diff against design.md § Phases and verification:
  the allowed-diff column is the invariant. Any drv diff outside it is a defect.
- Code against DEC-037..041 (dev checkouts, remote declarations, meta
  validation, overlay scope, agents area).
- Close checks: the design's close grep, the jq lock guard, `just gate`,
  `just coverage`, `doctrine check gate`.
- Mechanical conformance (`slice conformance`, `slice verify-vt`), judged by
  agent where the `flakes/` path prefix misattributes (ISS-005).
- Governance records the slice changes (design § Records at reconcile): do
  they still describe the system?
- Stale prose left by moved code (comments, README).

## Synthesis

**Closure story.** SL-009 delivered what design.md specified, in four phases,
each held to the drv gate's allowed-diff column:

- P1 (d7860ab5): `bin/dev-checkouts` drives every override; inputs declared
  by remote; lock guard. Reviewed separately in RV-020.
- P2 (f1d4ca64): `host-meta.nix` validates metas before resolution; tests
  went red first and were mutation-checked.
- P3 (1f4d6bd8): agents overlay only on legacyPackages; drvs and drvs-sets
  identical.
- P4 (41c9d906): `features/agents.nix`. The only diffs were the two expected:
  Sleipnir home `.manpath` order (same 341 entries), and `base@aarch64-linux`
  losing the registry entry (confirmed with nix-diff). The negative control
  dropped eca.

Re-run by the auditor at 61680d0c, and green: `doctrine check gate`,
`just gate`, `just coverage`, the jq lock guard, and the design's close grep
(no output). P3/P4 diffs read in full against DEC-040/041. P1/P2 evidence
taken from notes.md and RV-020.

**Findings.** F-1 (a stale justfile comment) was fixed in 61680d0c. F-2
(design prose) and F-3 (governance records) go to reconcile. F-4 (ISS-005
attribution) and F-5 (ISS-011, oubliette follows) are owned elsewhere. No
blocker.

**Standing risks.**
- VH-1 (user, on Draupnir: `just drvs`, `just probe`, `just isolation`) has
  not run. The Mac's `os()` branch (the `path:` flake reference) is covered
  only by it; Linux absence is covered by the `FLAKES_DEV=/nonexistent` run.
- Mechanical conformance is unusable in this repo until ISS-005 is fixed, so
  conformance here rests on agent judgement.
- Dev checkouts keep moving under other agents. Each snapshot recorded them;
  later gates must keep doing so (`mem.pattern.flakes.drv-gate`).

**Tradeoffs accepted.** The `.manpath` reorder in Sleipnir's home is a hash
change with an identical set. The gate's probe does not mask it; the
PHASE-04 observation proposes masking it.

## Reconciliation Brief

### Per-slice (direct edit)
1. design.md sec-5 (Phases and verification), P4 row: remove "`config.nix`
   comment" from the phase cell; P3 delivered it (F-2).
2. design.md sec-6 (Code impact), `bin/dev-checkouts` row: "its three verbs"
   → "its four verbs" (F-2).

### Governance/spec (REV / record status)
3. ISS-003 → resolved: `dev_override` includes only present checkouts;
   absence run evaluates (P1) (F-3).
4. ISS-006 → resolved: no lock-writing recipe overrides; jq lock guard in
   `just test` (P1) (F-3).
5. IMP-010 → resolved: `host-meta.nix` + `checks.host-meta` (P2) (F-3).
6. IDE-002 → closed, not adopted (DEC-037) (F-3).
7. DEC-016: amend. The overlay clause is superseded by DEC-040. Drop the
   consequence that every Mac evaluation must override `agents` (the lock
   names no local path) (F-3).
8. DEC-018: restate. legacyPackages is the agents overlay's only carrier
   (F-3).
9. DEC-027, DEC-031: content. The `agents` registry left the NixOS base for
   `agents.registry`; the eca/chatgpt W2 exception ended
   (`agents.eca`, `agents.chatgpt`, selected by personal-linux) (F-3).
10. DEC-034: the stub set is `bin/dev-checkouts stub`, the dev-checkout
    list, which now includes oubliette (F-3).
11. HYP-001: add evidence. W2 landed with no factory selection read (F-3).
12. RFC-001: mark W2 and W6 done (F-3).
