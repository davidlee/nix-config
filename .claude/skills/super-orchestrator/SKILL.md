---
name: super-orchestrator
description: Use when the user wants a planned slice driven to completion unattended (e.g. overnight) — you are the seat, chartering fresh sub-orchestrators every 1-3 phases that drive quotient pi workers and spend Sonnet/Opus subagents only where they earn it, inside a stated autonomy envelope. Main worktree by default. Combines /capsule-driver's tiering with /pi-orchestrate's delegation. Halts before audit.
---

# Super-orchestrator (the seat)

Drive a planned slice's phases to completion while the human is away. You
hold the human's attention and the escalation channel; everything below you
is disposable context.

**Announce at start:** "Using super-orchestrator to drive SL-NNN, phases
X–Y, through sub-orchestrators."

```
you (seat, human attached or asleep)            context: hand-backs only
  └── sub-orchestrator  (agent: sub-orchestrator, opus)   1-3 phases, < 250k
        ├── pi workers   (quotient pi_agent)    default for all phase work
        ├── sonnet       (capsule-worker / general-purpose)  close adherence
        └── opus         (capsule-worker / general-purpose)  real judgement
```

## Preflight: report, then start

Check each, print one line per item, and start anyway unless marked
**blocks**. The human may be asleep; a warning in the morning beats no run.

1. **Plan exists** (**blocks**): design locked, `plan.toml` authored, phase
   sheets materialised (`doctrine slice phases <id>`). This skill implements
   a plan; it does not make one.
2. **quotient forms** (**blocks**; do this first, while the human is
   still here). quotient is assumed. Run the probe from
   `quotient help orchestrate` ("Before the first real run") here at the
   seat, once for the whole run, extended:
   - probe for the tools the phases' workers must run: the gate commands
     (e.g. the `justfile`'s `check` recipe), test runner, formatters,
     linters, any binary a phase's tests call;
   - probe both `read` and `write` forms, and run the cheapest gate (e.g.
     typecheck) to show the toolchain works, not just that it exists.

   Override: the guide says to batch form changes and prefer doing a step
   yourself. Here the step would recur every phase all night, so propose
   one flake/form change covering every gap, and wait for the human to
   approve it and restart quotient and Claude. Re-probe after the restart.
3. **Background tasks**: if `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` is not `1`,
   warn that spawns may background and wake parents at full context, and tell
   the sub-orchestrators to request foreground explicitly. Do not block.
4. **Permission posture**: in `default` mode every child's prompt surfaces
   here and the run stalls while the human sleeps. Warn; do not block.
5. **Spawn depth**: `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` unset or ≥ 2.
   Below 2, warn: sub-orchestrators cannot spawn Sonnet/Opus and will fall
   back to pi or do the work themselves.
6. **Worktree**: none. Run in the main worktree unless the human said
   otherwise. Note `git status --porcelain` so later commits can be checked
   against what was already dirty.

## Other writers are normal

Another agent (or the human) may edit `.doctrine/` or unrelated files during
the run. That is not a conflict:

- Commit only the paths a phase changed (`git commit <paths>`), never
  pathless, never `git add .`. Leave other changes alone; never revert,
  stash, checkout or reset them.
- Change doctrine state through the CLI; re-read a hand-edited file (notes,
  plan) immediately before editing it, and make small appends.
- A moving `HEAD` is fine. An `index.lock` is transient: wait and retry.
- It **is** a conflict when someone else edits a source file the current
  phase owns. Halt that phase and escalate (below).

## The loop

1. **Charter** a sub-orchestrator: slice id, a contiguous run of phases,
   the envelope (below) and any standing constraint from the human. Size it
   by the phases, not a fixed count: **1** for a heavy phase (large test
   matrix, many files, new subsystem), **2** typically, **3** only for small
   ones. pi orchestration is chattier than capsule work (briefs, waits,
   re-runs), so lean smaller. Spawn agent type `sub-orchestrator`, unnamed
   (never pass `name`), in the foreground.
2. **Read the hand-back.** Check: commits exist (`git log --oneline`),
   every Sonnet/Opus spawn carries a reason, envelope decisions are logged.
   Don't re-verify diffs; spot-check one gate only if the hand-back is
   vague.
3. **Reap** it (`TaskStop`) once read. Always charter a fresh one; never
   resume a tired one.
4. **Escalations**: see below. Otherwise charter the next run.
5. **Halt when the planned phases are done. Do not begin audit.** Write the
   morning report.

Keep your own context small: you read hand-backs, not code.

## Model use

Delegation follows `quotient help orchestrate` via `/pi-orchestrate`; the
sub-orchestrators read it, not you. pi is the default worker for all phase
work. This skill makes the guide's "stronger agent" concrete; each Claude
spawn states its reason:

| use | when it is worth it |
|---|---|
| **Sonnet** | implementation where close instruction-following matters: contract tests transcribed from criteria and negative controls, byte-exact formats, a precise multi-file mechanical change, or a pi task that failed twice |
| **Opus** | real judgement: diagnosing a failure two attempts missed, adjudicating contested review findings, a security- or trust-boundary review, an in-envelope design adaptation that needs reasoning through |

The sub-orchestrator is itself Opus; it spawns an Opus child only to keep a
deep investigation out of its own context. In a doctrine repo the Claude
worker is `capsule-worker` with a `model` override; elsewhere
`general-purpose`.

## Autonomy envelope

The goal is a run that finishes unattended. Decide inside the envelope, log,
and keep going; interrupt only for decisions that are really the human's.

**Decide, log, continue** (the "yes, sure" tier):
- Plan adaptations: reorder tasks, split a phase (append new ids, never
  renumber), fix a VT's `test_file`/`keywords`, add criteria.
- Design clarifications and local corrections that keep scope, behaviour
  contracts and decisions intact: a wrong path or symbol, an arithmetic
  slip, a helper's name, an extra test helper. Edit the design text if
  needed and flag it for audit.
- Test fixtures, helpers, adjacent refactors inside the phase's files.
- A pi worker's loose result: re-brief, escalate to Sonnet, move on.

**Defer to audit / backlog** (log, don't fix now):
- Defects or improvements outside the phase's scope: `doctrine backlog new`.
- Design drift the implementation forced: an "Autonomy log" entry for
  `/audit` → `/reconcile`.

**Interrupt** (halt the affected work, escalate):
- Scope: anything in the slice's non-goals, or new outward reach (another
  repo, a network service, a push).
- A new runtime dependency.
- Weakening a bound, a security or trust-boundary rule, or a test's
  negative control.
- Contradicting an accepted ADR, DEC, policy or a recorded user ruling.
- Destructive or hard-to-reverse actions; a CLI gate that needs a user act.
- The same phase failing after two sub-orchestrator attempts.
- Another writer in the phase's source files.

### Escalating while the human is away

1. Park the blocked phase. If later phases do not depend on it (check the
   plan's sequencing), charter them and continue.
2. Send a push notification (`PushNotification`) naming the decision, in one
   line. Don't wait on a reply.
3. If nothing independent remains, stop and write the morning report.

## The log

The sub-orchestrators append to an `## Autonomy log` section in the slice's
`notes.md`, one line per envelope decision: phase, what, why, tier
(decided / deferred / escalated). `/audit` reads it.

## The morning report

When you halt, print and push:
- phases completed, with commit shas; phases parked and why
- escalations, each as a decision the human makes ("agreed" / "do X")
- the autonomy log's "decided" and "deferred" lines, compacted
- every Sonnet/Opus spawn with its reason; pi cost if reported
- preflight warnings still open
- the next step: `/audit SL-NNN`, or the parked phase

## Boundaries

- **Not `/dispatch`**: no worktrees, no confinement, unless told otherwise.
- **Do not implement or review diffs yourself.** If you are editing source,
  the tiering has failed.
- **Do not audit.** Hand back to the human for `/audit`.
- Record friction with `doctrine observation record friction "<summary>"`.

## Related

`/capsule-driver` (Claude-only tiering), `/pi-orchestrate` (pi delegation
rules), `/plan` and `/phase-plan` (what this consumes), `/audit` (next).
