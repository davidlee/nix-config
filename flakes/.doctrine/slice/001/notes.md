# Notes SL-001: Snooze pilot: first feature under the typed outer resolver

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Origin

Preflight session 2026-10-15 synthesised `brief.features.local.md` (web-agent
architecture brief) and MULTIHOST.md into direction v2, reviewed adversarially
by a second agent; dispositions in `review.features.local.md` (local,
untracked — reference only, not authority; ADRs supersede it).

Scope selectors were written as `flakes/...` (git root is `~`, worktree of
`~/.cfg`); unverified whether doctrine resolves them against `~` or
`~/flakes`. Check at first conformance run.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-15 · design (pre-research) · f870a4cb

### Produced
- ADR-001..005 — composition direction, proposed (8fb3b0b3)
- SL-001 scope (f870a4cb)
- minted: ISS-001..004, IMP-001..011, CHR-001..008, IDE-001 — session fixes, MULTIHOST follow-ups, TODO.md items

### Learned
- mem.fact.nix.merge-order
- mem.pattern.flakes.drv-gate
- mem.fact.flakes.git-add-n
- mem.fact.flakes.fmt-relock
- EVD-001 — coupling survey
- CPT-001 — desktop session model

### Open
- HYP-001 — typed resolver suffices; this slice tests it
- QUE-001 — platform scope declaration
- QUE-002 — CLI tiers (deferred)
- QUE-003 — launcher source (out of scope)
- QUE-004 — Mac VM shape (out of scope)
