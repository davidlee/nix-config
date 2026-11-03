# Notes SL-023: Layered dev-env consumer, carried to Doctrine

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-11-03 · design (drafting, run rev 28) · 683ca044

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
- `.doctrine` changes not committed (user commits)

### Learned
- mem_01a14f22cfed79d1a41b494ce0a96355 — corrected: host PATH does not lead with the Doctrine dir
- quotient research forms bind only their cwd root: cross-repo reads need one run per root

### Open
- drafting: design.md sections, code-impact selectors, materialise
- DEC-101, DEC-106, DEC-103 amended (noted on DEC-113/DEC-114), not superseded
- execution checks carried in DEC-114/DEC-117: sccache cache dir writable in forms;
  SCCACHE_DIR default; nix warning on stale follows (CHR-028)
