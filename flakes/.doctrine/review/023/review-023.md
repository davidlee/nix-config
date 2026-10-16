# Review RV-023 — reconciliation of SL-010

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

<!-- Pre-reading + lines of attack: what this review is probing, the invariants
     it must hold the subject to, and where the bodies are likely buried. Seeded
     at `review new`; the reviewer fills it before raising findings. -->

Mode: conformance. Surface reviewed: the main worktree at fe348e8f, plus the
F-6 header edit (capsule-driven; no dispatch candidate).

Lines of attack:
- **Move list.** Every row of design § NixOS side and § Home side landed at its
  named record and half, and is selected by the named profile or host.
  Nothing optional remains in either base.
- **Build identity.** P1–P3 are pure moves: drvs identical, or ordering-only
  with drvs-sets / nix-diff proof. P4's diffs are only the ones it declared.
- **Invariants.**
  - `services.avahi` is selected explicitly (ADR-001 D4: `requires` never
    selects).
  - The root-shell drop and the system-zsh move landed together.
  - No stale paths are referenced anywhere.
- **Delta and scope.** The recorded source-delta matches the landed commits,
  and the delta stays within the design-target selectors.
- **Governance.** DEC-042, DEC-043 and DEC-044 match the end state.
- **Human check.** VH-1 (behaviour after the user's switch).

## Synthesis

**Closure story.** SL-010 does what it set out to do. The NixOS base is now
nix, user, boot, kernel, env, maintenance, security, network and programs,
plus the cli inspection set. The home base is nushell, direnv and the base
cli. Every piece that left is a feature record or half, selected exactly as
the design's tables say.

**Builds.**
- P1 left every drv identical.
- P2 and P3 were proven ordering-only on Sleipnir, the `Sleipnir+*` coverage
  targets and both homes. The proof is the sets plus nix-diff, and a probe
  showing that no collision winner flipped.
- The bare coverage targets (`base@aarch64-linux`, `home@aarch64-linux`) only
  shrank.
- P4's diffs are the declared ones: root, assigner and postgres move to bash
  (F-3); zsh comes from `terminal.zsh`; the shpool unit is gone; zmx is a
  duplicate entry.

**Checks.**
- The gate passes: `doctrine check gate` rc 0, treefmt 0 changed.
- `just test` and `just coverage`, including isolation, pass.
- Hand-mapping puts every code path in the delta under a design-target
  selector.
- The user verified VH-1 on Sleipnir after switching. They checked root's
  bash from ghostty with the default TERM, their nu login, zsh's config, zmx
  session restore, and that shpool is gone.

**The one real defect, F-1.** Moving root to bash exposed a missing system
terminfo entry. The design had treated the root shell as a choice of POSIX
shell, and readline also needs the terminal's terminfo. The fix is
`environment.enableAllTerminfo` in the base (fe348e8f). It was chosen over
installing per-emulator entries, because the terminal reaching a host's shell
may be remote.

**Standing risks.**
- `enableAllTerminfo` couples NixOS evaluation to 13 upstream packages
  evaluating. If one breaks on unstable, turn the option off or pin.
- The evaluation commands (`just drvs`, `just test`, `just coverage`,
  `nix fmt`) re-resolve emacs-overlay through the local `emacs` override, so
  home drvs drift between snapshots with no source change. Seen here as magit
  20261013 → 20261016. Attribute such diffs before reading them as regressions
  (observation already recorded).
- Conformance cannot attribute paths in this repo (ISS-005). Its output was
  read by hand here.

**Accepted tradeoffs.**
- F-4: an immutable plan criterion carries a false clause; its intent is met.
- F-5: a redundant, deduplicated `pathsToLink` entry kept so that P4 stayed a
  move.

## Reconciliation Brief

### Per-slice (direct edit)
- **F-1**, design.md:
  - § NixOS side, the "Base after" bullet: add `env.nix` keeps
    `environment.enableAllTerminfo = true` (every terminal's terminfo, so
    root's bash works from any emulator, local or over ssh).
  - § Phases and verification: add a note that FIX-1 (fe348e8f) followed P5
    and added 13 terminfo outputs to every NixOS system; evidence in
    notes.md § FIX-1.
- **F-3**, design.md § Home side, the `users.defaultUserShell` row: "dropped:
  root and the system users taking the default (assigner, postgres) get
  NixOS's default bash".

### Governance/spec (REV)
- **F-3**, DEC-042 consequences: add "system users taking the default shell
  (assigner, postgres) also get bash". Written with `doctrine knowledge edit`
  (no comma inside the item; the flag splits on commas).
- **F-1**, DEC-042 consequences: add "the base installs all terminfo
  (environment.enableAllTerminfo) so root's bash works from any terminal".
