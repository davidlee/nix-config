# SL-008 notes

## Design triage (2026-10-16)

Evidence: `research/research.md`. Only its ✓ rows are load-bearing.

**Scope input** (user, 2026-10-16): `personal` means the machines the user
owns, so Sleipnir and Draupnir both import it and a work Mac does not. goad
on darwin is deferred to IMP-023. The Mac's lack of `~/dev` checkouts is
incidental (it is a new build).

**Constraining governance**:
- ADR-001: D2, D3, D4, D7
- ADR-002: D1, D3, D4, D5
- ADR-003
- ADR-004: D4
- ADR-005: D1, D3, D4, D6
- DEC-004, DEC-005, DEC-006, DEC-007, DEC-008, DEC-016, DEC-017, DEC-024,
  DEC-025, DEC-026, DEC-027
- POL-001
- Memories: `mem.pattern.flakes.drv-gate`, `mem.fact.nix.merge-order`,
  `mem.fact.flakes.git-add-n`, `mem.fact.flakes.fmt-relock`,
  `mem.system.flakes.home-worktree`

**Shaping decisions to make**:
- the platform-scope mechanism (QUE-001; research § Cross-thread 2,
  options a–d)
- the home base: its shape, location and layers
- how finely the Linux desktop home modules are split
- what `personal` contains, and where walker, sleipnir-doctor and alarm go
- where the ISS-008 items go
- the parked and dead modules
- the home-base coverage target and the isolation check
- the W2 boundary (eca, chatgpt)
- whether satan* gets a cross-platform `requires` on postgresql
- whether to revise ADR-002 D5 (order)
- phasing and the gate

**Risks**:
- merged-list reorders, and collision winners flipping on `home.packages`
- Linux-only halves landing silently inert on darwin, or failing inside HM
  (tailscale-systray, swayosd, mangohud, systembus-notify)
- nudge runs its `.nu` from the live checkout path, so a file move changes
  behaviour
- the drvs gate is the only check on Draupnir (no probe)
- an aarch64 home may not evaluate if `inputs.emacs` or the neovim overlay
  lacks aarch64-linux packages

**Assumptions**:
- the SL-006/007 gate carries over
- HM `c58f54c` platform behaviour as verified: systemd-only halves are inert
  on darwin
- `agents_override` is needed by every home evaluation until ISS-006 is fixed

**Open questions**: OQ-1..OQ-7 in `slice-008.md`, carried as inquiry nodes in
the design run.

## Direction from the user (2026-10-16), before the inquiring stage

- **inq-1 (QUE-001)**: a feature record may carry `platforms`, a list of
  system strings in the `meta.platforms` style (e.g. `lib.platforms.linux`,
  `["x86_64-linux"]`). Absent means every platform. The resolver gets the
  host's `system` and **refuses** a selected feature that does not support
  it. Profiles stay dumb (`mkDefault` only) and are split:
  `personal` (portable), plus `personal-linux` and `personal-darwin`, each
  of which imports `personal`. Revises ADR-002 D1/D4 and ADR-005 D6, and
  edits DEC-006.
- **inq-12 (cli)**: repartition `modules/shared/cli/_packages` by
  availability. One home list, filtered by `lib.meta.availableOn`, plus an
  explicit `brokenOn` list (watchman; atuin per ISS-007). The `isx86`
  guards go. This is a behaviour phase: Draupnir gains packages.
- Rejected: flake-parts `perSystem`/`withSystem` for module content. Those
  are per-system *outputs*; configurations already know their system
  through `pkgs.stdenv.hostPlatform` (DEC-016).
- Evidence: `availableOn` on aarch64-darwin (registry nixpkgs, not the
  locked pin) is false for backintime, trashy and strace, and true for most
  of the rest of `linuxHome`. watchman claims darwin support but fails to
  build there. `meta.platforms` says what a package supports, not what
  builds or is cached.

## Taxonomy polish (user, 2026-10-16; does not block, apply in the design.md taxonomy section)

- `terminal.utils`: tmux, zmx (out of the base shell-ux bucket?) and clocks.
- text: calendars and calculators split out of `text.tools`. The emacs
  web1913 dictionary installer and sdcv may sit with aspell (a
  dictionary/spelling feature).
- `data.formats` is too broad. Hex editors, markdown pagers, and maybe a
  json/yaml split out of it.

## Review pass RV-017 (2026-10-16)

Two codex reviewers (gpt-6-sol, read-only) ran in parallel: one technical, one
on the taxonomy. Findings, dispositions and verifications are on RV-017
(`doctrine review show RV-017`); user rulings settled F-8, F-9, F-10, F-11 and
F-13, and DEC-032/DEC-033 were edited to match.

**Would a further pass help?** Not before locking. The open risks are
empirical, and a review on paper cannot settle them:
- collision winners (P2–P5): the gate probe settles them on Sleipnir; the
  Draupnir residue gets the VH link-map check at the next switch;
- what P7 actually adds on darwin: the cache check settles it.
A further pass would only re-probe the taxonomy, which is settled by the
user's choices. If one is wanted, it should check plan-level gate coverage
(each phase's proof row) once the plan exists, not the design.

## Harvest

fresh-as-of: slice ready (design locked rev 38, plan committed, PHASE-01 not started); head 8e8b9807

- **Produced**:
  - DEC-030..036 (accepted; each shapes SL-008);
  - QUE-001 answered (DEC-030);
  - IMP-023 (goad on darwin);
  - `design.md` locked at run revision 38;
  - `plan.toml`/`plan.md`: seven phases, sheets materialised;
  - RV-017 (design review ledger: 17 findings from two codex reviewers, all
    disposed; DEC-032/033 edited for the user's rulings; pass waived by the
    user with F-16/F-17 fixed but not re-verified by the reviewer).
- **Learned**: these are facts for this slice. Promote them to memories at close.
  - A Nix attribute segment cannot start with a digit unquoted
    (`feature.graphics.3d` fails to parse), so feature names avoid it.
  - HM `c58f54c`: `systemd.user.enable` defaults to isLinux, and the platform
    assertion sits under `mkIf`. So systemd-only halves are inert on darwin,
    while tailscale-systray, systembus-notify, swayosd and mangohud fail.
  - Area files are plain lists without `lib`.
  - `bin/spotify-alarm` calls `spotify_player` from PATH.
  - nudge runs `.nu` from the live checkout path.
- **Open (to resolve at close)**:
  - IMP-016 → resolved by DEC-032.
  - ISS-008 → fixed in P3.
  - REVs on ADR-002 (D1, D4, D5) and ADR-005 D6, plus the DEC-006 edit:
    raise before P1.
- **Uncommitted**: nothing of SL-008's (b120346a, 8e8b9807).
- **Other untracked items, not SL-008's**: IDE-003..005, IMP-020/021 and
  ISS-009. Leave them alone.

## PHASE-01

### EN-3 governance (2026-10-16, raised, not approved or applied)

- REV-007 (`doctrine show REV-007`): ADR-002 D1/D4 (`platforms` key, read and
  shape-checked by the resolver) and D5 (DEC-035 wording: reorders proved
  harmless by the gate). Also notes D2's "written `{ name; value; }` pairs"
  wording, which the `{lib}: map area [names]` tree outdates.
- REV-008 (`doctrine show REV-008`): ADR-005 D6 extended (a selected feature
  whose `platforms` omit the host's system is an error). The "no support
  metadata until needed" clause the design calls Neutral is D6's last clause
  in the accepted ADR; the D6 rewrite replaces it with a pointer to DEC-030.
- Both stay `proposed`, `approval=none`. Approval (a user act) and apply
  happen at `/reconcile`, as REV-006 for SL-007.
- **For reconcile:** DEC-006's signature gains `system`:
  `lib: { tree, classes, system, modules } -> { modules }` (its body text also
  still describes the long-gone `flags` result). Edit at reconcile, with the
  README § Features paragraph on `platforms` and the darwin/QUE-001 note.

### Gate snapshots

`~/.cache/multihost-gate/sl008/` — baseline/ (EN-2) and phase-01/ (EX-6;
PHASE-02's baseline). Worker fills in counts and verdict below.

**Baseline (EN-2)** `~/.cache/multihost-gate/sl008/baseline/`, taken at HEAD
8e4ca4a7 immediately before the first edit; `just gate` green. Lines: drvs 13,
drvs-sets 5, coverage 7; probe wrote `system/` and `home/`.

**Phase-01 (EX-6)** `~/.cache/multihost-gate/sl008/phase-01/` (PHASE-02's
baseline), HEAD 8e4ca4a7 + uncommitted P1 delta. Counts identical (13/5/7).
`diff` of drvs, drvs-sets, coverage, `diff -r` of system/ and home/: all empty.
`just test` and `just gate` green; `nix fmt --no-cache` 0 changed after the
final edit; flake.lock unchanged. Verdict: **P1 row: none — identical.**
(Emacs-overlay drift was visible in lock-warnings during the phase but moved no
drv line.)

**Red evidence (T3a)**: before allowing the key, `testBadPlatformsShapeFails`
gave `[false false false]` (expected `[false false true]`) and
`testUnsupportedPlatformFails` gave `[false false]` (expected `[false true]`):
`platforms` was an unknown key. After allowing the key: `[true true true]` and
`[true true]`, each red for its own reason. Shape check, then selection check,
turned both green. `testPlatformsAbsentMeansAll` passes throughout (guard).

## PHASE-02

Status: executed, **STOPPED at the EX-5 gate (STOP trigger 1)**; handed to the orchestrator. Uncommitted P2 delta on top of 1391fcc6.

### Decisions
- D1 taken: editors + EDITOR/VISUAL stay in a shrunk `modules/home/shared/default.nix`, imported last by the base until P4.
- Relative-path fixes (nushell.nix, cli.nix, shared/emacs.nix) and doc paths (agents/README.md, _templates/agents/_envrc) done as in the sheet.

### Gate snapshots
Snapshots under `~/.cache/multihost-gate/sl008/`: before `phase-02-before/` (taken at HEAD 1391fcc6, clean but for the vicinae deletion; identical to phase-01), after `phase-02/`.
- Counts 13 / 5 / 7. Drift check: archive of HEAD evaluated to the same 13 lines as T0 -> no drift. (The sheet's recipe needs the archive's justfile `flake :=` set to `path:` + justfile_directory(); `.` resolves the git root to `~/.cache`.)
- drvs-sets, coverage, system probe: identical.
- drvs: `homeConfigurations.david@Draupnir` IDENTICAL (no reorder reached darwin); `david` / `david@Sleipnir` changed; `templates.agents/default` changed. Template proof: `diff -r` shows only the `_envrc:3` comment line.
- Sleipnir home probe: `packages` and `home-path-links` identical; `home-files-links` differs on ONE line, `.manpath -> hm_.manpath`. The manpath file differs only in the `man-cache` store hash (MANDB_MAP line), which is derived from `home-path`'s drv hash. Contents otherwise equal. Per the sheet this is STOP 1.
- `order-only` on Sleipnir: NOT ORDER-ONLY, naming `david-fish-completions` and `home-manager-generation`. `david-fish-completions` differs in env `paths` (a space-separated string, not an array, so the checker's list sort misses it): its 345 tokens sorted are byte-identical old vs new (evidence: `phase-02/evidence/*.paths`). home-manager-generation is the cascade. nix-diff: `phase-02/nix-diff.david@Sleipnir`; chain bottoms out at home-manager-path `__json` + fish-completions `paths`.
- just gate green, fmt 0 changed, flake.lock unchanged.
