# Notes SL-012: Transient breakage workarounds with removal checks

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-17 · design locked, slice at plan · a393d52f

### Produced
DEC-052 DEC-053 DEC-054 DEC-055 DEC-056 DEC-057 · RV-025 (concluded, 8 fixed) ·
design.md (locked, run rev 31) · 28861d6c (click-threading overlay removed) ·
mem.fact.nix.lock-node-names · mem.fact.flakes.nom-darwin-sh

### Learned
mem.fact.nix.lock-node-names (RV-025 F-5) · mem.fact.flakes.nom-darwin-sh
(F-7, F-8) · research X-3 (fixes land without version bumps)

### Open
- chore for shell_cmds + yEd probes: file at P2 (design sec-4)
- improvement: stable is nixos-24.11, EOL: noted in design sec-7, not filed
- at reconcile: DEC-053 path (workarounds/, not overlays/), DEC-036 rename

## Design triage (2026-10-17, exploring)

Open questions: design run inq-1 … inq-6 (`doctrine design tree SL-012`).

Constraining governance (research Thread 1): DEC-016 (fix overlays beside
consumer; user: may be amended), ADR-003 (two pins: nixpkgs, nixpkgs-home),
DEC-036 (skip list owner), ISS-004 (darwin overlays only via modules),
ADR-005 (coverage targets carry unselected features' packages).

Shaping evidence (research X-3, X-4): both real cases were fixed with no
version change, so the cache probe is the signal. kokoro is absent from
stable 24.11, so stable is not the default replacement.

Risks: a cached-but-permanent skip (binutils-wrapper) would fire a naive
check; offline runs must not fail; overlay from config must not depend on pkgs
(cycle); dry-run before every switch doubles evaluation time.

Assumptions: a workaround is pin-wide, not host-specific (an overlay on a
package outside a closure is free, by laziness). system-switch already pipes
through nom (`run.sh`), which shows planned builds and names a failed drv.

Done ahead of the mechanism: 28861d6c (click-threading overlay); kokoro
re-enabled by the user.

## PHASE-02 (2026-10-17, worker)

Probe registry and removal check: `workarounds/{default,probes,probes-test,
pin-filter}.nix`, `workarounds/check{,-test}`; `just workarounds-check`;
`update-system` / `update-home` end with `-workarounds/check <pin>`
(antigravity-nix dropped from `update-home`, user 2026-10-17). Chore CHR-016
(shell_cmds + yEd skips), linked `references --role originates_from SL-012`.

### For /reconcile (wording drift)
- **storePath, not outPath** (orchestrator ruling on the phase sheet's OQ-1).
  EX-4, VT-2 and design sec-2 say the probe record gets `outPath`; nix
  serialises any attrset with an `outPath` attribute as that bare string under
  `--json`, so the field is `storePath`. Its value is the derivation's
  `.outPath`.
- **Unfree via `meta.unfree`** (plan EX-3), not `meta.license.free` (design
  sec-2). Followed EX-3.
- **Pin filter in one file**, `workarounds/pin-filter.nix`
  (`pin: probes: …`, `null` keeps all): `check` sends its text in `--apply`,
  probes-test.nix imports it for the F-3 case. Not in the plan's file list.
- **Missing key**: the module system's "accessed but has no value defined"
  names neither `_file` nor (in the default truncated trace) the
  `addErrorContext` frame, so probes.nix checks for missing keys itself and
  throws naming the probe. host-meta.nix has the same blind spot (its
  context frame shows only under `--show-trace`).
- Exit 2 (usage, or the probes failed to evaluate) is outside design sec-2's
  table (sheet A7).
- DEC-053 / DEC-055 / DEC-056 text still says `overlays/workarounds.nix`.

### Follow-up candidates (not filed)
- Shared evalModules-schema helper for host-meta.nix and probes.nix
  (`lib: options: file: value:`), with the missing-key check above folded in
  so host-meta gains it too. Not done here: host-meta.nix is outside the
  slice (orchestrator ruling on OQ-2).

### VA-1 (error messages, by eye; probe numbers count from 1)
- unknown key: ``The option `reasonn' does not exist. Definition values:
  - In `workarounds/default.nix, probe 2 (killall)': "x"``
- missing key: `workarounds/default.nix, probe 2 (killall): missing reason`
- attr missing from pin: `workarounds/default.nix, probe 2 (killall-nope):
  not in nixpkgs-home for aarch64-darwin`
- unfree without manual: `workarounds/default.nix, probe 3 (yed): unfree,
  never on cache.nixos.org: set signal = "manual" (RV-025 F-2)`

### VA-2 live check (2026-10-17, nixpkgs-home 7fd4004d0511991fff3a0524856a9be09e28c5f0)
```
$ just workarounds-check            # same output for `nixpkgs-home`
ok atuin (aarch64-darwin)
ok killall (aarch64-darwin)
manual yed (CHR-016): check by hand
exit=0
$ just workarounds-check nixpkgs    # no probes on nixpkgs
exit=0
```
Store paths: atuin `g0n6d1cj…-atuin-18.23.0`, killall
`wpjr4ml6…-killall-shell_cmds-329`.

### Gate
`just test` green (checks.workarounds ~3.5 s cold, two nixpkgs imports);
`just coverage` green, output identical; `just drvs` diff empty; `just gate`
green; `nix fmt` clean; shellcheck clean; locks untouched. Mutation checks
(each red, then restored): drop the unfree branch, drop eager validation,
deepSeq the resolved list (F-3), widen the issue regex, manual returns
outPath; in `check`: request manual probes, drop the pin filter, 33-char
hash.

## PHASE-03 (2026-10-17, worker)

`lastGood` and `last-good`: `workarounds/last-good.nix` (new),
`workarounds/last-good` + `workarounds/last-good-test` (new, executable),
`workarounds/probes.nix` (passes `lastGood`, `stable`, `stableHello` to the
tests), `workarounds/probes-test.nix` (`testLastGoodSelectsTheRevision`,
`testLastGoodIsNotCurrent`), `justfile` (`workarounds/last-good-test` in
`test`). No `just last-good` recipe (orchestrator ruling on OQ-3).

### For /reconcile
- **Config nulls dropped** (orchestrator ruling on OQ-1). Design sec-3 says
  `config = pkgs.config`; the evaluated config carries `replaceStdenv = null`
  (and other nulls), which nixpkgs 24.11 reads as set: `attempt to call
  something which is not a function but null`. lastGood passes
  `lib.filterAttrs (_: v: v != null) pkgs.config`.
- **Refusals, exit 2** (OQ-2): `last-good` refuses an unknown input, a
  follows input (`llm-agents` today), and any input not locked to github
  NixOS/nixpkgs (owner compared case-insensitively), since lastGood fetches
  only NixOS/nixpkgs. Also exit 2: usage, no lock at HEAD (wrong repo), and
  only one commit ever changed the lock. Design sec-3 has no exit table.
- DEC-054 says `bin/workaround last-good`; the plan and code use
  `workarounds/last-good`.
- **"Last good" is the previous lock, not the previous nixpkgs.** When the
  latest lock change moved other inputs only, the clean case prints the
  current nixpkgs rev. Today: 329472f8 changed the lock, nixpkgs stayed
  `7fd4004d`, so `last-good nixpkgs` prints the current rev. As designed;
  a walk back to the last *different* rev of that input is a possible
  refinement (not filed).
- A2 holds: Lix prints `fetching github input …50ab7937` for stable's
  fetchTree even on a warm store, but `--offline` resolves it in 48 ms to
  the same store path as `inputs.stable`; no network.
- Evaluating 24.11 under Lix adds 3 `or as an identifier is deprecated`
  warnings to `just test` (A4).

### Test isolation (last-good-test)
The fixture is `$work/<name>/cfg.git` (`core.bare=false`,
`core.worktree=$work/<name>/home`, as `~/.cfg`). Before any git call:
`unset $(git rev-parse --local-env-vars) FLAKES_GIT_DIR`, `HOME` and
`XDG_CONFIG_HOME` inside `$work`, `GIT_CONFIG_GLOBAL=/dev/null`,
`GIT_CONFIG_NOSYSTEM=1`, `GIT_CEILING_DIRECTORIES=$work`, fixed author env.
Every fixture git call names `GIT_DIR`. Asserted: HOME is the fixture's,
fixture HEAD has 3 commits, `--absolute-git-dir` and `--show-toplevel` are
the fixture's. The default-repo case symlinks `$HOME/.cfg` (fake HOME) to
the fixture. Real repo HEAD unchanged (987a36ba) across all runs.

### VA-1 (real repo, 2026-10-17; working lock == HEAD's, so the source is e92f06fb's lock)
```
$ workarounds/last-good nixpkgs
{ rev = "7fd4004d0511991fff3a0524856a9be09e28c5f0"; narHash = "sha256-i5qk1kLiit98rRbh1AXmWBNT9QXC/y4l5Wk/u5EdpDQ="; }
$ workarounds/last-good stable
{ rev = "50ab793786d9de88ee30ec4e4c24fb4236fc2674"; narHash = "sha256-/bVBlRpECLVzjV19t5KMdMFWSwKLtb5RyXdjz3LJT+g="; }
$ workarounds/last-good llm-agents
last-good: 'llm-agents' follows agents/llm-agents, not a locked input   (exit 2)
```
Pasted into `import ./workarounds/last-good.nix (PASTE) pkgs ["hello"]`:
nixpkgs → `hello-2.12.3`, stable → `hello-2.12.1`. Cross-checked by hand:
e92f06fb's `root.inputs.nixpkgs` is `nixpkgs_28`, rev `7fd4004d`.

### Gate
`just test` green (log `~/.cache/multihost-gate/p3-test.log`); `just
coverage` identical; `just drvs` diff empty (`~/dev` and `/srv/fleet`
HEADs unchanged); `just gate` green; `nix fmt` touched only
last-good.nix (mine); shellcheck clean; locks untouched. Mutation checks
(each red, then restored): lastGood fed nixpkgs' rev instead of stable's
(both lastGood tests fail); `inherit (pkgs) config` (eval error, null
called); in `last-good`: plain `flakes/flake.lock` pathspec (cwd case),
`HEAD^` instead of the 2nd log entry (clean, single-commit cases), node by
input name (decoy, clean, dirty cases), case-sensitive owner (clean,
dirty), ignore the dirty test (dirty case); in the test: `~/.cfg` symlink
pointing elsewhere (default-repo case).
