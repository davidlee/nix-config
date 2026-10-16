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
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-16 · close

### Produced
- PHASE-01..07 done — resolver platforms, home base + layers, features by function, personal profiles, home coverage + isolation, availability filter (commits 1391fcc6, c4020d9a, 1f037235, 5ddfdf05, 0d7dd406, ff4a0746, 8cb4a79b..d2f5f0f3)
- RV-018 — audit ledger, 18 findings, reconciliation brief in review-018.md
- registry: PHASE-01 source delta bootstrapped (`slice record-delta 8 PHASE-01 --commit 1391fcc6`)
- minted: IMP-026 — lazygit to dev.scm; IMP-027 — clangStdenv/binutils in dev.build; CHR-015 — Draupnir link-map check (VH-2)
- owned elsewhere: CHR-001 — modules/DESIGN.md; IMP-019 — probe .manpath normalisation

### Learned
- promoted at close: mem.fact.flakes.availableon-limits, mem.fact.flakes.home-gate-derived-hash, mem.fact.flakes.hm-darwin-halves

### Open
- none for SL-008. Follow-ups: IMP-026, IMP-027, CHR-001, IMP-019. RV-017 (design review) left `active · await=raiser` (pass waived).
- closed: REV-007/008 done; DEC-006/024/036, RFC-001 reconciled; CHR-015, IMP-016, ISS-008 resolved; VH-1 user choice, VH-2 user-verified.

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

## PHASE-06

Status: all tasks T0-T7 done, gate green, no STOP. Worker model: sonnet
(claude-sonnet-5-5). Uncommitted P6 delta on HEAD 0d7dd406. Plan/design
authoritative over the sheet; no disagreement found.

### Gate snapshots

- Before: `~/.cache/multihost-gate/sl008/phase-06-before/` (drvs, drvs-sets,
  coverage, `system/`, `home/`, `local-input-refs`). P5->T0 drift: none.
  After: `.../phase-06/` (PHASE-07's baseline; `coverage` has 8 lines).
- Drift check (HEAD archive `drvs` vs before): identical, no drift. Archive removed.
- Counts: drvs 13, drvs-sets 5, coverage 8 (was 7).
- `diff drvs`, `diff drvs-sets`: empty. `diff coverage`: exactly
  `> coverage.home@aarch64-linux /nix/store/10vf1bdn52y2mdk0xg6p22cbza9v60mh-home-manager-generation.drv`.
  `diff -r` of `system/` and `home/` probes: empty.
- `coverage.err` ends with `isolation: coverage."home@aarch64-linux" ok` and
  `isolation: homeConfigurations."david@Draupnir" ok`; `just coverage` exit 0.
- T6e (`phase-06/evidence/isolation-drvpaths`): stubbed == unstubbed for both
  targets; Draupnir's equals its `drvs` line (`ni5xsrc2...`), home-base's its
  new `coverage` line (`10vf1bdn...`).
- `just gate` exit 0; `nix fmt` second run 0 changed (first reformatted the
  stub to `{outputs = _: {};}`); `flake.lock` unchanged after every task.

### Red evidence

- T2: `just isolation` before the target: `coverage."home@aarch64-linux"`
  FAILED (`flake ... does not provide attribute ...coverage."home@aarch64-linux"...`),
  Draupnir ok, exit 1.
- T4: `just coverage` with new target, old pick: eval error through
  `concatStringsSep` in `_drvs` (nixos_pick on a home); first line `error:`.
  After `coverage_pick`: 8 lines, exit 0.

### Negative control (VA-1)

- Owners (T0c, `phase-06-before/local-input-refs`): exactly 7 refs, all
  `.packages`/`.homeManagerModules`: attention.nix:76,80 (goad), attention/behaviour.nix:19
  (panopticon), satan/attrd.nix:28,32, satan/patcher.nix:28,32. Nothing in
  `modules/home` or `hosts/Draupnir`.
- Control: `feature.attention.goad.enable` resolved into the target's modules.
  Unstubbed (`controls/goad-unstubbed.result`): `attribute 'aarch64-linux'
  missing` at attention.nix:80 (goad's real flake has no aarch64-linux
  packages; R7), i.e. differs from the stubbed error. Stubbed
  (`controls/goad-on.result`): `attribute 'homeManagerModules' missing` at
  attention.nix:76:30; `home@aarch64-linux` FAILED; Draupnir ok; exit 1; no
  other input named. As expected.
- Restore by `cp` from `controls/hosts.nix.orig`; `cmp` ok; `just isolation`
  two ok lines, exit 0; lock unchanged.

### Verdict

P6 row: coverage gains one line (home@aarch64-linux); all drvs and drvs-sets
identical; isolation passes; the goad control fails on goad's
homeManagerModules only.

### Assumptions and decisions

A1-A5 taken as written. D1-D4 as ruled: target calls `homeManagerConfiguration`
directly (mkHome untouched); stub path absolute via `stub := "path:" +
justfile_directory() + "/features/stub"`; isolation reports on stderr only;
one `nix eval` per target. Files: hosts.nix, justfile, README.md,
features/stub/flake.nix (new, `git add -N`).

## PHASE-07

### Block A status: DONE (T0-T3), uncommitted. Worker: sonnet (second worker finished T2/T3).

Done (uncommitted, source only): T0 baseline `phase-07-pre/`; T1 `features/cli-broken.nix` + `features/available.nix`; T2 all 29 guards + `modules/nixos/cli.nix` converted; T3 Draupnir delta + VA-1. Snapshot `~/.cache/multihost-gate/sl008/phase-07a/` (drvs 13, drvs-sets 5, coverage 8, probe) is Block B's before.

Decisions: A4 names via `lib.getName` (plain data). A5 helper in separate `features/available.nix`. A6 `a ++ available pkgs [linux...]`.

**Plan adaptation (orchestrator ruling, DEC-036 conformant):** EX-1 list extended from [watchman atuin] by four eval-time failures on aarch64-darwin, added to `cli-broken.nix` with reasons: `gtt` (alsa-lib), `udiskie` (libappindicator-gtk3), `micro` (= micro-with-wl-clipboard; wayland; `lib.getName` returns pname `micro`, not `micro-wrapped`), `fsearch` (meta.broken). availableOn sees only a package's own meta.platforms. No change to available.nix semantics. Evidence: `phase-07a/evidence/eval-fail`, `eval-fail-errors`.

Gate results: `just gate` green; fmt 0 changed; flake.lock unchanged. Sleipnir: drvs and drvs-sets lines (system, home, david) identical to phase-07-pre; `pkgs.Sleipnir` identical; probe `system/` and `home/` `diff -rq` empty. Coverage 8 lines identical, exit 0, isolation `coverage."home@aarch64-linux"` ok and `homeConfigurations."david@Draupnir"` ok. Only changed lines: Draupnir home drv (`pc3p64c2...`) and set (208 -> 265, +57).

Draupnir gained (57; no removals; watchman, atuin, gtt, udiskie, micro, fsearch absent): await binutils-wrapper ccache cheat circumflex clang cmatrix csv-tui d2 drawio emacs-all-the-icons-fonts fastfetch ffmpeg-full fltrdr fortune-mod ghostscript gitui git-with-svn gtop hexyl htop hyperfine kakoune kakoune.cr kakoune-lsp kb killall-shell_cmds latex2html lld lldb llvm mermaid-cli mprocs nb nerd-font-patcher nms pandoc-cli pinfo procs pstree pueue resvg russ sn0int stdenv-darwin stress-ng structurizr-cli tdf tealdeer tpnote tui-journal tuisky tut ueberzugpp wiki-tui xxd-tinyxxd yEd. Delta: `phase-07a/evidence/draupnir-delta`.
Spot checks: gained `htop-3.5.3` (system.monitor) present; excluded `tray-tui` and `wtf` (same list) absent, `availableOn` false on aarch64-darwin.

stdenv-darwin / binutils-wrapper: from `dev.build` (features/dev.nix ~58-66): `clangStdenv` resolves on darwin to `stdenv-darwin` (the stdenv itself, a derivation that is not useful as a user package), and `binutils` resolves to `binutils-wrapper-2.46` (the cctools wrapper; `clang`, `lld`, `llvm`, `lldb` from libclang/llvm entries are real tools). Bare `gcc` is unguarded and was already `gcc-wrapper` on Draupnir. FINDING: `clangStdenv` in home.packages is a pre-existing oddity on Linux too (a stdenv, not a tool); on darwin it gains a stdenv-darwin entry. Intended by the availability rule but arguably unintended content; not fixed. `binutils-wrapper` may collide with darwin cctools `bin/ld`/`ar` etc. (R4/VH-2).

### VA-1 (cache.nixos.org, aarch64-darwin outPaths of the 57 gained)
55 cached. UNCACHED (for VH-1): `killall-shell_cmds-329` /nix/store/wpjr4ml6rry1arkkpqx9i6ha1kx0724c-killall-shell_cmds-329; `yEd-3.25.1` /nix/store/7k8hz835dpfnyackb56g7my96j6rzik3-yEd-3.25.1. Evidence `phase-07a/evidence/va1-cache`. User choice: add to `cli-broken.nix` aarch64-darwin, or accept a local build.

### Block B status: T4-T7 done, uncommitted; one item blocked (break-remind deletion). Worker: opus (orchestrator rationale: Block B carries the correctness judgement: collision-winner call for yazi/mcfly, classification of every Sleipnir probe diff, the Close checks).

Blocked: `git -C ~ rm flakes/modules/home/linux/break-remind.nix` was denied by the auto-mode classifier ("Irreversible Local Destruction"), although the sheet allows it. The file is still in the tree and tracked; nothing imports it, so no eval is affected. The orchestrator must run that one command. Until then `ls modules/home/linux` shows `break-remind.nix` in addition to the listed files; every other Close check passes. Evidence the file is dead: `git grep break-remind -- flakes ':!flakes/.doctrine'` finds only the file itself.

Files changed (source): features/media.nix, features/files.nix, hosts/Sleipnir/doctor.nix, features/profiles/workstation.nix, features/profiles/personal-darwin.nix, hosts/Draupnir/features.nix, README.md.

#### Gate snapshots (Block B)
- Before: `~/.cache/multihost-gate/sl008/phase-07a/`. Drift check: the tree was clean at HEAD 8cb4a79b, and a fresh `just drvs` matched `phase-07a/drvs` line for line before any edit: no drift (the emacs-overlay rev did move, 3d05567 -> 9e88531, without effect on the drvs). After: `.../phase-07b/` (drvs 13, drvs-sets 5, coverage 8, probe `system/` `home/`, `pkgs.*`, `evidence/`).
- `drvs` vs 07a: only `homeConfigurations.{david,david@Sleipnir,david@Draupnir}` differ (intended). `nixosConfigurations.*`, `darwinConfigurations.Draupnir`, `packages`, `legacyPackages`, `templates` identical.
- `drvs-sets` vs 07a: nixos and darwin lines identical; Sleipnir home and `david` 345 -> 341; Draupnir home 265 -> 263.
- `coverage`: 8 lines identical to 07a; exit 0; `coverage.err` ends with both `isolation: ... ok` lines.
- Probe: `system/` `diff -r` empty. Home `packages` (a unique drv set) identical, as expected (the removed drvs stay present once). `home-path-links` identical (also the collision-watch lines vs `phase-07-pre/collision-watch`). User-unit lines identical.
- `just gate` exit 0; `nix fmt` 0 changed on both runs; `flake.lock` unchanged.

#### Intended differences
Sleipnir `pkgs_of` multiset diff vs 07a (4 lines removed, nothing added):
- `mcfly-0.9.3` (drv 6fnj2km2...) , `/nix/store/azpm0dj1...-mcfly-0.9.3`: files.search entry. HM's `programs.mcfly` entry (same drv) remains.
- `yazi-26.9.1` (drv 6h4csnqs...), `4gqw5a1s...-yazi-26.9.1`: files.manage entry. HM's `programs.yazi` entry (same drv) remains.
- `mpv-with-scripts-0.41.0` (drv i021kmw9...): the second mpv in media.players (same drv twice in one list).
- `viu-1.6.1` (drv znzdxkhd...): media.players' viu; media.view's remains.
Sleipnir `home-files-links` diff vs 07a (3 lines; EX-4 and one derived):
- `.local/bin/sleipnir-doctor`: `.../992l01z8...-hm_sleipnirdoctor` -> `.../5npyrkb5...-sleipnir-doctor`.
- `.config/sleipnir-doctor/checks.d/panopticon`: `.../bq60qbsr...-hm_sleipnirdoctorpanopticon` -> `.../62wfjadh...-sleipnir-doctor-panopticon`. Both shebangs now `#!/nix/store/lb41b0an...-python3-3.14.7/bin/python3.14`.
- `.manpath`: `hm_.manpath` hash moved because `home-path` (hence its `man-cache`) has a new derivation. Content differs only in the `man-cache` store hash: masked diff empty, `phase-07b/evidence/manpath-raw`, `manpath-masked` (P4 derived-hash rule).
- `checks.d/emacs` unchanged (bash provider, left as is).
Draupnir `pkgs_of` diff vs 07a: exactly the same `mcfly` and `yazi` removals (Draupnir drvs ww6hwm4b / pfma0xm7 variants); its mpv and viu were not selected (media.players is Linux-only). Draupnir keeps one `yazi` and two `mcfly` entries, from HM programs. Draupnir gains nothing in Block B.

#### EX-3 decisions
- yazi: current winner `bin/yazi`, `bin/ya` -> `4gqw5a1syvf51b4h4l3vc1q57ylfbvwv-yazi-26.9.1`. `programs.yazi.package.outPath` = the same path; both entries in `pkgs.Sleipnir` had the same drv. TAKEN (removed from files.manage). Evidence `phase-07a/evidence/hm-programs`; after removal the links are identical.
- mcfly: winner `bin/mcfly` -> `azpm0dj1...-mcfly-0.9.3` = `programs.mcfly.package.outPath`; same drv. TAKEN (removed from files.search).
- mpv (second) and viu (players): same drv twice in one list; removed. No row dropped.
- Because the bare and HM packages are the same derivation, removal cannot flip a winner on Sleipnir; `home-path-links` identical confirms it. Draupnir: HM programs are in the base, so the same holds there (an identical drv on aarch64-darwin too, from the two entries in `pkgs.Draupnir`).

#### Close checks (design § Close)
- `profiles/`, `darwin/home.nix`, `modules/shared/cli/`: gone.
- `modules/home`: cli darwin default linux nushell programs shpool zsh (.nix). `modules/home/linux`: default eca chatgpt bough slk helix, plus `break-remind.nix` pending the blocked `git rm`.
- Stale-path `git grep -En` (design pattern): nothing. `isLinux`/`isx86` in `features` and `modules/nixos/cli.nix`: nothing.
- `sleipnir-doctor` run from the built store path: exit 0, 73 lines of checks (`phase-07b/evidence/doctor-run.out`); panopticon provider exit 0, JSON (`panopticon-run.out`); shebang evidence `doctor-shebang`.

#### VA-2 verdict
Walked the P7 table: availability (Sleipnir sets identical, Draupnir +57 in 07a, none in B), brokenOn (watchman/atuin and the four added names absent), isx86 (system lines identical, `base@aarch64-linux` coverage line identical), doctor (runs), duplicates (home-path-links identical), break-remind (only the blocked delete remains), docs (README, workstation.nix, Draupnir features, personal-darwin). Every difference is in the table. Verdict: matches the table, with the break-remind `git rm` outstanding.

#### Plan adaptations and decisions (Block B)
- EX-4 says "three"; `sleipnir-doctor-emacs` is bash (orchestrator ruling): only the two python scripts get the pinned interpreter. Shape: `pkgs.writeScript` over `builtins.replaceStrings` of the shebang with `pkgs.python3.interpreter`, one helper `pinnedPython` in doctor.nix (A8).
- EX-3: both yazi and mcfly taken (above).
- README: feature tree gains `available.nix` and `cli-broken.nix`; the platforms paragraph gains the availability-filter paragraph; the Coverage paragraph (P6 wording) gains the `home@aarch64-linux` sentence. Hosts table needed no change (still accurate).

#### Findings
- `clangStdenv` in `dev.build`'s home.packages is a stdenv, not a tool (`stdenv-darwin` on Draupnir). Out of scope; recorded only.
- `just probe`'s `packages` file is a unique drv set, so it cannot show a duplicate-entry removal; `pkgs_of` multiset diff is the proof for EX-3.

### Pending user (VH-1, VH-2) -- both resolved 2026-10-16

2026-10-16 VH-2 VERIFIED by the user ("VH-2 accepted"). Draupnir link-map compare (current generation vs probe of 773f7dc9+, package-name join): two flips, both priority-decided and identical to Sleipnir's home -- `bin/git` + all git files `git` -> `git-with-svn` (`hiPrio gitFull`, dev.nix:34, newly available on darwin); `bin/cpp` `gcc-wrapper` -> `clang` (prio 5 < 10). Lost: plain `git` (wins no file). Gained: the expected PHASE-07 set incl. `stdenv-darwin` (IMP-027). The toolchain-in-home question (cpp) is IMP-027's. Probe fixes for darwin: 0c6ddad7. CHR-015 resolved. REV-007/REV-008 approved by the user ("accept revs"), apply at reconcile.

2026-10-16 VH-2 first result: Draupnir home build failed -- binutils-wrapper-2.46 and gcc-wrapper-16.2.0 both priority 10, colliding on bin/strings (and ar, nm, strip, …). Fixed by skipping `binutils-wrapper` on aarch64-darwin in cli-broken.nix (gcc-wrapper ships the cctools tools there). Pre-check: listed bin/ of every Draupnir home package from cache.nixos.org (238 of 293 outputs listable); other duplicate names resolve by priority (git-with-svn -10, clang 5 < gcc-wrapper 10, net-tools 5 over inetutils 7) or are false positives (libressl is only `nc`). 55 uncached/bin-less outputs unchecked.


2026-10-16 user decisions: VH-1 -- skip both builds; `shell_cmds` (getName of killall) and `yEd` added to `cli-broken.nix` aarch64-darwin (Draupnir home 263 -> 261 packages; `just test`, `just coverage` + isolation green). VH-1 resolved by user choice. VH-2 deferred to audit/next Draupnir switch (user). `break-remind.nix` deleted by the user (1142eae6). PHASE-07 delta recorded as range ff4a0746..HEAD (includes user commits e7bfec60/8dbfd01c; 8dbfd01c only deletes the vicinae settings file, outside SL-008). DEC-024 draft consequence: user assents; apply at reconcile.

VH-1 (user decides, per uncached package): `killall-shell_cmds-329` (/nix/store/wpjr4ml6rry1arkkpqx9i6ha1kx0724c-killall-shell_cmds-329) and `yEd-3.25.1` (/nix/store/7k8hz835dpfnyackb56g7my96j6rzik3-yEd-3.25.1); Block B changed no Draupnir package other than the yazi/mcfly removals (identical drvs remain via HM, already cached or built as before). For each: add its name to `features/cli-broken.nix` `aarch64-darwin`, or accept a local build at the next Draupnir `home-switch`. Commands to re-check: `awk '/^>/{print $4, $2}' ~/.cache/multihost-gate/sl008/phase-07a/evidence/draupnir-delta | while read out name; do nix path-info --store https://cache.nixos.org "$out" >/dev/null 2>&1 && echo "cached $name" || echo "UNCACHED $name $out"; done`. Expected: exactly the two UNCACHED lines above (cache state may have moved). Mark verified only on the user's choice.

VH-2 (on Draupnir, before activating the new home):
```sh
cd ~/flakes
just home-build        # or: nix build "path:$PWD#homeConfigurations.\"david@Draupnir\".activationPackage" $(just --evaluate home_override) --no-write-lock-file --out-link result-home
bin/gate-probe ~/probe-new 'homeConfigurations."david@Draupnir"'   # writes ~/probe-new/home-path-links
cur=$(readlink -f ~/.local/state/nix/profiles/home-manager)/home-path   # confirm it exists; else $(readlink -f ~/.nix-profile)
mk() { (cd "$1" && find -L . ! -type d -printf '%P\n' | LC_ALL=C sort | while IFS= read -r f; do printf '%s -> %s\n' "$f" "$(realpath -m -- "$f")"; done); }
mk "$cur" > ~/probe-cur-links
diff ~/probe-cur-links ~/probe-new/home-path-links
```
Look for: lines `bin/X -> A` on the left and `bin/X -> B` on the right where the package name differs (a flipped collision winner). Expected: every pre-existing link points at the same package name (store hashes may differ where a dependency moved); new links only for the 57 gained packages (and 07a's gains list). Inspect binutils-wrapper (gained, from dev.build) against darwin's cctools: `ld`, `ar`, `as`, `nm`, `strip`, `ranlib`, `size`, `strings`, `objdump`, `lipo`-class names are the likely collisions; also GNU vs BSD tools from gained `killall-shell_cmds`, `procs`, `htop`. A flipped winner is fixed forward with hiPrio/lowPrio (design :839-844, RV-017 F-7). Not verified by the worker.

### For the orchestrator
- Run `git -C ~ rm flakes/modules/home/linux/break-remind.nix` (denied to the worker), then re-check `ls modules/home/linux`.
- DEC-024 replacement `consequences` -- PENDING USER ASSENT; to be applied at reconcile (DEC-024 not edited): "A host importing workstation gets the Wayland desktop stack (desktop.core), pipewire, docker, snooze, the app formats, fonts and dictate. The profile is Linux-only through desktop.core's platforms (DEC-030), so a darwin host cannot import it: the resolver refuses a selected feature whose platforms omit the host's system."
