# Notes SL-023: Layered dev-env consumer, carried to Doctrine

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-11-03 · ready (design locked rev 42; plan 8 phases) · 299a66a6

### Produced
- SL-023 scoped (S1–S5, C1, T1–T5) — uncommitted, staged
- research.md (gitignored) — three quotient pi threads, orchestrator-verified rows ✓
- minted: DEC-107 — one PATH list, pam/home-manager own order; DEC-108 — four layers;
  DEC-109 — Doctrine paths as host facts, nix build at /run/doctrine-nix-bin;
  DEC-110 — host-path runtime bind, /run/doctrine-bin goes
- minted (inquiry close): DEC-111 Doctrine subtraction; DEC-112 capsule-tools split;
  DEC-113 five jails + default shell; DEC-114 devEnv + host-facts env list;
  DEC-115 forms as approved links; DEC-116 agents.pi multiplatform;
  DEC-117 verification; DEC-118 tech spec phase; DEC-119 cross-repo records
- CHR-028 — gated follows removal
- slice-023.md scope brought current with DEC-107..119 (inquire.scope)
- design.md drafted: nine sections, materialised; 20 design-target selectors
- IMP-058 — JAILED_AGENT_DEPTH guard likely surplus (user, during drafting)
- RV-046 (codex, gpt-6.1-sol): F-1..F-3 MAJOR, fix-now, verified; design.md adopted
  rev 35; scope, selectors (features/dev.nix in; modules/home/{dev-env,default}.nix out);
  F-1..3 reopened procedurally to add route=review, re-verified by codex
- DEC-120 — use_dev_envs and dev-envs-forms override agents to the in-tree library (post-lock)
- plan.toml / plan.md: PHASE-01..08; phase sheets materialised; research restamped
- `.doctrine` changes not committed (user commits)
- ISS-024 — ccache skipped on aarch64-darwin (platform-skips + manual probe);
  pre-existing Draupnir eval failure, fixed before PHASE-01's baseline (user)
- PHASE-01 implemented (uncommitted): agents/doctrine.nix, agents/dev-env.nix,
  modules/user-bin-path.nix; env.nix + darwin home.sessionPath read the list;
  dev.env feature (personal); agents.pi on every platform (personal);
  checks.factories VT-1/VT-2 in hosts.nix (nixosConfigurations and the
  home-base coverage home lifted into its let as `homeBase`)
- PHASE-01 EX-5 (DEC-119, outside the repo): init.zsh's `path=(~/bin …)`
  prepend was already removed by the user in 906b5acb; nothing to do
- PHASE-01 VA-1 ✓ (nix-diff): Sleipnir system and all Sleipnir+* coverage and
  base@aarch64-linux move only in environment files (pam, systemd path,
  profile, zshenv); homes add sccache, mold (Linux) and session vars;
  Draupnir home adds sccache, pi, sessionPath; home@aarch64-linux and
  darwinConfigurations.Draupnir unchanged; dev checkouts unchanged
- PHASE-01 VH-1 ✓ (operator, 2026-11-04, after switch + relog): PATH leads with
  ~/.local/share/doctrine/bin; type -a doctrine lists it, then the ~/.local/bin
  symlink (expected until PHASE-07); RUSTC_WRAPPER=sccache. A pre-switch session
  keeps its old env: the user manager lingers, so a relog/reboot is needed

### Learned
- mem_01a14f22cfed79d1a41b494ce0a96355 — corrected: host PATH does not lead with the Doctrine dir
- quotient research forms bind only their cwd root: cross-repo reads need one run per root

### Open
- next: /phase-plan PHASE-02 (EN-1 needs only PHASE-01's files)
- DEC-120 post-lock amendment → reconcile into design.md (§ Post-lock amendments)
- uncommitted; new untracked files need explicit git add: plan.toml, plan.md,
  knowledge/decision/120* incl. its slug symlink (user commits)
- DEC-101, DEC-106, DEC-103 amended (noted on DEC-113/DEC-114), not superseded
- execution checks carried in DEC-114/DEC-117: sccache cache dir writable in forms;
  SCCACHE_DIR default; nix warning on stale follows (CHR-028)

## Further review passes (review.passes, after RV-046)

None needed before lock. RV-046 probed ownership, ordering, baked paths and
governance placement; its three fixes are local and were verified. What a
further pass would probe, if wanted: the runtime claims no review can settle
from source — quotient's form check on the `$HOME` PATH entry and mold's
spaced flag (DEC-110), sccache in forms (DEC-114), nested bwrap (DEC-111).
These are execution checks already carried in the handover; a review would
only restate them.

## Post-lock amendments (for /reconcile)

The design is locked (run rev 42) and was not reopened. These amend it and
must be reconciled into design.md at /reconcile:

- **DEC-120** (user, 2026-11-03, during planning). § The consumer / § The shell:
  `use_dev_envs` and `bin/dev-envs-forms` add
  `--override-input agents path:$HOME/flakes/agents`; `use_dev_envs` watches
  `~/flakes/agents/*.nix`; dev-envs' lock keeps the published pin; the
  `doctrine` input stays pinned. § Code impact gains `bin/dev-envs-forms`
  (+ test) as a design target. § Handover: no push and re-lock is needed before
  the subtraction. Plan: PHASE-03 EX-7/VT-4; PHASE-06/EN-2 superseded.
