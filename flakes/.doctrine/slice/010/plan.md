# SL-010 plan

Five phases, ordered so every derivation change is attributable.

```
P1 parked + dead ──> P2 NixOS moves ──> P3 home moves ──> P4 behaviour ──> P5 docs
   no drv change       ordering-only       ordering-only       intended diffs    no drv change
```

- **P1 first** because it touches nothing that evaluates: it clears `modules/`
  so later diffs read cleanly, and proves the baseline.
- **P2 / P3 split by evaluation.** NixOS moves change system drvs (plus one
  home move: the tailscale tray follows its daemon); home moves change home
  drvs. Separate snapshots keep each nix-diff small.
- **P4 isolates behaviour.** Root's shell, the system zsh move, shpool and zmx
  are the only intended diffs. The system zsh move cannot ride in P3: with
  root still on zsh, a base without `programs.zsh` fails NixOS's shell
  assertion (`coverage."base@aarch64-linux"` would break).
- **P5 last** so docs describe what landed.

Each phase takes its own fresh `just drvs` snapshot immediately before
editing (checkouts and the emacs-overlay re-resolve move under us;
mem.pattern.flakes.drv-gate). The user's uncommitted `justfile` and pi
settings edits are never staged: commit explicit paths only.

Risks carried into execution:

- Ordering-only claims need `drvs-sets` proof, not assertion
  (mem.fact.nix.merge-order).
- `/etc`-only effects (avahi, sshd, tailscale, locate, udisks2, firewall ports)
  leave no trace in some drvs; spot-check option values before and after.
- `features/terminal/` is a new directory: `git add -N` before evaluating
  (mem.fact.flakes.git-add-n).
