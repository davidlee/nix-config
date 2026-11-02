# IMP-057: Jail and Quotient definitions for the home repo

This repo (`~/flakes`) has no jail and no Quotient forms. Pi therefore runs here
unconfined, and the agent-safety setup that project flakes get from the
dev-envs consumer (SL-022) does not apply. This item adds the definitions.

Terms:

- **Jail** — a bubblewrap sandbox that confines an agent to a bound set of
  paths and tools (see SL-022 § Context).
- **Quotient form** — a per-call agent entry point (`read`, `write`) that the
  host's Quotient server launches for a delegate. Forms are approved by hand
  with `quotient allow`.

The shape differs from a project flake:

- A project flake exports `packages.<system>.dev-tools` and the consumer builds
  around it. This repo *is* the flake, so its own tools (nix, just, statix,
  treefmt, the gate's checks) need an equivalent producer output, or the jail
  has no toolset to bind.
- The git worktree is `$HOME` (see `~/flakes/CLAUDE.md`). A jail launched there
  would expose all of `~`, so its launch directory must be `~/flakes` or below.
  IMP-042 (refuse a launch dir that is `$HOME` or an ancestor) is the guard.
- The repo is public (POL-001). The jail must bind no secret material, and the
  forms must not read outside the checkout.

Open questions for the slice (not decided here):

- Whether the root flake gets a `dev-tools` output, or the dev-envs consumer
  takes the repo's tools some other way.
- Which paths the jail binds read-only and which read-write, given `$HOME` is
  the worktree and `.doctrine/`, `.pi/` and `.claude/` are tracked here.

Related: SL-022 (the consumer and its proof), IMP-056 (Doctrine consumer,
step 3), IMP-042 (launch-dir guard).
