# Review RV-018 — reconciliation of SL-008

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

Mode: **conformance self-audit** (one agent drives raiser and responder with
`--as`). Surface reviewed: the primary tree (`~/flakes`, git worktree `$HOME`)
at head d2f5f0f3; SL-008 was not dispatched, so there is no candidate branch.

Phase commits: P1 1391fcc6, P2 c4020d9a, P3 1f037235, P4 5ddfdf05,
P5 0d7dd406, P6 ff4a0746, P7 8cb4a79b + 70c6aa3b + 1142eae6 + d2f5f0f3
(recorded as the range ff4a0746..d2f5f0f3).

Known foreign paths (not SL-008 findings, named so the undeclared cell reads
correctly): e7bfec60 (`.config/umbriel/*`, the user's umbriel work) and
8dbfd01c (deletes `flakes/.config/vicinae/settings.json`), both inside the
P7 range; 625075fe and 389fe91a (another agent's backlog commits) sit at
the P3 and P5 range starts and are excluded from those deltas.

Lines of attack:
1. **Path conformance.** `doctrine slice conformance 8` against the
   design-target selectors (design.md § Design-target selectors), read
   through ISS-005 (git-root vs doctrine-root prefix): strip `flakes/` and
   judge by hand.
2. **Gate invariants** (design § Phases and verification): P1 drvs identical;
   P2–P5 order only (probe identical); P6 one coverage line; P7 exactly the
   § Behaviour changes table. Evidence is the phase notes and
   `~/.cache/multihost-gate/sl008/`; re-run `just test`, `just gate`,
   `just coverage` (+ isolation) and `doctrine check gate` now.
3. **Design § Close** checks: removed paths gone, `modules/home` and
   `modules/home/linux` hold only the listed files, stale-path grep empty.
4. **Governance coherence**: ADR-002 / ADR-005 (REV-007, REV-008 proposed),
   DEC-006 (signature, stale `flags` body), DEC-024 (darwin consequence),
   DEC-036 (broken list), QUE-001, IMP-016, ISS-008.
5. **Design vs delivered divergences**: the plan adaptations in notes.md per
   phase, the "probe identical" seat ruling, P7 EX-4's script count, the
   cli-broken list, the lazygit control, the docs list (§ Code impact and
   docs).
6. **Code quality leads** from the orchestrators: lazygit declared twice,
   the P6 coverage target's duplicated `pkgs` line, `clangStdenv` in
   `dev.build`, `modules/DESIGN.md`, research staleness.

Invariants held: every package of the old buckets lands exactly once (P4
completeness); no collision winner flips; no home without the personal
profiles reaches a local-path input; spec/governance findings go to the
reconciliation brief (`design-wrong`), never the backlog.

Already decided by the user (recorded, not re-litigated): REV-007/REV-008
stay `proposed`, applied at reconcile; DEC-024's drafted darwin consequence
assented, apply at reconcile; DEC-006 signature and body fixed at
reconcile; VH-1 resolved (shell_cmds, yEd skipped on darwin, d2f5f0f3);
VH-2 deferred to the next Draupnir home-switch; the seat's "probe identical"
ruling (link maps, packages, home-path-links, user units identical;
derived-hash lines allowed with evidence).

## Synthesis

**Closure story.** SL-008 delivered what its design locked: a resolver that
reads a record's `platforms` and refuses an unsupported selection (P1); a home
base with Linux and darwin layers in place of `profiles/` and `darwin/home.nix`
(P2); every home module and cli bucket turned into a feature by function, with
`personal` / `personal-linux` / `personal-darwin` profiles (P3–P5); a headless
aarch64 home coverage target plus an isolation check that lean homes never
reach a local-path input (P6); and the one content phase, availability-filtered
cli lists (P7). Each phase's gate evidence is in notes.md and
`~/.cache/multihost-gate/sl008/`. Re-run at audit (head d2f5f0f3): `just test`
green, `just gate` rc 0 (treefmt 0 changed), `doctrine check gate` rc 0,
`just coverage` rc 0 with 8 lines and both isolation targets ok. Design
§ Close checks all pass: `profiles/`, `darwin/home.nix`, `modules/shared/` gone;
`modules/home` and `modules/home/linux` hold exactly the listed files; the
stale-path grep is empty.

```
SL-008 path through the system
  hosts/<h>/features.nix ─imports─> features/profiles/{workstation,personal*}.nix
            │                                   │
            └──────────> features.nix (resolve: tree, classes, system) ── refuses platforms ∌ system
                                   │
  hosts/<h>/home.nix ─> modules/home/{linux,darwin} ─> modules/home/default.nix (base)
                                   │
                         + selection.modules.homeManager  (mkHome, hosts.nix)
```

One behaviour worth knowing: the platform check (`features.nix`, a third
per-record assertion beside `requires` and "lands somewhere") reads only
`platforms` and never forces a module, so a Linux-only record selected on
Draupnir fails resolution with a message naming the system (P5
`browsers-on-mac` control). Tests: `testUnsupportedPlatformFails`,
`testPlatformsAbsentMeansAll`, `testBadPlatformsShapeFails`,
`testPersonalLinuxOnDarwinFails`, `testDesktopCoreLinuxOnly`
(`features-test.nix`, run by `just test`).

**Findings.** No blocker. The governance lag (F-14 REV-007/008, F-15 DEC-006 /
DEC-024 / DEC-036, F-16 QUE-001 / RFC-001 / IMP-016 / ISS-008) is by design:
REVs were raised before P1 and wait for reconcile. The design-text
divergences (F-3, F-4, F-5, F-6, F-7, F-18) are places where implementation
learned something the design did not know; each is a per-slice edit. Code
leads became owned backlog (F-8 IMP-026 lazygit, F-10 IMP-027 clangStdenv,
F-11 CHR-001 modules/DESIGN.md) or a tolerated, design-sanctioned shape (F-9).
F-1 (empty PHASE-01 registry row) was fixed in the audit. F-13 (README § Hosts
lacks the home base) is the one missed deliverable; it is a small docs commit
before close.

**Standing risks.**
- Draupnir's home link map is unchecked (F-17, CHR-015) until the user's next
  Draupnir home-switch. P7 added ~55 packages there, including
  `binutils-wrapper`, which may shadow cctools tools. The cache check (VA-1)
  and the user's VH-1 choice cover build cost, not collisions.
- `lib.meta.availableOn` admits packages whose dependencies are Linux-only;
  four such names were found by evaluation and listed in `cli-broken.nix`. A
  nixpkgs bump can add more; the symptom is a Draupnir eval failure, caught
  by `just drvs`.
- Conformance and VT attribution remain hand-judged until ISS-005 is fixed.

**Tradeoffs accepted.** The derived-hash gate rule (F-4) in place of literal
"probe identical"; the coverage target's one duplicated `pkgs` line (F-9);
lazygit staying in the base until IMP-026 (F-8).

**Sources that matter at reconcile.** `doctrine show REV-007` and
`doctrine show REV-008` (the ADR edits the code already assumes);
`doctrine show DEC-006` (resolver signature); `doctrine show DEC-024`
(workstation is Linux-only); `doctrine show DEC-036` (the broken list's
contract). Deeper inspection of the resolver change: `/walkthrough` on
`features.nix` and `features-test.nix`.

## Reconciliation Brief

### Per-slice (direct edit / slice verbs)
- **F-3** — `doctrine slice selector add 8 ALARM.md agents/README.md _templates/agents/_envrc --intent design-target` (load-bearing; what conformance reads). Mirror in design.md § Design-target selectors and add the three docs to § Code impact Files (P2, P5).
- **F-4** — design.md § Phases and verification: state the applied gate rule. "Probe identical" means packages, home-path-links and user units identical; a derived-hash `home-files-links` line (e.g. `.manpath`, whose `man-cache` hash follows `home-path`) is allowed when its masked diff is empty; a drv differing only by an unsorted space-separated store-path string is allowed when its built outputs `diff -r` empty. Note that plan EX wording (P2–P5) was narrower and stays as written.
- **F-5** — design.md § Behaviour changes, doctor row: two python scripts pinned (`pinnedPython` in `hosts/Sleipnir/doctor.nix`); `sleipnir-doctor-emacs` is bash, unchanged. Plan PHASE-07 EX-4 ("three") stays; divergence recorded on RV-018.
- **F-6** — design.md § Behaviour changes, brokenOn row: `aarch64-darwin = [watchman atuin gtt udiskie micro fsearch shell_cmds yEd]`, with the two causes (eval failure through dependencies or `meta.broken`, which availableOn ignores; uncached, skipped by the user's VH-1 choice). § Code impact Files: add `features/available.nix` (P7). Plan PHASE-07 EX-1 stays; divergence recorded on RV-018.
- **F-7** — design.md § Negative controls, dev.scm row: jujutsu absent; git falls back to the base's plain git; lazygit stays (base `programs.lazygit`, IMP-026).
- **F-18** — design.md § Verification additions, isolation recipe: the stub is overridden by absolute path, `"path:" + justfile_directory() + "/features/stub"`, because a relative path resolves against the `$HOME` git root.
- **F-12** — `doctrine slice research 8 --restamp` (drift is only plan.md / plan.toml; no section refresh).

### Governance/spec (REV and record edits)
- **F-14** — REV-007 (ADR-002: D1/D4 `platforms` key read and shape-checked; D5 DEC-035 wording; D2 `{lib}: map area` note) → user approval, apply. REV-008 (ADR-005 D6: unsupported platform is an error; Neutral "no support metadata until needed" clause → pointer to DEC-030) → user approval, apply. Both already decided by the user to apply at reconcile.
- **F-15** — DEC-006: signature `lib: { tree, classes, system, modules } -> { modules }`; replace the stale `flags` body. DEC-024: replace consequences with the assented draft (notes.md § PHASE-07 "For the orchestrator"). DEC-036: generalise the choice's list to "an explicit per-system list of packages availableOn admits but that fail to evaluate or build, or are uncached by the user's choice (e.g. atuin while ISS-007 stands)".
- **F-16** — QUE-001 → answered by DEC-030, done. RFC-001: W5 row and § Target shape (personal is three profile files; the headless home stays W7's; `coverage."home@aarch64-linux"` pre-pays it).

### Source, before close (not a reconcile surface)
- **F-13** — README § Hosts: describe the home base (`modules/home/default.nix`; `linux/` and `darwin/` layers; each `hosts/<h>/home.nix` imports one) and add the home row(s) to the class table, per design.md § Shape. One docs commit.

### At /close
- Backlog: resolve IMP-016 (DEC-032; `graphics.cad`) and ISS-008 (P3; `niri-off` control).
- PHASE-07 VH-2 stays unverified, owned by CHR-015 (the user's check at the next Draupnir home-switch). Do not mark it passed.
- Follow-ups owned: IMP-026 (lazygit), IMP-027 (clangStdenv / binutils), CHR-001 (modules/DESIGN.md), IMP-019 (probe `.manpath` normalisation).

## Reconciliation Outcome

Basis (user acts, 2026-10-16): REV-007/REV-008 approved ("accept revs");
DEC-024 draft consequence assented; VH-1 resolved by the user's choice; VH-2
verified ("VH-2 accepted"), CHR-015 resolved; the seat's "probe identical"
ruling accepted (F-4).

### Direct edits applied
- F-3: `doctrine slice selector add 8 ALARM.md agents/README.md _templates/agents/_envrc --intent design-target`; also `bin/gate-probe` (touched by 0c6ddad7 after the audit). Mirrored in design.md § Design-target selectors and § Code impact Files. `slice conformance` still misattributes by the `flakes/` prefix (ISS-005).
- F-4: design.md § Phases and verification states the applied "probe identical" rule (derived-hash `home-files-links` line with empty masked diff; unsorted store-path string with empty `diff -r`); plan EX wording stays.
- F-5: design.md § Behaviour changes, doctor row: two python scripts pinned via `pinnedPython`; the bash emacs provider unchanged.
- F-6: design.md § Behaviour changes, brokenOn row: the nine-name aarch64-darwin list (incl. `binutils-wrapper`, 773f7dc9) and its four causes; `features/available.nix` in § Code impact Files.
- F-7: design.md § Negative controls, dev.scm row (jujutsu absent; git falls back to the base; lazygit stays, IMP-026).
- F-18: design.md § The isolation check: the stub by absolute path.
- Post-audit changes folded into design.md: VH-1 result (shell_cmds, yEd skipped, d2f5f0f3); VH-2 result (binutils collision fixed by 773f7dc9; flips `git` → `git-with-svn` and `cpp` → `clang` are priority-decided, identical to Sleipnir, accepted by the user); `bin/gate-probe` `path:` on Darwin and `just probe` per current host (0c6ddad7).
- F-12: `doctrine slice research 8 --restamp`, after the design.md edits.
- F-13 (source): README § Hosts gains the home base paragraph, diagram and a `home base` class row; the host-config row names `home.nix`.

### Records and REVs completed
- REV-007 (ADR-002 D1/D2/D4/D5, Neutral): approved, applied, landed by hand, done (F-14).
- REV-008 (ADR-005 D6): approved, applied, landed by hand, done (F-14).
- DEC-006: body rewritten to `lib: { tree, classes, system, modules } -> { modules }`; the `flags` result removed (F-15).
- DEC-024: consequences replaced by the assented draft (F-15).
- DEC-036: choice generalised (evaluate/build failure, collision, uncached by the user's choice); body lists the nine names (F-6, F-15).
- QUE-001: already `answered` by DEC-030 (terminal; questions have no `done` state). No write (F-16).
- RFC-001: W5 done (SL-008), § Target shape (three personal profiles, headless W7's, home base lines), base bullet, open-questions list (F-16). Direct edit, as at SL-005..SL-007.

### Left for /close
- Resolve IMP-016 and ISS-008. PHASE-07 VH-2: verified by the user since the audit (CHR-015 resolved), so it may be recorded as passed at close on that basis. Follow-ups: IMP-026, IMP-027, CHR-001, IMP-019.

Reconcile pass complete — handoff to /close.
