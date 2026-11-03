# Notes SL-023: Layered dev-env consumer, carried to Doctrine

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-11-04 · started; PHASE-06 completed, PHASE-07 next · 59c7999e (doctrine e37ecf2a3)

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
- PHASE-02 committed 5cedc922: agents/jailed-agents.nix (host-path
  runtime bind + PATH, nixDoctrineOption via bind-pkg, nixDoctrine on posture
  and makeJailedAgent, hostDevEnv export), jailed-agents-test.nix, README.md.
  just test / gate / coverage green; VA-1 ✓; drv gate: only Sleipnir's home
  moves, in jail/form launchers (eca, malebolge, satan-gptel-harness,
  quotient-read/-write) and dependents
- PHASE-02 D-1: nixDoctrine bound with c.bind-pkg, not the design sketch's
  c.ro-bind — ro-bind omits the closure the design requires (reconcile wording)
- PHASE-03 committed 90e3bdaf: dev-envs five jails, forms (envOptions,
  postureFlags.nixDoctrine), devShells.default, shorthands; dev-envs/dev-env.nix
  (`errors` + `checkDevEnv`, checks.dev-env); checks.stub over five launchers
  (needles: bundle, `--setenv STUB_DEV_ENV stub`, `${STUB_HOST_ENV+x}`); doctrine
  input (github:davidlee/doctrine, no follows); use_dev_envs → #default + agents
  override + watches dev-envs/*.nix, agents/*.nix; dev-envs-forms agents override;
  README § Jailed Agents. just test green; root drvs unchanged; VA-1 ✓ (Smut:
  smut-dev-tools in jailed-pi, all five jails + shorthands on PATH)
- PHASE-03 deviation for /reconcile: `checkDevEnv` is exported from
  dev-envs/dev-env.nix beside a pure `errors`, not defined inline in flake.nix
- PHASE-04 (outside the repo, DEC-119): doctrine CHR-184 created; step 1
  e48660f3f pushed to origin/edge (operator-authorised); fleet a9b384f
  (toolsPackage capsule-tools, lock bump doctrine only; NOT pushed); step 3
  23c4d5eb3 (not pushed). Doctrine nix flake check green after steps 1 and 3.
  VA-1 ✓ each step (guest tool set holds doctrine-0.48.1; capsule-tools holds
  bubblewrap from step 1). VA-2 ✓ (nix-diff jailed-pi: + bubblewrap only)
- Compared Doctrine revision for PHASE-05 (EN-1): 23c4d5eb3
- ISS-025 — dev-envs stub check fails where the stub's locked store path is absent
- PHASE-05 (2026-11-04): launcher diff at doctrine 23c4d5eb3. Evidence (gitignored):
  `.doctrine/state/slice/023/evidence/phase-05/` — `launcher-diff.sh`, `*.norm`,
  `*.diff`, `summary.txt`, `classification.md`. Three unlisted deltas, all
  resolved with the user: F-1 producer pins ignored → dev-envs `project` is
  `flake = false` + flake-compat (checks.project-pins, stub-project/flake.lock
  pins Doctrine's nixpkgs 55bfb4d7; `just test` runs it under --override-input);
  every consumer jail now carries Doctrine's own dev-tools out path. F-2 library
  nodejs_24 now resolves after the caller's packages (jailed-agents-test
  `piCallerNode`). F-3 R5 wording. F-1/F-3 → § Post-lock amendments.

### Learned
- mem_01a14f22cfed79d1a41b494ce0a96355 — current wiring updated after PHASE-02 (jail bind at host path;
  nixDoctrine at /run/doctrine-nix-bin); stale `--args 23` claim corrected
- jail.nix launchers are one line: assert a PATH value with `grep -o '--setenv PATH [^ ]*'`
  (mem.fact.jail-nix.launcher-one-line)
- quotient research forms bind only their cwd root: cross-repo reads need one run per root
- mem.fact.flakes.relative-path-input-lock CORRECTED: the stub's lock narHash pins its
  content (not a sentinel); edit the stub → `nix flake update project` in dev-envs

### Open
- PHASE-02 EX-6 ✓ (2026-11-04, after the operator's switch): active machine form binds
  "$HOME/.local/share/doctrine/bin", no /run/doctrine-bin; live pi read run in ~/dev/doctrine
  (run-20261103T135438988Z-1-a9b824e4112d): `type -a doctrine` → host path, 0.47.0
- DRIFT for /reconcile: plan PHASE-02 EX-6 asks for `quotient allow`
  per machine form; quotient never approves machine forms (help policy § Project forms: no
  approval + no link → machine form runs). DEC-115 is right: `quotient allow` is for project-form links (PHASE-06)
- after the switch, ~/dev/{smut,satan-attrd}/.doctrine/state/pi/extensions/mcp.ts still
  bake /run/doctrine-bin: in-jail pi doctrine MCP breaks there until re-bake
  (`doctrine install` in that checkout, or PHASE-07)
- fleet a9b384f and doctrine 23c4d5eb3 unpushed (operator's call)
- PHASE-05 ✓ 2ea8e854. next: /phase-plan PHASE-06
- F-2: malebolge bridge under a project's node (26 in Doctrine) not exercised
  live; needs node >= 23.6. If it fails: backlog item in malebolge (user)
- new untracked: dev-envs/stub-project/flake.lock (git add -N done)
- DEC-120 post-lock amendment → reconcile into design.md (§ Post-lock amendments)
- uncommitted; new untracked files need explicit git add: plan.toml, plan.md,
  knowledge/decision/120* incl. its slug symlink (user commits)
- DEC-101, DEC-106, DEC-103 amended (noted on DEC-113/DEC-114), not superseded
- execution checks carried in DEC-114/DEC-117: sccache cache dir writable in forms;
  SCCACHE_DIR default; nix warning on stale follows (CHR-028)
- PHASE-06 ✓ (2026-11-04): doctrine e37ecf2a3 (flake producer-only, lock drops
  agents+quotient nodes only, justfile EX-2); .envrc on use_dev_envs (allowed);
  forms linked + approved (doctrine, smut); doctrine.policy forms → machine forms;
  old doctrine-{read,write} form links removed; CHR-028 evidence (EX-5: warnings
  only). dev-tools out path unchanged; gate green in the consumer shell; VA-1 two
  project-form pi runs completed. next: /phase-plan PHASE-07
- doctrine e37ecf2a3 unpushed (with 23c4d5eb3)

## Execution passes (PHASE-03/04)

| pass | who | profile | cost | outcome |
|---|---|---|---|---|
| P03 lane A (flake side) | Claude Sonnet subagent | — | — | met design; deleted + restored a store path while diagnosing the stale stub (unasked); found the narHash-pins-content fact |
| P03 lane B (shell side) | pi deepseek-flash | implement | $0.02 | green first try; dropped "the shell" from README's consumer list |
| P03 review | pi deepseek-flash | review | $0.09 | 12 findings: 9 fixed (partial devEnv cases, tight needles, set-env-vs-forward needle, empty `inner` quoting, watch dev-env.nix, README by-hand block, description, non-attrset guard, checkDevEnv name); 2 accepted (throw text untestable by tryEval; dead `probe` predates); git diff unavailable in form (no .git under $HOME's worktree pointer) |
| P04 | orchestrator | — | — | done directly: edits smaller than a brief |

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
- **PHASE-05 F-1** (user, 2026-11-04: "A"; departure, design not reopened).
  The launcher diff showed `--override-input project git+file:…` (Lix 2.95.4)
  ignores the project's flake.lock: the project's inputs reuse the stub's lock
  entries or lock fresh, so dev-tools was built at dev-envs' pins, not the
  producer's. Fix: dev-envs takes `project` as `flake = false` and evaluates it
  with flake-compat against its own lock (probe: same dev-tools drv as
  Doctrine's flake at 23c4d5eb3). § The consumer (and § Verification: the diff
  may require identical dev-tools paths) to reconcile.
- **PHASE-05 F-3** (user, 2026-11-04, accepted). § Verification's R5 row covers
  agents-library drift since the producer's agents pin (malebolge bridge,
  quotient relay), not only store paths.
- **PHASE-05 F-2** (user, 2026-11-04; library fix, no design change): the
  library's nodejs_24 now resolves after the caller's packages.
- **PHASE-06 D-1** (agent, user away: "make sensible decisions"). § `.envrc`
  lists `SCCACHE_DIR` among the exports that "are now host facts", but
  `agents/dev-env.nix` does not set it. Dropped anyway: the old value
  (`~/.cache/sccache`) is sccache's Linux default, so behaviour is unchanged.
  PHASE-07 EX-2 still checks it live. Wording to reconcile.
- **DEC-121** (user, 2026-11-04: "A", after /consult on PHASE-07 F-1). A jailed
  cargo used a host sccache server over TCP 127.0.0.1:4226 (networked jails
  share host loopback), so rustc ran unconfined on the host. Each side now uses
  its own unix socket: the library's `envOptions` set
  `SCCACHE_SERVER_UDS=/tmp/sccache.sock` in every jail and form;
  `agents/dev-env.nix` gains `hostOnlyEnv` (Linux only,
  `${XDG_RUNTIME_DIR}/sccache.sock`), applied by `dev.env` alone, never in
  `env`. § Host facts (`for` returns `{env; hostOnlyEnv; packages}`), § The
  jail library (envOptions) and DEC-114's wording to reconcile. Class risk
  (any host loopback service reachable from a networked jail): RSK-001.

## PHASE-07 VA-1: design § After: behaviour (2026-11-04)

Home generation 867; flakes ee2a5f86; doctrine 7eddc8ea1; fleet a9b384f. Symlink
~/.local/bin/doctrine removed by the operator before every row below except
where a row says otherwise.

| row | command | result |
|---|---|---|
| Doctrine's gate in a jail | `just gate` in jailed-shell (D-1: launcher equals jailed-pi bar agent) | rc 0 (re-run after DEC-121 and symlink removal); e2e confinement ran live, no skip |
| sccache, jail | clean + rebuild, one target dir | 160/160 hits; host server 0 requests; socket /tmp/sccache.sock |
| sccache, form | `pi_agent` implement profile: `cargo build --locked`, clean, rebuild, `--show-stats` (run …210659733Z-18) | 163 requests, 160 hits, 0 misses; stats confirmed in events.jsonl |
| sccache, host | fresh login: `echo $SCCACHE_SERVER_UDS`; `cargo check`; `ss` | /run/user/1000/sccache.sock; UDS listening; nothing on 4226 |
| forms | one `pi_agent` run each (read, write) | both completed, no form-unapproved; UDS=/tmp/sccache.sock |
| one Doctrine, both sides | `type -a doctrine` in fresh `zsh -li` and jailed-shell | one entry each: ~/.local/share/doctrine/bin/doctrine |
| same BIN_PATH + codex command | PHASE-07 EX-3 finding | identical host and jail; not repeated |
| fresh codex starts MCP | `codex exec` / `jailed-codex exec` calling memory_list, after symlink removal | mcp__doctrine__memory_list answered on both sides |
| no persisted /run/doctrine-bin | grep host + jail codex config, mcp.ts | none (transcripts only, A2) |
| Nix Doctrine | `/run/doctrine-nix-bin/doctrine --version`; `command -v doctrine` in a jail | 0.48.1; command -v names the install dir |
| Smut | `direnv exec ~/dev/smut` (use_dev_envs) | loads; jailed-pi and doctrine on PATH |
| `just test` | ~/flakes | rc 0 |
| fleet | PHASE-06 VA-1 evidence | cited; fleet HEAD still a9b384f, lock unchanged |
| Doctrine's flake | `nix flake check`; flake.nix grep; darwin devshell drvPath | rc 0; no agents/quotient input; fwpm69vb…-devshell.drv |
| darwin home | Draupnir activationPackage drvPath | h519s5ib…-home-manager-generation.drv |
| `dev.env` optional | `just coverage` (isolation); hosts.nix checks.factories in `just test` | rc 0 |

Limits of this evidence:

- A form's ~/.cargo and ~/.cache/sccache did not survive between runs (the
  08:06 run found no ~/.cargo; the 08:07 run's was created that minute).
  Inference: a form's cache is per-run, so hits come only within a run, and each
  run re-fetches crates. `cargo --offline` fails in a form. The row's criterion
  is met; a warm cache across delegate runs is not provided.
- pi reaching MCP (malebolge bridge, F-2) is not evidenced here: VH-1.
