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

### Orchestrator verdict
The worker's STOP trigger 1 was adjudicated **order-only** and committed as
c4020d9a. Evidence: Sleipnir `packages` and `home-path-links` identical; the
only probe delta is `.manpath`'s `man-cache` store hash, which is derived from
the reordered `home-path` drv. The other NOT-ORDER-ONLY drv,
`david-fish-completions` (env `paths` is a space-separated string the checker
did not sort), was built old and new, and `diff -r` of the realised outputs
(old `/nix/store/r5zkbr9rfnhdb7ss35d2yg9s7wikhgvm-david-fish-completions`,
new `/nix/store/a2n1y3h8iiw4dmlmx9807w0kz0gjxxwh-david-fish-completions`) is empty. Draupnir home drv
unchanged. Carried into P3: the derived-hash rule, the `order-only` fix for
space-separated store-path strings (planner-verified: the P2 Sleipnir pair is
then ORDER-ONLY; Sleipnir vs Draupnir still NOT ORDER-ONLY), and the archive
drift check's `flake := "path:" + justfile_directory()` override.

## PHASE-03

Status: executed, gate green; uncommitted P3 delta on top of c4020d9a. Two
sheet-literal mismatches in the negative controls, both flagged for the
orchestrator (see § Negative controls); no gate STOP.

### Tests
Red (T1, before any feature edit; `phase-03/evidence/t1-red.json`), exactly as predicted:
- `testSleipnirHomeSelection`: all 16 `false`.
- `testObsRequiresCore`: `[false false]`.
- `testDesktopCoreLinuxOnly`: `[true true]`.
- `testSleipnirSelectsMigrated`: `desktop.core#nixos` gave `[true false]` (expected `[true true]`).
- Every other test green.
After T2: only `testObsRequiresCore` (`[false false]`) and `testSleipnirHomeSelection` (`[true false …]`) red. After T3: only `testSleipnirHomeSelection` red (`[true false …]`). After T4: `runTests` `[]`; `just test` green.

### Gate snapshots
Under `~/.cache/multihost-gate/sl008/`. HEAD c4020d9a + uncommitted P3 delta.
- Before `phase-03-before/` (T0, immediately before the first edit; tree clean but for the vicinae deletion and this notes file). Counts 13 / 5 / 7. P2→T0 drift: `drvs`, `drvs-sets`, `system/`, `home/` all identical to `phase-02/`.
- After `phase-03/` (= **PHASE-04's baseline**). Drift check: HEAD archive evaluated now = T0 `drvs` → no drift; `phase-03-before/` is the before.
- `drvs`: only `homeConfigurations.david` and `homeConfigurations.david@Sleipnir` differ. `david@Draupnir`, `darwinConfigurations.*`, `templates.*`, system: identical.
- `drvs-sets`, `coverage`, `diff -r system/`: identical.
- Sleipnir home `packages`, `home-path-links`: identical. Every `.config/systemd/user/` line identical.
- `home-files-links`: one derived-hash line, `.manpath -> …9wxn0fxp…-hm_.manpath` → `…vjxbqkqp…-hm_.manpath`. Content differs only in the `man-cache` hash on the MANDB_MAP line; masked diff empty (`phase-03/evidence/manpath.masked.diff`, raw `manpath.raw.diff`). Meets the derived-hash rule.
- Collision watch, before = after (counts and lines): `bin/foot` 1 system / 1 home; `bin/swaybg` 1 system; swaybg + tailscale-systray + systembus-notify units 3; `graphical-session.target.wants/swaybg.service` 1; `share/icons/Bibata-` 1764 system lines; `.icons/default/index.theme` 1; `.icons/phinger-cursors-light/` 544. No winner flip.
- `order-only` (fixed checker) on `david@Sleipnir` and `david`: ORDER-ONLY (9/9 drvs in one closure only). `nix-diff` (`phase-03/nix-diff.david@Sleipnir`) bottoms out at `home-manager-path` `__json`, `man-paths` `__json` and `david-fish-completions` `paths`, as predicted. Draupnir: identical.
- `just gate` green (fmt 0 changed); `nix fmt --no-write-lock-file -- --no-cache` 0 changed; flake.lock unchanged.
- Checker fix (T0b): `order-only`'s `norm()` gained `pathlist` (sort space-separated store-path strings); the pre-fix copy is kept as `order-only.pre-p3`. Regressions: P2-before self → ORDER-ONLY; P2 pair → ORDER-ONLY (was NOT before the fix); P2 Sleipnir vs Draupnir → NOT ORDER-ONLY, exit 1.

### Negative controls
Under `phase-03/controls/` (`<name>/` link maps, `<name>.result`). Each a temporary inline module in Sleipnir's `features.nix` imports; restored by file copy, `cmp` equal, Sleipnir home drv equal to `phase-03/drvs`.
- `core-off` (core, obs and all six compositors `mkForce false`; resolved without refusal): no swaybg / tailscale-systray / systembus-notify units, no swaybg wants link, no `.icons/phinger-cursors-light/`, no `.icons/default/index.theme`, no `share/icons/phinger-cursors-light/` (544 in the positive). Liveness: `bin/firefox` present. **Mismatch 1:** the sheet expected `home.pointerCursor` to print `null`; it prints the submodule with `enable = false`, `name`/`package` undefined, `x11.defaultCursor = "left_ptr"`. The pinned HM declares `home.pointerCursor` with `default = { }` (`modules/config/home-cursor.nix:142-145`), so that is its unset state. The closure result is the authoritative one.
- `niri-off`: swaybg unit, its wants link and tailscale-systray unit **still present** (ISS-008 fixed). Liveness: `bin/nirius|vicinae` 0 (2 in the positive).
- `obs-off`: `packages` differs from `phase-03` only by `wrapped-obs-studio-32.2.2`. **Mismatch 2:** the sheet's pattern `-i 'obs-studio|wlrobs|^bin/obs '` still matches 2 `home-path-links` lines: fontawesome `brands/obs-studio.svg` icons inside mermaid-cli, present in the positive too. Target-anchored check (`-> /nix/store/<hash>-(wrapped-obs-studio|obs-studio|wlrobs)`): 0 off vs 500 positive; `home-path-links` delta has no non-obs line; `home-files-links` differs only on the derived `.manpath` line.

### Assumptions and deviations
- A1 (D1 confirmed by the orchestrator): `editors.nix` keeps `sublime-merge` (+ `# obsidian`), `office.nix` keeps `mpris-timer`, `rssguard`; `graphics.nix` keeps `yed`, `drawio`. No package lost (`packages` identical).
- A2/A3 taken: `core.nix` is `{lib, ...}:`, called with `{inherit lib;}`; areas after `shell`: editor notes web media graphics comms terminal.
- A4–A6 taken. obs-studio.nix's comment rides above the `obs` record.
- `services.*` in `core/home.nix` kept as separate keys (statix did not ask to merge).
- README: the `default.nix` area list wraps onto a second line instead of one ~150-column line.

Verdict: P3 row: order only — Sleipnir home packages and home-path-links identical, one derived-hash line (`.manpath`); system, coverage, Draupnir identical.

## PHASE-04
Status: executed; gate (T8) passes the P4 row; **STOP 6 raised in T9** (one
sheet expectation in `scm-off` does not hold, see § Negative controls), not
adjudicated by the worker. Uncommitted P4 delta on top of 1f037235. Worker
model: opus.

### Tests
- T1 red (before any feature edit): only `testSleipnirHomeSelection` failed,
  `expr` = 16 `true` (the P3 tags) then 38 `false` (the P4 tags), exactly as
  predicted. Every other test green. Unchanged after T2 and T3.
- T4: `just test` green (`runTests` `[]`, script tests ok).
- T6: `nix fmt --no-write-lock-file -- --no-cache` 0 changed; flake.lock
  unchanged; `just gate` exit 0.

### Completeness (EX-5)
Checker `~/.cache/multihost-gate/sl008/completeness.nix`, unchanged.
- T0 mapping self-check against the HEAD archive
  (`phase-04-before/completeness-mapping.json`): `mapping` sameDrvs and
  sameNames true, 285/285 (x86_64-linux), 185/185 (aarch64-darwin).
- T5 (`phase-04/completeness.json`), both systems: `mapping`, `union`, `base`,
  `nixos` all sameDrvs = sameNames = true; `union.missing`/`extra` `[]`;
  `missingFeatures` `[]`; `misplaced` `{}`; `union.counts` [285,285] Linux,
  [185,185] darwin.

### Gate snapshots
Under `~/.cache/multihost-gate/sl008/`. HEAD 1f037235 + uncommitted P4 delta.
- Before `phase-04-before/` (T0, immediately before the first edit; tree
  clean but the vicinae deletion and untracked observation records). Counts
  13 / 5 / 7. P3→T0 drift: `drvs` and `drvs-sets` identical to `phase-03/`.
  Every eval re-resolved the nested emacs-overlay to 9e88531 (2026-10-16), in
  the before and the after alike; no effect on any line.
- After `phase-04/` (= **PHASE-05's baseline**). Drift check: HEAD archive
  (`head-tree/`) evaluated now = T0 `drvs` → no drift; `phase-04-before/` is
  the before.
- `drvs`: only `homeConfigurations.{david,david@Sleipnir,david@Draupnir}`
  differ. `nixosConfigurations.Sleipnir` **identical** (NixOS list inlined in
  the old order), `darwinConfigurations.Draupnir`, `templates.*`,
  `packages.*`, `legacyPackages.*` identical.
- `drvs-sets` (both homes included), `coverage`, `diff -r system/`: identical.
- Sleipnir home `packages`, `home-path-links`: identical. Every
  `.config/systemd/user/` line identical.
- `home-files-links`: one derived-hash line, `.manpath -> …vjxbqkqp…-hm_.manpath`
  → `…iz8gx94w…-hm_.manpath`; content differs only in the `man-cache` hash
  on the MANDB_MAP line; masked diff empty
  (`phase-04/evidence/manpath.masked.diff`, raw `manpath.raw.diff`). Meets
  the derived-hash rule (packages/home-path-links/units identical;
  order-only passes).
- Collision watch (`bin/(git|trash|emacs|emacsclient|nvim|vim|tmux|yazi|mcfly|viu|xxd)`):
  before = after (`phase-04-before/collision-watch`); `bin/git` →
  git-with-svn (gitFull, hiPrio), `bin/trash` → trashy (hiPrio). `bin/foot`
  1 system / 1 home; swaybg, tailscale-systray, systembus-notify units 6
  matching lines, unchanged.
- `order-only` on `david@Sleipnir` (= `david`): ORDER-ONLY, 9/9 drvs in one
  closure only, 0 sources. `nix-diff` (`phase-04/nix-diff.david@Sleipnir`)
  bottoms out at `home-manager-path` `__json`, `man-paths` `__json`,
  `david-fish-completions` `paths`, as in P3.
- `order-only` on `david@Draupnir`: ORDER-ONLY, 12/12 drvs in one closure
  only, 0 sources. First Draupnir home move of the slice. `nix-diff`
  (`phase-04/nix-diff.david@Draupnir`) bottoms out at `home-manager-path`,
  `home-manager-fonts`, `home-manager-applications` and `man-paths`
  (`__json`), and `david-fish-completions` (`paths`). Not built (darwin).
  Residual: `order-only` sorts every list, so it cannot see a buildEnv
  winner change between byte-identical files at one path on darwin; the
  Linux link maps show none on Sleipnir, and Draupnir's package multiset is
  identical (`drvs-sets`).

### Negative controls
Under `phase-04/controls/` (`<name>/` link maps, `<name>.result`,
`control.sh`). Each a temporary inline module in the host's `features.nix`
imports, resolved without refusal. Restored by file copy; `cmp` equal to
`*.orig`; all three home drvs equal to `phase-04/drvs`.
- T0 positive pre-checks (`phase-04-before/home/`): `bin/{emacs,nvim,lazygit,jj,git,tmux}`
  1 each; `.config/systemd/user/emacs.service` 1; `EDITOR` in
  `hm-session-vars.sh` 1.
- `emacs-off`: `bin/emacs` 0, `emacs.service` 0, `EDITOR` in
  hm-session-vars.sh 0. Liveness `bin/nvim` 1. Pass.
- `neovim-off`: `bin/nvim` 0. Liveness `bin/emacs` 1. Pass.
- `scm-off`: `bin/jj` 0; `bin/git` present, target moved from
  git-with-svn (gitFull) to plain `git-2.55.0` (the base's). `packages` diff
  vs `phase-04/` removes exactly dev.scm's 19 drvs (incl. gitFull, gitui,
  sublime-merge) and adds nothing. **Mismatch (STOP 6):** the sheet expects
  no `^bin/(lazygit|jj) ->`; `bin/lazygit` is **still present**, same
  target as before. Cause: the base also installs lazygit through
  `programs.lazygit.enable = true` (`modules/home/nushell.nix:73`);
  `config.programs.lazygit.package` is the same drv
  (`l49sfspy…-lazygit-0.66.1.drv`) that dev.scm lists, and `packages` is a
  unique set, so it shows one lazygit drv with or without dev.scm. Evidence
  appended to `scm-off.result`. Left for the orchestrator.
- `utils-off`: `bin/tmux` 0; liveness `bin/asciinema` 0 (1 in `phase-04/`). Pass.
- `markdown-off` (Draupnir, eval only): `glow` in `home.packages` names 1
  before, 0 with the control; liveness `jq` 1. Pass.
- `head-tree/` kept (sheet removes it after T9; T9 has an open STOP).

### Assumptions and deviations
- A1–A8 taken as written. A1: base `cli.nix` in the design table's order with
  one `## <bucket>` comment per group. A3: area list as given.
- Comments: added group headers where a record mixes sources
  (`## dev introspection`, `## shell scripts` in dev.tools; `## network` in
  `modules/nixos/cli.nix`, where net.nix's linuxSystem list had none), and
  a one-line note above `text.dictionary` on why sdcv/web1913 are unguarded.
- `editor.neovim`'s record carries a comment (modules the record owns).
- Git rename: the index keeps `modules/home/shared/emacs.nix →
  features/editor/emacs.nix` (staged by `git mv`, content not yet staged);
  against the working tree the rewrap falls under 50% similarity, so
  `git diff HEAD -M` shows add + delete. nvim.nix and nvim-plugins.nix stay
  pure renames.
- `git grep` for stale paths: only `features/desktop/core.nix:11`
  (`wayland_packages.nix`, a false positive on `_packages`) after T7.

Verdict: P4 row: order only. Both homes' drvs-sets identical; Sleipnir
packages and home-path-links identical, one derived-hash line (`.manpath`);
Draupnir ORDER-ONLY; system identical; completeness equal on both systems.
T9: four controls pass; `scm-off` fails its sheet expectation on
`bin/lazygit` only (base `programs.lazygit`), STOP 6 for the orchestrator.

### Orchestrator verdict
STOP 6 (scm-off kept bin/lazygit) adjudicated as a mis-specified control
expectation: the home base also installs the same lazygit drv via
programs.lazygit (modules/home/nushell.nix:73); not a regression.
Committed 5ddfdf05.

## PHASE-05
Status: executed; gate (T6) passes the P5 row; controls (T7) pass. No STOP.
Uncommitted P5 delta on top of 5ddfdf05. Worker model: sonnet (orchestrator
rationale: whole-record moves with fully tabulated tests; gate judgement not
delegated). Where the sheet and design.md/plan.toml differ, the latter win;
no difference was found.

### Tests
- T1 red (before any record existed; `personal-linux.nix` written first, D1):
  `testSleipnirHomeSelection` 54 `true` then 7 `false`; `testPersonalRequires`
  `[false x6]`; `testPersonalLinuxOnDarwinFails` `[false false]`;
  `testAlarmIsHostSelected` `[false false]`. `testPersonalSelectsPortable` and
  `testDraupnirSelection` green (guards, D3). Every other test green. All as
  predicted.
- T2: only `testSleipnirHomeSelection` still red (54 true, 7 false); the three
  profile tests green; script tests (incl. nudge from its new path) not yet
  reached (the run stops at the failed check), then ok after T3.
- T3: `just test` fully green (resolver, factories, snooze, dictate, nudge).
  Sleipnir and Draupnir home drvPaths evaluate; Draupnir's equals the T0 one.
- T4: `nix fmt` (first run reformatted my 5 new/rewrapped files; second run 0
  changed), flake.lock unchanged, `just gate` exit 0, no statix/deadnix output.

### Gate snapshots
Under `~/.cache/multihost-gate/sl008/`. HEAD 5ddfdf05 + uncommitted P5 delta.
- Before `phase-05-before/` (T0). Counts 13/5/7. P4->T0 drift: `drvs` and
  `drvs-sets` identical to `phase-04/`. Drift check (HEAD archive evaluated
  after the after-snapshot) = T0 `drvs`: no drift; `head-tree/` removed.
- After `phase-05/` (= **PHASE-06's baseline**).
- `drvs`: only `homeConfigurations.david` and `homeConfigurations."david@Sleipnir"`
  differ (`0d322z0i…` -> `pyfwib7y…`). `david@Draupnir`, `nixosConfigurations.Sleipnir`,
  `darwinConfigurations.Draupnir`, templates, packages, legacyPackages identical.
- `drvs-sets`, `coverage`: identical. `diff -r system/`: empty.
- Sleipnir `packages`, `home-path-links`: identical.
- `home-files-links`: two lines differ. (a) `.config/systemd/user/nudge.service`
  (new store path); `nudge.timer` and `timers.target.wants/nudge.timer`
  identical. (b) derived-hash line `.manpath -> …iz8gx94w…-hm_.manpath` ->
  `…i6simqcf…-hm_.manpath`; masked diff empty
  (`phase-05/evidence/manpath.masked.diff`, 0 bytes; raw 210 bytes). Meets the
  rule: packages/home-path-links/units identical, `order-only` names only
  nudge.service. Every other unit line identical.
- nudge unit diff (`evidence/nudge.service.diff`): `ExecStart` only,
  `…/flakes/modules/home/linux/nudge/main.nu` -> `…/flakes/features/attention/nudge/main.nu`;
  old-path count 0, new-path count 1.
- Collision watch (15 lines): before = after. `bin/foot` 1 system / 1 home.
- `order-only` on `david@Sleipnir` (`phase-05/order-only.david@Sleipnir`):
  NOT ORDER-ONLY, 10 drvs each side, unmatched exactly `- nudge.service` /
  `+ nudge.service`, 0 sources. `nix-diff` of the two `nudge.service` drvs
  (`evidence/nix-diff.nudge.service`): only the `text` ExecStart path. Full
  diff `nix-diff.david@Sleipnir`.
- Draupnir's line did not move, so no order-only on it.

### Negative controls
Under `phase-05/controls/` (`control.sh`, `*.orig`, `<name>.result`; probe
dirs for the two Sleipnir ones). Restored by file copy; `cmp` equal; home
drvs equal `phase-05/drvs`.
- T0 pre-checks (`phase-05-before/home/home-files-links`): nudge.{service,timer}
  + timers.target.wants/nudge.timer 3 lines; satan-{patcher,attrd}.service
  4 lines; panopticon-sway.service 1. Owners: `services.nudge`/`timers.nudge`
  only in nudge.nix; `satan-patcher` only the flake input and satan-patcher.nix;
  `nudge` and `satan-patcher` both in `config.systemd.user.services`.
- `nudge-off` (Sleipnir): nudge lines 0; liveness panopticon-sway 1. Pass.
- `patcher-off` (Sleipnir): satan-patcher lines 0; liveness satan-attrd 2
  (service + wants). Pass.
- `browsers-on-mac` (Draupnir): before the control the home drvPath equals
  `phase-05/drvs`; with it, `feature selection failed:` and exactly one bullet,
  `feature.web.browsers is selected but does not support aarch64-darwin (platforms: …)`. Pass.
- `postgres-off` (Sleipnir): pre-check drvPath matches; with the control,
  exactly two bullets, `satan.patcher` and `satan.attrd` each `requires
  feature.services.postgresql, which is not selected`. Pass.

Verdict: P5 row: order only plus the nudge path. Sleipnir packages and
home-path-links identical; home-files-links differs on nudge.service
(ExecStart path only) and `.manpath` (derived hash, masked diff empty);
Draupnir, system, coverage identical.

### Assumptions and deviations
- A1–A9 taken as written. Git kept the pure renames (nudge/, alarm and doctor
  scripts); the rewrapped modules show as renames with modification in the
  index but fall below similarity against the working tree (R7, cosmetic).
- A9: `modules/home/linux/bin/` held a second untracked generated dir,
  `.ruff_cache`; moved with `__pycache__` into `phase-05/evidence/`, then
  `rmdir bin`. Not in the sheet.
- `ALARM.md:3` also named `modules/home/nixos/alarm.nix` (sheet listed `:7,9`);
  fixed so the sheet's own stale-path grep is empty.
- justfile `test` comment reworded (nudge is now under `features/`, so the
  "and modules/home/linux/nudge/" clause is dropped).
- `testAlarmIsHostSelected` and `testPersonalSelectsPortable` use `ok &&`
  guards; the unguarded resolve inside is only reached when `ok`.
- R6: `~/.config/emacs/CHANGELOG.md:568` names the old directory (history),
  not touched.
