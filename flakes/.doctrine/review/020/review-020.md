# Review RV-020 — code-review of SL-009

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

<!-- Pre-reading + lines of attack: what this review is probing, the invariants
     it must hold the subject to, and where the bodies are likely buried. Seeded
     at `review new`; the reviewer fills it before raising findings. -->

Quick per-phase pass over `git show d7860ab5 -- flakes/`, against PHASE-01
EX-1..EX-10 and design § Dev checkouts and the lock. RV-019 staleness out of scope.

Lines of attack:
- `bin/dev-checkouts`: presence test (`-e .git`, worktree file), `ahead`
  semantics vs what `update-local` actually locks, whitespace refusal, flag
  transport as one string.
- justfile: override composition per recipe (read-only vs lock-writing),
  eager backticks, `run`/`run.sh` pass-through, isolation's override set.
- `flake.lock`: no node changes beyond the six re-locked inputs.
- Tests: behaviour coverage of each verb's branches.
- README accuracy against behaviour.

## Synthesis

- **Overall**: solid
- **Synopsis**: PHASE-01 does what the design asks. `bin/dev-checkouts` is
  small, has one responsibility, and is the only place the list is written.
  The justfile names one override per kind (tree, dev, local, stub) and
  replaces the old per-family variables, which overlapped. The lock diff
  touches exactly the six re-locked nodes: agents, goad, oubliette,
  panopticon, satan-attrd, satan-patcher. emacs-overlay was held deliberately
  (ISS-010). The jq guard catches both `path` and `file:` URLs.
  Fixed now: tests for the no-upstream warning and for a worktree checkout,
  each mutation-checked (F-2); a README re-wrap (F-3).
  Tolerated: `ahead` compares against `@{upstream}`, not the branch the lock
  takes. Latent while every checkout tracks main (F-1).
  Accepted in the plan and not re-raised: eager backticks fail every recipe if
  the script fails; the override flags travel as one string.
  Outside the ledger: two memories named `home_override` /
  `system_override` (mem_01a13e63…, mem_01a13d36…); both now name the new
  variables.
- **Haiku**: Five checkouts in `~/dev` /
  the lock forgets where they live, /
  GitHub remembers.
