# Notes SL-006: Legacy flags to feature tree: the rest of W3

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Design review (2026-10-16)

RV-013: one adversarial pass (Opus subagent; user's choice of lane), 11
findings (1 blocker, 3 major, 7 minor), all fixed in design and re-verified by
the reviewer; the whisper-cpp overlay repair (F-1) evaluated against the
pinned nixpkgs.

**Further review passes: none needed before lock.** The pass covered every
section and its fixes were re-checked. What a further pass would probe, and
where it is cheaper to probe it instead: whether the new probe measures
(udev rules dir, session desktops, fontconfig, ports) catch a flipped winner
— proven empirically by phase 1's baseline and gate, not by more reading;
and the phase-4 desktop diff, the largest surface — covered by the audit.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-16 · ready (design locked, plan authored) · 164ffce7

### Produced
- DEC-023, DEC-024, DEC-025 (accepted; shape SL-006)
- RV-013 (design review, concluded; F-1..F-11 verified)
- ISS-008 (niri home half / umbriel coupling; sleipnir-doctor wpmPython)
- IMP-004 notes (fold-in narrowed to waybar; prune list)

### Learned
- (none recorded yet; candidate memory at close: whisper-cpp now takes its
  ggml backend from llama-cpp — pin ROCm targets via llama-cpp.override)

### Open
- IMP-003 (jackaudio), IMP-004 (prune), IMP-016, ISS-008, QUE-001

## Gate snapshots

Outside the repo, one directory per snapshot, each holding `drvs`,
`drvs-sets`, `coverage` and `just probe <dir>`'s `system/` and `home/`
(`bin/gate-probe`):

- `~/.cache/multihost-gate/sl006/baseline/` — before any config edit
  (PHASE-01 EN-2), tree at 605b5208 plus the probe move and `just probe`
  (tooling only). Probe re-run on the same tree: `diff -r` empty
  (deterministic). Line counts: system `packages` 456, `groups` 8,
  `kernelParams` 6, `root-options` 4, `ports` 21, `system-path-links`
  167682 (1336 under `share/nix-ld/`, 13 under `share/xdg-desktop-portal/`,
  1076 own files by hash), `udev-rules` 126, `session-desktops` 6,
  `fontconfig` 31; home `packages` 332, `home-path-links` 196449,
  `home-files-links` 3106. None empty. `just gate` green on it.
- `~/.cache/multihost-gate/sl006/phase-01/` — after PHASE-01; PHASE-02's
  baseline. Also holds `nix-diff-toplevel.txt` and the home lines re-evaluated
  with `emacs/emacs-overlay` pinned to the baseline's rev
  (`*-home-pinned-b58afd9`).
- `~/.cache/multihost-gate/sl006/phase-02/` — after PHASE-02; PHASE-03's
  baseline (`drvs`, `drvs-sets`, `coverage`, `system/`, `home/`).
- `~/.cache/multihost-gate/sl006/phase-03/` — after PHASE-03; PHASE-04's
  baseline. Taken at emacs-overlay 08c72b09663805de26057dfed80b7153846336ca
  (no drift; no pinned files needed). Also holds `nix-diff-toplevel.txt`,
  `nix-diff-home.txt`. Re-captured after T7/T8 (docs, temp entries removed):
  `drvs`, `drvs-sets`, `coverage` identical.
- `~/.cache/multihost-gate/sl006/phase-04/` — after PHASE-04; PHASE-05's
  baseline. Taken with `emacs/emacs-overlay` pinned (temporary `justfile`
  edit, removed after; `git diff --quiet -- flakes/justfile`) to
  08c72b09663805de26057dfed80b7153846336ca, which is also what an unpinned
  eval resolved to at T0. Also holds `order-before.json` / `order-after.json`
  (fonts, console, sessions, portals, sorted systemPackages drvPaths),
  `nix-diff-toplevel.txt`, `nix-diff-home.txt`, and the negative-control
  probes `tmp-no{sway,kde,mango}/`. Docs/comment edits after the capture
  (T7) re-checked: Sleipnir system and home drvs unchanged, no re-capture.

## PHASE-01 summary

**Probe** (`bin/gate-probe`, `just probe <dir> [attr]`). Link maps list every
file reachable under the built tree with links followed (`find -L`), each with
its resolved target (`realpath -m`), because `system-path` holds
`share/nix-ld/lib` as one directory link into nix-ld's inner `buildEnv`
(`ld-library-path`), whose store path moves on any reorder of
`nix-ld.libraries`. Files the tree holds itself (1076 in system-path: mime
and icon caches, `mimeinfo.cache`, …; 2 in home-files) resolve into the
tree's own input-dependent store path, so they are measured by content hash
(`<relpath> = <sha256>`). `udev-rules` is content hashes per file (the
builder copies rules, last package wins a name). `fontconfig` is the link map
of the `fontconfig-etc` drv (taken from the string context of
`environment.etc.fonts.source`) plus `fonts.conf = <sha256>`. Both prefixes
confirmed in `system-path-links` (EX-2): `share/nix-ld/` 1336 lines,
`share/xdg-desktop-portal/` 13. Deterministic (re-run `diff -r` empty).
Caveat: `find -L` would descend into an out-of-store directory link
(`mkOutOfStoreSymlink`); none exist today (all 3106 home-files targets
resolve into the store).

**Gate vs baseline** (EX-7, VA-1):
- probe: `diff -r` empty, system and home.
- `drvs-sets`: nixos and darwin identical; the home lines differ, and so does
  `homeConfigurations.david@Draupnir` in `drvs` — emacs-overlay drift under
  `home_override` (`b58afd9` at baseline → `08c72b0`), not this change.
  Proof: with `--override-input emacs/emacs-overlay …/b58afd9`, the
  post-change home lines (`drvs` and `drvs-sets`, all three) equal the
  baseline exactly; Draupnir's drv is `95in4nmq…` at b58afd9 and `pxcgk5qp…`
  at 08c72b0. So the home activationPackage did not change at all (mangohud's
  `home.packages` entry is defined by home-manager's own module, whose
  position is unchanged).
- `drvs`: only `nixosConfigurations.Sleipnir` changed for this phase
  (`j3xb0qqh…` → `hdy0sg8q…`). 13 drvs differ in its closure; `system-path`
  is the only leaf: its env is equal once arrays are sorted (only
  `chosenOutputs` order differs), inputDrvs/inputSrcs equal. The other 12
  (`dbus-1`, `etc`, `activate`, `system-units`, `user-units`,
  `unit-{dbus-broker,polkit,accounts-daemon}.service`, two
  `X-Restart-Triggers-*`, toplevel) are equal modulo the changed paths.
  Narrower than the design allowed: udev rules, nix-ld env, firewall,
  sessions and `users-groups.json` did not change at all (gamemode's
  membership is merged from extraGroups and members into one list).
- `coverage`: both Sleipnir twins changed with the toplevel (A4); both
  evaluate.
- `just gate` green (tests, treefmt incl. deadnix/statix); `flake.lock`
  untouched.

**Negative controls** (VA-2; temporary `coverage.tmp-*` in hosts.nix, removed,
`git diff --quiet -- hosts.nix`):
- steam+gamescope `mkForce false`: `programs.steam.enable` false; `bin/steam`
  absent from system-path-links (0 vs 1; 0 vs 18 lines naming a `-steam`
  store path); steam's firewall ports gone (0 vs 7 `270xx` lines).
- gamescope `mkForce false`: `gamemode` absent from effective groups;
  `bin/gamescope` absent from system-path-links.
- mangohud `mkForce false`: `programs.mangohud.enable` false; 0 mangohud in
  `home.packages` (vs 1); 0 mangohud files in home-path (vs 14).
- twins: `bin/steam`, `gamemode`, mangohud all present in the baseline probe.

## PHASE-02 summary

- Gate vs phase-01: `drvs`, `drvs-sets`, `system/`, `home/` all identical,
  every line (home/darwin included: emacs-overlay did not drift this time, so
  the pinned comparison was unnecessary). `coverage` gained exactly two lines:
  `Sleipnir+llama-cpp` 2949l4yp4jwdxz1r8r88xz7cicckzs9p, `Sleipnir+rocm`
  hdv7ljb0zrpbqivbs8890zdnfxi5d3i6; the other two unchanged. Both differ from
  Sleipnir's toplevel (each feature projects something).
- Red (A2): `testOffFeatures` aborted the whole run with "The option
  `feature.ai' does not exist" (no tryEval in `sleipnirWith`).
- Refactor (T5): `testSleipnirLeavesPodmanOff` + `testPodmanSelectable` folded
  into `testOffFeatures` as `virt.podman#nixos`; PHASE-03 extends the flat list.
- README: Overrides example `ai.rocm = false` swapped for `speech = false`.
- `just gate` green, `flake.lock` untouched.

## PHASE-03 summary

- Gate vs phase-02:
  - `drvs`: only Sleipnir moved — `nixosConfigurations.Sleipnir`
    hdy0sg8q → zypvdm5s; `homeConfigurations.david` and `david@Sleipnir`
    wz9szhqv → xjan80fm. Draupnir (home, darwin), packages, templates
    identical. `drvs-sets` identical. `system/` probe identical.
  - toplevel nix-diff: sole leaf `system-path`, env equal once arrays are
    sorted; moved entries caddy-2.11.7 and system-config-printer-1.5.18. etc,
    dbus-1, system-units, user-units differ only through it.
    `users-groups.json` did **not** move: no caddy group exists, so dropping
    `"caddy"` from extraGroups changed nothing (narrower than expected).
  - home nix-diff: leaves `home-manager-path`, `man-paths`,
    `david-fish-completions`, each order-only; moved entry openscad-2021.01.
    `home-path-links` identical.
  - `home/home-files-links` differs on one line, `.manpath`: its text embeds
    the man-cache store path, and man-cache is input-addressed over
    man-paths (a buildEnv of home.packages), so any home.packages reorder
    moves it. Worker STOP; **orchestrator adjudication: accepted as
    ordering-only** (slice objective admits "unchanged or proven
    ordering-only", mem.pattern.flakes.drv-gate); EX-6 read with that
    exception for `.manpath`.
- Coverage: six lines. The four existing moved (Sleipnir's toplevel moved);
  new `Sleipnir+speech` 4n6plf0v057j58c0116ndhc8d1f402p0 and
  `Sleipnir+sunshine` sgfjby7va8nby0j12cgbah5dmfni1cpb, both distinct from
  the toplevel.
- Speech red → green: before the repair `Sleipnir+speech` failed with
  "function 'anonymous lambda' called with unexpected argument
  'rocmGpuTargets'". Fact: whisper-cpp now takes its ggml backend from
  llama-cpp and passes rocmSupport on to it, so the ROCm target pin goes
  through `llama-cpp = prev.llama-cpp.override {rocmGpuTargets =
  ["gfx1201"];}`. Checked: whisper-cpp-1.9.5.drv's llama-cpp-0.6.0.drv input
  names gfx1201.
- Negative controls (VA-2, temp `lib.mkForce false` entries, removed after):
  mpd `services.mpd.enable` false (on: true); printing
  `services.printing.enable` false, system-config-printer links in
  system-path 0 (on: 40); webserver `systemd.services ? static-web-server`
  false, `bin/caddy` 0 (on: 1); dictate user unit and `.local/bin/dictate`
  both absent (on: present); cad openscad absent from `home.packages` and
  home-path `bin/` (on: 149 home-path links).
- Red (T1): whole run aborted on "The option `feature.audio' does not
  exist". T1 refactor taken: `testSleipnirSelectsMigrated` is two literal tag
  lists (`nixosOnly`, `homeOnly`) with `expected` derived by map.
- dictate assets moved byte-identical (`git mv`); `features/audio/dictate:19`
  docstring still says "set by dictate.nix" — fixing it moves store paths,
  left for a later commit. `~/.config/umbriel/binds.toml:45` likewise
  (outside flakes/).
- README: gating example now `features.fonts`; Overrides example
  `desktop.kde = false`; flag table down to desktop.* and fonts (PHASE-04
  needs a third swap or deletion).
- `just gate` green, `flake.lock` untouched.

## PHASE-04 summary

- Gate vs phase-03 (emacs-overlay pinned to 08c72b0):
  - `drvs`: only Sleipnir moved — `nixosConfigurations.Sleipnir` zypvdm5s →
    wcvilzwg; `homeConfigurations.david` and `david@Sleipnir` xjan80fm →
    cyfidm5f. Draupnir (home, darwin), packages, legacyPackages, templates
    identical.
  - `drvs-sets`: one line — Sleipnir system `572 ad76579a…` → `570
    0a8db462…`; every other line identical. Sorted systemPackages multiset
    (order-{before,after}.json): exactly two removed, `cava-1.0.0.drv`
    (fb8f74hj) and `waybar-0.15.0.drv` (sl4z9l4p) — the IMP-004 duplicates.
  - `system/` probe identical, every file: `packages` (unique),
    `session-desktops`, `system-path-links`, `udev-rules`, `ports`, `groups`,
    `kernelParams`, `root-options`, **`fontconfig`** (A2 held; no EX-4
    deviation to record).
  - Order lists: fonts (73), console (1), sessions (6), portals (15) — each
    the same order, not only the same multiset. Nothing reordered.
  - toplevel nix-diff: sole leaf `system-path`. Its env is equal outside
    `chosenOutputs`; `chosenOutputs` 572 → 570, sorted multiset diff exactly
    one `cava-1.0.0` and one `waybar-0.15.0` entry (priority 5) removed. The
    rest is order: the desktop entries (kde, niri, sway blocks) now precede
    the services / games / virt feature entries (caddy … quickemu) instead of
    following them. `system-path-links` identical, so no first-wins collision
    flipped (R2 did not fire). etc, dbus-1, system-units (accounts-daemon,
    dbus-broker, polkit), user-units differ only through it.
  - home nix-diff: leaves `home-manager-path`, `david-fish-completions`,
    `man-paths`; for each, env equal once lists/words are sorted (only `out`
    differs). `home-path-links` identical (R3 did not fire).
  - `home/home-files-links`: one line, `.manpath` (gfzjffpa → jcx1mql8),
    the accepted exception by PHASE-03 precedent.
- Coverage: six lines, all moved (A7), all evaluate.
- Negative controls (VA-2; temp `lib.mkForce false` entries in hosts.nix,
  removed after, `git diff --quiet -- flakes/hosts.nix`):
  sway `programs.sway.enable` false (on: true), `bin/waybar` in system-path
  0 (on: 1) — waybar now reaches system-path only through sway; niri
  `programs.niri.enable` false (on: true); cosmic
  `services.desktopManager.cosmic.enable` false (on: true); kde
  `-plasma-desktop-` lines in system-path-links 0 (on: 776); fonts
  clockface-font absent from `fonts.packages` (on: present).
  mango: the sheet expected `programs.mango` undeclared when off; it is not —
  nixpkgs now ships its own `nixos/modules/programs/wayland/mango.nix`, so
  the option exists either way (declared by mangowm's flake module when on).
  So VA-2 reads literally: `programs.mango.enable` false (on: true);
  `mango.desktop` absent from `session-desktops` (on: 1), sessionPackages
  6 → 5.
- Red (T1): plain assertion failure in `testSleipnirSelectsMigrated` only
  (A6), no abort. Test choice: `nixosOnly` gains cosmic, kde, mango, fonts
  (fonts through the workstation profile); new `bothHalves` (sway, niri
  `#nixos` → `[true true]`); `homeOnly` gains sway, niri `#homeManager` →
  `[false true]` — slightly redundant with `bothHalves`, kept so VT-1's
  `#homeManager` keywords are real assertions.
- `modules/features.nix` is now `{ options = {}; }` with a header saying no
  flag remains (deadnix/statix clean); kept for PHASE-05.
- Verbatim check (`diff -w` HEAD sources vs new halves): only record framing,
  headers, the ISS-008 comment, and T3's `cava`. No alejandra reflow inside
  bodies. `sway-easyfocus` still listed twice (prune candidate, IMP-004).
- `just gate` green (zero lint warnings), `just coverage` green,
  `flake.lock` untouched.

## PHASE-05 summary — flag machinery retired

- T0: HEAD 903875fd, tree clean, baseline phase-04 present.
- Red (T1): `testResultIsModulesOnly` alone failed (result `["flags" "modules"]`),
  no abort.
- Green (T2, atomic): `modules/features.nix` removed (`git rm`); the resolver
  returns `{ modules }`; hosts.nix `args hostname` drops `selection` and the
  `features` specialArg; `testFlagsHideSelection` replaced by
  `testResultIsModulesOnly`; `resolves` reads `.modules`;
  `testPrerequisiteOffFails` simplified to `fails r.modules.homeManager` /
  `true`. Collision message now "is also an outer option" (DEC-025);
  `testFlagCollisionFails` keeps its name (VT keyword in SL-001).
- README: one mechanism; legacy bullets, diagram branch, file-table row and
  `#### Legacy flags` removed; section title unchanged.
- EX-5: emacs-overlay pinned to 08c72b09 (pin grep = 1), unpinned
  (`git diff --quiet -- justfile` ok). drvs, drvs-sets, coverage, system/,
  home/ all identical to phase-04 (captures in
  ~/.cache/multihost-gate/sl006/phase-05/).
- Close grep (`git grep -nE '...' -- . ':!.doctrine'`): no output, exit 1.
- `just gate` green (zero warnings), `just coverage` green (six targets),
  flake.lock untouched.
