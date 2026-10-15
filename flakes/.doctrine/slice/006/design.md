<!-- doctrine:section sec-1 -->
## Shape

Every remaining legacy flag becomes a tree feature (DEC-023), then the flag machinery is retired. Sleipnir's effective configuration is unchanged (ADR-001 D7); the only drv diffs allowed are the ones listed per phase under Verification, each proven.

```
legacy flag            feature                  file                         selected by (DEC-024)
games.enable        ─> games.steam              features/games.nix           Sleipnir
games.gamescope     ─> games.gamescope          features/games.nix           Sleipnir   requires games.steam
games.mangohud      ─> games.mangohud     (hm)  features/games.nix           Sleipnir
ai.llama-cpp        ─> ai.llama-cpp             features/ai.nix              nobody     coverage
ai.rocm             ─> ai.rocm                  features/ai.nix              nobody     coverage
mpd                 ─> audio.mpd                features/audio.nix           Sleipnir
speech              ─> audio.speech             features/audio.nix           nobody     coverage
dictate             ─> audio.dictate      (hm)  features/audio.nix           workstation
printing            ─> services.printing        features/services.nix        Sleipnir
webserver           ─> services.webserver       features/services.nix        Sleipnir
sunshine            ─> services.sunshine        features/services.nix        nobody     coverage
apps.cad            ─> apps.cad           (hm)  features/apps.nix            Sleipnir
desktop.sway        ─> desktop.sway  (nixos+hm) features/desktop/sway.nix    Sleipnir
desktop.niri        ─> desktop.niri  (nixos+hm) features/desktop.nix         Sleipnir
desktop.{cosmic,kde,mango} ─> desktop.<wm>      features/desktop.nix         Sleipnir
fonts               ─> desktop.fonts            features/desktop/fonts.nix   workstation
```

- A feature record holds the body of its old module file, moved verbatim except as noted; the old file is deleted (`git rm`). Comments move with their lines.
- New areas are appended to `features/default.nix` after `non-nix-packages`, in phase order: `games`, `ai`, `audio`, `services`, `apps`, `desktop`. The existing areas keep their order (ADR-002 D5). The moved modules do not: they leave `config.nix`'s alphabetical gate list (cosmic, fonts, games, …) for area order, appended after the evaluation's own imports. That is a deliberate deviation from D5's "migration preserves existing order" — there is no position in the tree that reproduces an import inside `config.nix` — and its consequence is reordered merged lists, proven per phase (Gate and probe, RV-013 F-2/F-6). New files need `git add -N` before evaluation (`mem.fact.flakes.git-add-n`).
- Each phase changes, together: the records, the flag declarations (`modules/features.nix`), the host's settings (`hosts/Sleipnir/features.nix`), the import gates, and the profile. The resolver refuses a flag at a feature's path, and an undeclared flag fails evaluation, so these cannot land separately.
- `(hm)`: home-manager half only. These are Linux-only; Draupnir imports no profile and selects none of them, so QUE-001 does not bite (see Selection).

<!-- doctrine:section sec-10 -->
## games: steam, gamescope, mangohud

New area file `features/games.nix`, three inline records in this order (DEC-023):

- **steam** (`nixos = {pkgs, ...}:`): the body of `modules/nixos/games.nix` — steam-hardware, steam with its firewall openings, protontricks and `extraPkgs`, the games `nix-ld.libraries` (comment: merged into the base set in programs.nix), `game-devices-udev-rules`, and the steam / wine system packages with their commented entries.
- **gamescope** (`nixos = {pkgs, username, ...}:`, `requires = ["games.steam"]`): the body of `modules/nixos/gamescope.nix` — `programs.steam.gamescopeSession`, gamemode with its settings, gamescope with its args, the duplicate `game-devices-udev-rules` (kept: removing it is a list change for no gain in this slice), the commented ananicy block, and its packages. Plus `users.groups.gamemode.members = [username];` (IMP-003). `requires` replaces the legacy `follows config.games.enable` default: `gamescopeSession` is a steam option, and the resolver now refuses gamescope without steam instead of quietly following it.
- **mangohud** (`homeManager = _:`): the body of `modules/home/linux/games.nix` (`programs.mangohud.enable`, the commented lutris line). No `requires`: the overlay works for any Vulkan app.

**Groups (IMP-003).** `gamemode` leaves `modules/nixos/user.nix`'s `extraGroups`. nixpkgs' gamemode module declares `users.groups.gamemode` (`nixos/modules/programs/gamemode.nix`), so the group exists exactly when `games.gamescope` is selected, and the feature adds david to it — the qemu/libvirtd precedent from SL-005. `jackaudio` stays (no owner module).

`modules/nixos/programs.nix:92`'s comment ("Verified games requirements live in games.nix (features.games)") is updated to name `features/games.nix` (`games.steam`).

<!-- doctrine:section sec-2 -->
## ai: llama-cpp and rocm

New area file `features/ai.nix`, two inline records:

- **llama-cpp** (`nixos = {lib, pkgs, ...}:`): the body of `modules/nixos/llama-cpp.nix` with its header comment and the `presets` `let` block, inline (63 lines; under the ~100-line spill prompt). The `llama-prism` overlay stays in `hosts/Sleipnir/config.nix`: it is a package fix, and an unselected feature is never evaluated anyway.
- **rocm** (`nixos = _:`): `nixpkgs.config.rocmSupport = true;`, with a comment from README: it rebuilds much of nixpkgs, and llama-cpp does not need it.

No `requires` between them: `llama-cpp-prism-rocm` is a ROCm build regardless of `rocmSupport`. Neither is selected; each gets a coverage target (Selection).

<!-- doctrine:section sec-3 -->
## audio, services, apps

Three area files, inline records, each the verbatim body of its module:

| area file | record | half | from |
|---|---|---|---|
| `features/audio.nix` | `mpd` | nixos `{username, ...}:` | `modules/nixos/mpd.nix` |
| | `speech` | nixos `{pkgs, ...}:` | `modules/nixos/speech.nix` |
| | `dictate` | homeManager `{lib, pkgs, ...}:` | `modules/home/linux/dictate.nix`, header comment included |
| `features/services.nix` | `printing` | nixos | `modules/nixos/printing.nix` |
| | `webserver` | nixos | `modules/nixos/webserver.nix` |
| | `sunshine` | nixos | `modules/nixos/sunshine.nix` |
| `features/apps.nix` | `cad` | homeManager | `modules/home/linux/cad-3d.nix` (taxonomy: IMP-016) |

- **dictate's assets** move beside their feature: `modules/home/linux/bin/{dictate,dictate-test}` → `features/audio/{dictate,dictate-test}` (`git mv`); the record's two `./bin/dictate` references become `./audio/dictate`. `dictate-test` loads the script as its sibling (`here / "dictate"`), so it moves unchanged. `justfile`'s `test` recipe path is updated. A path literal's store path depends on its basename and content only, so the unit's `ExecStart` is unchanged.
- **caddy (IMP-003).** `caddy` leaves `user.nix`'s `extraGroups`. No `caddy` group exists on Sleipnir (webserver installs the package; it runs static-web-server, not the caddy service), so effective membership is unchanged. It is not moved: there is no group to join.
- `printing` keeps its site-bound `extraHosts` printer entry (IMP-017).
- **speech's overlay is repaired** (RV-013 F-1; user chose repair over parking, 2026-10-16). `overlays/whisper-rocm.nix` passes `rocmGpuTargets` to `whisper-cpp`, which the pinned nixpkgs no longer accepts: `whisper-cpp` now takes its ggml backend from `llama-cpp` (`pkgs/by-name/wh/whisper-cpp/package.nix`), and `llama-cpp` still takes `rocmGpuTargets`. The overlay becomes `whisper-cpp.override { rocmSupport = true; vulkanSupport = false; llama-cpp = prev.llama-cpp.override { rocmGpuTargets = ["gfx1201"]; }; }`, keeping the gfx1201-only pin, and its header comment is corrected (F-10). Sleipnir does not select speech, so its derivations are unaffected; `coverage."Sleipnir+speech"` proves the repair. If that override does not evaluate, stop and `/consult` (fallback: park speech).

<!-- doctrine:section sec-4 -->
## desktop: compositors and fonts (+ IMP-004)

New area `features/desktop.nix`, in the order `sway`, `niri`, `cosmic`, `kde`, `mango`, `fonts`; `sway` and `fonts` spill to their own files (ADR-002 D3) and are listed as `(import ./desktop/<name>.nix)`.

- **sway** → `features/desktop/sway.nix`: one record, `nixos` = `modules/nixos/sway.nix`, `homeManager` = `modules/home/linux/sway.nix` (~150 lines together; its `let` block, wpm archive script and all).
- **niri**: `nixos` = `modules/nixos/niri.nix`, `homeManager` = `modules/home/linux/niri.nix` (vicinae module import, tailscale-systray, the swaybg wallpaper service). Verbatim: those last two also serve umbriel, the session in use; ISS-008 tracks moving them to their real owner.
- **cosmic**, **kde**, **mango**: `nixos` halves only, verbatim (mango keeps its `imports = [inputs.mangowm.nixosModules.mango]`).
- **fonts** → `features/desktop/fonts.nix`: `modules/nixos/fonts.nix` verbatim (125 lines). Its `../../packages/clockface-font.nix` path is the same depth from `features/desktop/`. It also sets the console font and keymap; the legacy flag gated those too, so moving them keeps today's semantics. Separating console from desktop fonts is W4's classification work.

**Desktop base stays unconditional.** `wayland`, `wayland_packages`, `greeter`, `xdg`, `x11`, `qt` and `umbriel` remain imports in `hosts/Sleipnir/config.nix`; no compositor `requires` them. W4 classifies them. Session identity (ISS-001) and portal fan-out (IMP-005) are untouched (CPT-001): `wayland.nix` still sets `niri` globally.

**IMP-004.** One package leaves `modules/nixos/wayland_packages.nix`, and one duplicate is resolved the other way (user, 2026-10-16):

| package | consumer | change |
|---|---|---|
| `waybar` | the sway home half's `programs.waybar` (`sway.conf`'s own `exec waybar` is commented out) | the `wayland_packages` entry goes; `desktop.sway` already lists it |
| `cava` | a waybar module, but a general audio visualiser | stays shared; the sway record's duplicate goes |

`grimshot` stays shared: besides `sway.conf`'s bind, the zsh alias `scr` uses it under any wlroots compositor. `hyprpicker`, `swaybg`, `swayimg` and `kanshi` are compositor-agnostic and stay. Unused entries — `wob`, `i3status`, `wf-config`, `gnomeExtensions.appindicator`, `marble-shell-theme` — stay too: removing them changes the set; IMP-004 keeps that prune (RV-013 F-5).

<!-- doctrine:section sec-5 -->
## Selection and coverage

Per DEC-024: the workstation profile carries what any desktop workstation of mine wants; a host carries what is bound to its hardware, site, data or taste.

```nix
# features/profiles/workstation.nix — added
feature.desktop.fonts.enable = lib.mkDefault true;
# Linux-only home half: a darwin host importing this profile would select it
# and fail ADR-005 D6 / hit QUE-001.
feature.audio.dictate.enable = lib.mkDefault true;

# hosts/Sleipnir/features.nix — after (legacy settings all gone)
imports = [../../features/profiles/workstation.nix];
feature.virt.capsule.enable = true;          # existing
feature.virt.qemu.enable = true;             # existing
feature.games = { steam.enable = true; gamescope.enable = true; mangohud.enable = true; };
feature.desktop = { sway.enable = true; niri.enable = true; cosmic.enable = true; kde.enable = true; mango.enable = true; };
feature.audio.mpd.enable = true;             # /media/music
feature.services = { printing.enable = true; webserver.enable = true; };   # printers: site-bound (IMP-017)
feature.apps.cad.enable = true;              # not in a profile until IMP-016
```

The header comment becomes: the profiles it imports, and the features it selects itself. Its stale trailing `# games.enable = true;` goes.

**Off features (ADR-005).** `hosts.nix` gains one coverage target each, beside the existing two, built the same way (`mkNixos "Sleipnir" … (select "Sleipnir" … [{feature.<area>.<name>.enable = true;}])`):

```
coverage."Sleipnir+llama-cpp"   coverage."Sleipnir+rocm"
coverage."Sleipnir+speech"      coverage."Sleipnir+sunshine"
```

`just coverage` forces each system drvPath (evaluation, not build: `rocm`'s target evaluates the `rocmSupport` closure but builds nothing). Draupnir imports no profile and selects no tree feature, so it is untouched; the per-phase gate proves it.

<!-- doctrine:section sec-6 -->
## Retiring the machinery

Last phase, once no flag is read (W3's exit, RFC-001).

| file | change |
|---|---|
| `modules/features.nix` | deleted |
| `features.nix` | outer `evalModules` drops `./modules/features.nix`; returns `{ modules }` only (no `flags`); header comment loses "Two paths coexist" |
| `features.nix` | the "option at a feature's path" structural check **stays** (DEC-025, ADR-002 D4), reworded: an outer option at `<area>.<name>` would be a second switch for that feature |
| `hosts.nix` | `args` drops `features = selection.flags`; header comment updated |
| `hosts/Sleipnir/config.nix` | (phase 4, when its last gate goes) `features` and `lib` args go; the "unconditional first, then feature-gated" comment goes; the parked comment's "Deliberately not feature flags: a flag says 'flip me'" (`:56-57`) becomes "not features: selecting one says 'flip me'" |
| `modules/home/linux/default.nix` | (phase 4) `features` and `lib` args go; plain `imports` list |
| `features-test.nix` | the flag-at-path test's comment (`:119`) speaks of an outer option, not a legacy flag (DEC-025); `resolves` forces `.modules` instead of `.flags`; `testPrerequisiteOffFails` checks `.modules.homeManager` only; `testFlagsHideSelection` is replaced by `testResultIsModulesOnly` (`attrNames` of the result is `["modules"]`: the selection reaches no evaluation except as modules) |
| `README.md` | see Docs |

The flag-at-path test fixture declares its own outer option, so it is independent of `modules/features.nix` and keeps passing unchanged.

**Lint per phase** (RV-013 F-8): deadnix flags leftovers as the flags drain — `follows` and the `config` arg in `modules/features.nix` after phase 1, `mkEnableOption` after phase 3 — each removed in the phase that orphans it.

A module that still names `features` in its argument set would fail evaluation with "attribute 'features' missing": the gate catches any reader `grep` misses.

<!-- doctrine:section sec-7 -->
## Gate and probe

**Probe promotion** (phase 1, before any migration). `.doctrine/slice/005/gate-probe.sh` moves (`git mv`) to `bin/gate-probe` at the flake root, run as `just probe <outdir> [<attr>]`. The flake root becomes `$(dirname "$0")/..` (it was three levels up), and each mode reads the overrides `just drvs` uses for it: `system_override` for system, `home_override` for home (RV-013 F-7). Defaults: `nixosConfigurations.Sleipnir` and `homeConfigurations."david@Sleipnir"`; `just probe <outdir>` writes both under `<outdir>/{system,home}`. Its header drops the SL-005 citation for a one-line purpose and points to `mem.pattern.flakes.drv-gate`. `bin/` is new; the probe is shared tooling for W3/W4. SL-005 is closed; its references to the old path become historical.

A sorted list cannot show who wins a collision, and several merged lists are order-semantic, so for those the probe measures the **built artefact**, not the list (RV-013 F-2):

| measure | what it proves |
|---|---|
| system (kept) `packages`, `groups`, `kernelParams`, `root-options`, `system-path-links` | as SL-005; the link map also covers the nix-ld library env (`/share/nix-ld`) and portal definitions (`/share/xdg-desktop-portal`), which reach system-path — phase 1 confirms both prefixes appear in it, else adds them as measures |
| system (new) `ports` | sorted `networking.firewall` TCP/UDP ports and ranges, global and per interface (steam, sunshine, qemu) |
| system (new) `udev-rules` | the built udev rules directory: each file with its target — who shadows whom across `services.udev.packages` |
| system (new) `session-desktops` | link map of `services.displayManager.sessionData.desktops`: which session file wins |
| system (new) `fontconfig` | link map of the built `/etc/fonts` tree plus the content hash of `fonts.conf`: font-directory precedence |
| home (new) `packages`, `home-path-links`, `home-files-links` | sorted unique `home.packages`; link maps of `config.home.path` and `config.home-files` (dotfiles, scripts, units) |

`console.packages` (terminus, only from `fonts`) is checked by `nix-diff` of its drv.

**Gate per phase** (`mem.pattern.flakes.drv-gate`): `just drvs`, `just drvs-sets`, `just probe`, `just coverage` and `just gate` (tests + treefmt, which runs deadnix) before the first edit and after each phase, each phase compared with the one before (RV-013 F-3).

**Merge order.** An ordering-only diff is accepted when every probe measure is identical, or when the only changed measure is a built artefact whose derivation `nix-diff` shows differs only by list order (met in PHASE-03 and PHASE-04 by `.manpath`, man-cache over man-paths; RV-014 F-1). Any changed drv the probe does not explain is `nix-diff`ed: its `env` must be equal once lists are sorted, or it is red. If a built artefact changes (a collision winner flipped, `mem.fact.nix.systempath-collision-first-wins`), stop and `/consult`: preferred fix is removing the duplicate at its source; fallback is `mkOrder` on that one definition.

<!-- doctrine:section sec-8 -->
## Phases and verification

One commit per phase; each phase ends green on the gate. Anything not in its row is red: `nix-diff` it and stop.

| # | phase | allowed diff | proof |
|---|---|---|---|
| 1 | probe + **games** | Sleipnir toplevel: order of `systemPackages`, `udev.packages`, firewall ports, `nix-ld.libraries`, `sessionPackages` (steam's gamescope session); `extraGroups` loses `gamemode`, `users.groups.gamemode.members` gains david. Home: `home.packages` order (mangohud) | every probe measure identical (system and home) |
| 2 | **ai** | none: both are off, so no module is projected and the removed gates were false | every `drvs` line identical; `just coverage` gains two targets, both evaluate |
| 3 | **audio, services, apps** | Sleipnir toplevel: order of `systemPackages`, `udev.packages` (printing drivers), `printing.drivers`; `extraGroups` loses `caddy` (no such group). Home: order (dictate, cad) | every probe measure identical, so `dictate`'s files and unit are unchanged; two more coverage targets, both evaluating (`Sleipnir+speech` proves the overlay repair) |
| 4 | **desktop** (+IMP-004) | Sleipnir toplevel: order of `systemPackages`, `sessionPackages`, `xdg.portal.extraPortals`, `fonts.packages`, `console.packages`; 2 fewer `systemPackages` entries (`waybar`'s duplicate in wayland_packages, `cava`'s in the sway record). Home: order (sway, niri halves). The `features`/`lib` args leave `config.nix` and `modules/home/linux/default.nix` here (deadnix, RV-013 F-8) | `drvs-sets` system count drops by exactly 2; the probe's unique `packages` identical (RV-013 F-11); every other probe measure identical |
| 5 | **retire** | none | every `drvs` line identical |

Home, Draupnir, packages, legacyPackages and templates lines are identical at every phase except where a row names home.

**Resolver tests** (`features-test.nix`), red first, in the phase that migrates each feature:
- `testSleipnirSelectsMigrated` gains each on-feature with its halves: `[nixos, home]` per tag (e.g. `games.mangohud` → `[false true]` on its `homeManager` tag; `desktop.sway` → both).
- `testOffFeatures`: llama-cpp, rocm, speech, sunshine unselected.
- `testGamescopeRequiresSteam`: the real tree without the host file, `modules = [(on "games.gamescope")]`, fails; its twin with `games.steam` also on resolves (RV-013 F-4: the host file's plain definitions would make a `false` conflict, failing for the wrong reason).
- `testFlagsHideSelection` loses its `flags ? games` element in phase 1 (the games flags go); phase 5 replaces it (Retiring the machinery). Its `:303` comment ("NixOS half only, each") is rewritten when home halves join `testSleipnirSelectsMigrated` (RV-013 F-3, F-9).

**Negative controls** (one-off evals, not committed; `mem.fact.nix.verify-closure-not-option`): deselect each on-feature in turn with `lib.mkForce false` (the host's selections are plain definitions; RV-013 F-4) and check its signature is gone — `programs.steam.enable` false and steam absent from system-path (steam, deselected together with gamescope, which requires it); `gamemode` group absent from effective groups (gamescope); mangohud absent from `home.packages` (mangohud); `services.mpd.enable` false (mpd); the `dictate` user unit absent (dictate); `services.printing.enable` false (printing); `static-web-server` unit absent (webserver); openscad absent (cad); `programs.sway.enable`, `programs.niri.enable`, `services.desktopManager.cosmic.enable`, `programs.mango.enable` false, and for kde `plasma-desktop` absent from system-path (one per compositor); `clockface-font` absent from `fonts.packages` (fonts). For sway also: `waybar` absent from system-path (IMP-004).

**Close:** `git grep -En 'features\.(games|ai|desktop|apps|fonts|printing|speech|webserver|dictate|mpd|sunshine)\b|specialArgs\.features|selection\.flags|modules/features\.nix'` over tracked files under `flakes/` (excluding `.doctrine/`; the flake sees only tracked files) finds nothing; `just gate` green (RV-013 F-9).

<!-- doctrine:section sec-9 -->
## Code impact and docs

| path | change |
|---|---|
| `features/{games,ai,audio,services,apps,desktop}.nix` | new area files |
| `features/desktop/{sway,fonts}.nix` | new own-file records |
| `features/audio/{dictate,dictate-test}` | moved from `modules/home/linux/bin/` |
| `features/default.nix` | six areas appended |
| `features/profiles/workstation.nix` | `desktop.fonts`, `audio.dictate` |
| `hosts/Sleipnir/features.nix` | legacy settings out; feature selections in |
| `hosts/Sleipnir/config.nix` | gates, `features`, `lib` out |
| `modules/home/linux/default.nix` | gates, `features`, `lib` out |
| `modules/nixos/user.nix` | `gamemode`, `caddy` out of `extraGroups` |
| `modules/nixos/wayland_packages.nix` | `waybar` out (`cava`, `wob`, `grimshot` stay) |
| `modules/nixos/programs.nix` | games comment |
| `modules/nixos/{games,gamescope,llama-cpp,rocm,mpd,speech,printing,webserver,sunshine,sway,niri,cosmic,kde,mango,fonts}.nix` | deleted |
| `modules/home/linux/{games,dictate,cad-3d,sway,niri}.nix` | deleted |
| `modules/features.nix` | deleted (phase 5) |
| `features.nix`, `hosts.nix`, `features-test.nix` | retirement; coverage targets; tests |
| `bin/gate-probe`, `justfile` | probe moved, new measures, home mode; `probe` recipe; dictate-test path and its `:45-47` comment |
| `overlays/whisper-rocm.nix` | phase 3: pin via `llama-cpp.override { rocmGpuTargets }` (RV-013 F-1); header comment: `rocmSupport` is not on globally (RV-013 F-10) |
| `README.md` | below |

**README.** "Feature flags" becomes one mechanism: the "Legacy flags" subsection and flag table go; the intro and diagram lose `flags ─> specialArgs.features`; the tree listing shows every area; "have moved here" becomes a statement that every optional module is a feature. Section pointers updated: Dictation (`features/audio.nix`, `features/audio/dictate`), Printing (`features/services.nix`), llama.cpp ("Gated by `ai.llama-cpp`" → `feature.ai.llama-cpp`, selected in `hosts/Sleipnir/features.nix`; drop the `ai.rocm` flag wording). "Parked is not a feature" loses "then promote to a flag" (→ "to a feature").

IMP-004's note landed in PHASE-04 (plan EX-5), which also removed the README flag material ahead of PHASE-05 (RV-014 F-6).

**At reconcile** (REV for governance): ADR-001 D2's "While the legacy flags remain…" and its closing `specialArgs.features` sentence become history; ADR-005 D1's "Transitional" clause goes; RFC-001 W3 row records SL-006 and W3 done. IMP-003 notes gamemode and caddy done (jackaudio remains); IMP-004 notes the fold-in (prune remains); IMP-006 notes W3 complete.

**Follow-ups:** ISS-008 (niri half carries umbriel's tray and wallpaper; also `sleipnir-doctor.nix:1` runs python from the sway half's `wpmPython` env, RV-013 F-9); IMP-004 prune; IMP-016 (apps taxonomy, `apps.cad` placement); W4 classifies the desktop base and `fonts`' console settings.

