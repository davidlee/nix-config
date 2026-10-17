<!-- doctrine:section sec-1 -->
## Shape

Telling you a workaround can go is kept separate from the workaround itself.
A probe names a package, the pin and system it was broken on, and every site
to revert. The fix stays where it is needed (DEC-016), in whatever form it
takes: a local overlay, a `mkForce false`, an `optional isLinux`, a skip.

```
workarounds/default.nix          probes (plain data); applies nothing
   │
   ├──> flake.workaroundProbes   each probe + storePath (its unpatched outPath)
   │      (from inputs.<pin>, no overlays)
   │
   └──> workarounds/check        narinfo on cache.nixos.org
          200 ─> "candidate: remove <sites> (<issue>: <reason>)"   exit 1
          404 ─> ok
          else ─> "unknown"  (warn; network or cache error)
        runs: end of update-system / update-home (non-fatal there), on demand

fix sites (unchanged in kind, beside their consumer):
   overlay in hosts/<h>/config.nix   mkForce in modules/home/darwin   features/platform-skips.nix
   last-known-good leaf app ──> workarounds/last-good.nix {rev; narHash} pkgs attr

bin/will-build                   dry-run: what this build compiles locally
```

Decisions: DEC-052 (rename), DEC-053 (probes, fixes local), DEC-054
(lastGood), DEC-055 (removal check), DEC-056 (transient skips), DEC-057
(will-build, nom). Evidence: `research/research.md`. An informal codex
devil's-advocate pass before drafting changed DEC-052 through DEC-057
(notes.md).

Drafting deviation from DEC-053: the registry is `workarounds/default.nix`,
not `overlays/workarounds.nix`. It patches nothing, so `overlays/` would
mislead. Its probe output, check, helper and tests sit beside it. DEC-053,
DEC-055 and DEC-056 were corrected at reconcile (RV-027 F-2).

Every phase is drv-neutral except P4, where both homes gain
`nix-output-monitor` (RV-025 F-7).
<!-- doctrine:section sec-2 -->
## Probes and the removal check

A probe is a record in the list in `workarounds/default.nix`:

```nix
{
  attr = ["atuin"];                 # path in the pin's package set
  pin = "nixpkgs-home";             # flake input: nixpkgs | nixpkgs-home
  system = "aarch64-darwin";
  issue = "ISS-007";
  reason = "18.23.0 not cached for aarch64-darwin; local build fails";
  sites = [                         # every place to revert, repo-relative
    "modules/home/cli.nix"
    "modules/home/darwin/default.nix"
    "features/platform-skips.nix"
  ];
  # signal = "manual";              # runtime bug: listed, never probed
}
```

All keys are required except `signal`. A flake-parts module,
`workarounds/probes.nix`, validates them (unknown key, missing key, wrong
type, a `pin` that is not an input, an `issue` that is not a backlog-shaped
id) and fails evaluation naming the probe. This is the same discipline as
`host-meta.nix`. probes.nix checks for a missing key itself: the module
system's own message names neither the file nor the probe.

**`flake.workaroundProbes`** is the list with `storePath` added: the
derivation's `.outPath`. The field cannot be called `outPath`, because nix
serialises any attrset with an `outPath` attribute as that bare string under
`--json`. It is computed from
`import inputs.${pin} { inherit system; config.allowUnfree = true; }`
with no overlays, so it is the derivation Hydra would build (research X-2). A
manual probe gets `storePath = null`. An `attr` missing from the pin is an eval
error naming the probe. A package that left nixpkgs needs its probe
rewritten, not silently skipped.

**`workarounds/check [pin]`** (bash, jq, curl) evaluates the output once,
with the pin filter (`workarounds/pin-filter.nix`, shared with the test)
applied in Nix (`--apply`) before any `storePath` is forced. A broken probe
on the home pin then cannot abort `update-system`'s check (RV-025 F-3). For
each probe it fetches `https://cache.nixos.org/<hash>.narinfo`, where `<hash>`
is the first 32 characters of the storePath's basename (the store hash, not
the lock's `narHash`). It classifies the result:

| result | state | output | exit |
|---|---|---|---|
| HTTP 200 | cached | `candidate: remove <sites> (<issue>: <reason>)` | 1 if any |
| HTTP 404 | absent | `ok <attr> (<system>)` | — |
| other, or curl fails | unknown | `unknown <attr>: <curl error>` | — (warn) |
| `signal = manual` | manual | `manual <attr> (<issue>): check by hand` | — |
| usage error, or the probes fail to evaluate | — | message on stderr | 2 |

The narinfo request is the cache protocol itself, so 404 and a network
failure are cleanly told apart. `nix path-info` folds both into one non-zero
exit. "Cached" means the build failure is gone. A runtime bug needs
`signal = manual`, and removing any workaround is still proven by the next
build (DEC-055). Unfree packages are never on cache.nixos.org, so a probe for one must be
`signal = manual`. Validation refuses an unfree attr without it, by reading
`meta.unfree`, so a probe that can never fire is never written
(RV-025 F-2).

**Wiring.** `update-system` and `update-home` end with
`-workarounds/check <pin>`. The leading `-` makes the line non-fatal in
`just`, so `update` still runs `update-home` and `everything` still switches
(the workaround is still in place, so switching is safe). The output is the
signal. `just workarounds-check` runs it alone and fails on a candidate.
Neither `just test` nor the gate queries the network.
<!-- doctrine:section sec-3 -->
## Last-known-good replacement

`workarounds/last-good.nix` is a function, not a module:

```nix
# lastGood { rev; narHash; } pkgs [ "foo" ]  ->  foo from that nixpkgs
{ rev, narHash }: pkgs: attr:
  pkgs.lib.getAttrFromPath attr (import (builtins.fetchTree {
    type = "github"; owner = "NixOS"; repo = "nixpkgs"; inherit rev narHash;
  }) {
    inherit (pkgs.stdenv.hostPlatform) system;
    config = pkgs.lib.filterAttrs (_: v: v != null) pkgs.config;
  })
```

`pkgs` supplies the system and config (allowUnfree), so the old package is
built the way the current one would be. Null-valued settings are dropped:
nixpkgs 24.11 reads a present `replaceStdenv = null` as set and calls it. `fetchTree` with `narHash` is pure
(research: 0.3 s). Each distinct rev is fetched and evaluated once.

It is used where the fix lives: in a local overlay
(`final: prev: { foo = lastGood r prev ["foo"]; }`), or directly in a
package list. It is for **leaf apps**: their old closure, old libc included,
sits beside the current one without conflict. A library that other packages
depend on gets a local patch of the current package instead
(`override` / `overrideAttrs` / `overridePythonAttrs`) (DEC-054). The
function's comment says this. It does not try to detect libraries.

`workarounds/last-good <input>` prints the `{ rev; narHash; }` to paste
(there is no just recipe). It
resolves the input to its lock node through `root.inputs` (node names are
not input names: `nixpkgs` is node `nixpkgs_28`, RV-025 F-5). It reads git
through an explicit `GIT_DIR` (`$FLAKES_GIT_DIR`, default `~/.cfg`), because
discovery fails on the Mac (justfile:26-29). It reads the lock by its path
relative to the work tree (`flakes/flake.lock`). It uses `HEAD`'s lock, or,
when the working lock equals HEAD (the breaking update is already
committed), the previous commit that changed `flake.lock`. `last-good
stable` prints the stable node, so stable needs no mechanism of its own.
"Last good" is the previous *lock*: when the last lock change moved only
other inputs, it prints the input's current rev (IDE-007).

It exits 2, with a message, on a usage error, an unknown input, a `follows`
input, an input not locked to github NixOS/nixpkgs (lastGood fetches only
that), no lock at `HEAD`, or a lock that only one commit ever changed.

Every lastGood use gets a probe like any other fix.
<!-- doctrine:section sec-4 -->
## Skip list rename and transient skips

`features/cli-broken.nix` becomes `features/platform-skips.nix` (DEC-052).
The content stays, and so do DEC-036's semantics: per-system names compared
with `lib.getName`. `features/available.nix` imports the new path. Comments
in `features/profiles/personal-darwin.nix` and `hosts/Draupnir/features.nix`
follow, as do README § Feature tree and § Features, DEC-036's body and
choice, and the memory `mem.fact.flakes.availableon-limits` (scope paths and
body).

The transient skips get probes (DEC-056). The file's comment points at
`workarounds/default.nix` for them:

| probe attr | pin / system | issue | sites |
|---|---|---|---|
| `atuin` | nixpkgs-home / aarch64-darwin | ISS-007 | `modules/home/cli.nix`, `modules/home/darwin/default.nix`, `features/platform-skips.nix` |
| `killall` (getName `shell_cmds`) | nixpkgs-home / aarch64-darwin | new CHR | `features/platform-skips.nix` |
| `yed` (getName `yEd`; unfree, `signal = manual`) | nixpkgs-home / aarch64-darwin | same CHR | `features/platform-skips.nix` |

shell_cmds and yEd were skipped by the user's choice (SL-008 PHASE-07 VH-1),
not because they are broken. The shell_cmds probe asks whether it is now
cached, which is when the choice can be revisited. yEd is unfree, so it is
never cached: its probe is manual, and the chore says what to check (build
time on the Mac). One chore covers both. Probe attrs are nixpkgs attribute
names, verified: `killall` (name `killall-shell_cmds-329`), `yed`
(`features/docs.nix:16`, pname `yEd`) (RV-025 F-2).
<!-- doctrine:section sec-5 -->
## Pre-build list and nom

**`bin/will-build <installable>…`** runs `nix build --dry-run --no-link`
with the caller's flags and parses the "will be built" block from stderr. It
then reads `preferLocalBuild` from one batched `nix derivation show`, and
prints:

```
will build locally (2):
  python3.14-click-threading-0.5.0
  foo-1.2
config (4): activate etc etc-nix-registry.json nixos-system-Sleipnir-…
will fetch: 812 paths
```

"Config" is a short, commented list of name patterns: `etc`, `etc-*`,
`activate`, `unit-*`, `*-units`, `system-path`, `nixos-system-*`,
`darwin-system-*`, `home-manager-generation`, `home-manager-files`,
`hm_*`, `*.json`, `*.conf`, `man-paths`, `user-environment`. It also includes
any drv that sets `preferLocalBuild`, in either encoding (plain
`env.preferLocalBuild`, or inside structured attrs' `env.__json`). Config
names are grouped on one line and counted, never dropped (codex F6): it exits
1 if the groups do not add up to nix's own count. A dry-run counts the local store too, so a
previously built uncached drv is not listed. That cache-only question is the
probe's job.

**`just will-build [system|home|all]`** passes this host's system output
(nixos or darwin, chosen by just's `os()`, as for `flake`) and/or
`homeConfigurations."david@<host>".activationPackage`, with
`{{local_override}}`. It runs on demand, and it is the last line of
`update-system` (system output) and `update-home` (home output), after the
check, also prefixed `-`, as `-just host='{{host}}' will-build <which>` so a
`host=` override reaches it.

**nom for home.** `home-switch` and `home-build` become
`set -o pipefail; home-manager … --log-format internal-json -v 2>&1 | nom --json`.
pipefail keeps home-manager's exit status: without it, a failed switch exits
with nom's 0. The recipes write `2>&1 |`, not `|&`, because just runs lines
with `sh`, which is bash 3.2 on the Mac (RV-025 F-8). `run.sh` (bash, Linux)
gains `set -o pipefail` (it has the same hole).

The pipe is the justfile variable `nom_pipe`, empty when `nom` is not on PATH.
A home built before nom joined the home base (Draupnir's first switch) then
switches with plain output instead of failing (RV-027 F-1).

nom is not installed on Draupnir today. It is only in the NixOS base
(`modules/nixos/nix.nix:89`) and the unloaded dev shell (`perSystem.nix:13`).
`nix-output-monitor` joins the home base (`modules/home/cli.nix`). It is
cached for aarch64-darwin (RV-025 F-7).
<!-- doctrine:section sec-6 -->
## Phases and verification

| phase | change | `just drvs` diff |
|---|---|---|
| P1 rename | § Skip list rename, without the probes | none |
| P2 probes | `workarounds/default.nix`, `probes.nix`, `check` + `check-test`, the three probes, update wiring, `just workarounds-check` | none |
| P3 lastGood | `last-good.nix` + its flake check, `last-good` + its test | none |
| P4 will-build, nom | `bin/will-build` + test, `just will-build`, update wiring, `nix-output-monitor` in the home base, home recipes and `run.sh` via nom with pipefail | the three home outputs (`david@Sleipnir`, `david@Draupnir`, the `david` alias) and `coverage.home@aarch64-linux`: + nix-output-monitor (Sleipnir's may dedupe with the system copy); nothing else |
| P5 docs | README § Workarounds (new) and § Features rename, DEC-036, DEC-053 path, memory | none |

Tests (red, green, refactor). All run offline in `just test`:

- `workarounds/check-test`: a `nix` stub returns a fixture `workaroundProbes`
  JSON, and a `curl` stub records each requested URL and maps it to a status.
  Cases: one cached → exit 1, with the sites and issue in the output; the
  requested URL for fixture `/nix/store/<32 chars>-name` is exactly
  `https://cache.nixos.org/<32 chars>.narinfo`; all absent → exit 0; curl
  failure → `unknown`, exit 0; manual → listed, curl never called; pin filter
  → only that pin's probes, and it is passed to the `nix eval --apply`.
- `checks.<system>.workarounds`: a fixture probe set evaluated through
  `probes.nix`. Valid → storePath equals `pkgs.hello`'s outPath. Each invalid shape →
  eval fails naming the probe (unknown key, missing key, bad pin, missing
  attr, unfree without `signal = manual`). A deliberately throwing probe on
  one pin does not stop forcing the other pin's (F-3). `lastGood` at the
  stable node's rev returns stable's `hello`, which differs from the current
  one, so a historical revision is really selected (F-5). There is no extra
  fetch: stable is already an input.
- `workarounds/last-good-test`: a throwaway bare repo used through `GIT_DIR`
  with a separate work tree, as on the Mac, holding two lock commits whose
  `root.inputs.nixpkgs` points at a renamed node (`nixpkgs_3`). Dirty lock →
  HEAD's node. Clean → the previous commit's. `stable` → the stable node.
- `bin/will-build-test`: a stub `nix` emits recorded dry-run stderr and
  derivation JSON. Real drvs are listed, config is grouped and counted, and
  nothing is lost: listed plus config equals total.
- nom pipefail: a recipe-level check that a failing stub command through
  `2>&1 | nom --json` exits non-zero (VA if nom cannot be stubbed).

Per phase: `just test`, `just coverage` and `just drvs` before and after
(mem.pattern.flakes.drv-gate), and `nix fmt` on touched files without
committing the emacs-overlay re-lock (mem.fact.flakes.fmt-relock).

Closure (VA): a live `just workarounds-check` reports the three probes with
their real states today. Record them, do not assert them: cache state moves.
`rg cli-broken` finds nothing outside `.doctrine/` history.
<!-- doctrine:section sec-7 -->
## Code impact and docs

```
workarounds/default.nix        new: probe list (atuin, shell_cmds, yEd)
workarounds/probes.nix         new: flake-parts module, validation, flake.workaroundProbes,
                                    checks.<system>.workarounds
workarounds/check{,-test}      new
workarounds/last-good.nix      new: lastGood function
workarounds/last-good{,-test}  new
bin/will-build{,-test}         new
flake.nix                      imports workarounds/probes.nix
features/cli-broken.nix     →  features/platform-skips.nix (comment points at probes)
features/available.nix         path
features/profiles/personal-darwin.nix, hosts/Draupnir/features.nix   comments
modules/home/cli.nix           + nix-output-monitor; atuin comment names the probe
modules/home/darwin/default.nix   atuin comment names the probe
justfile                       test (+3 tests, +check), update-system, update-home,
                               home-switch, home-build, workarounds-check, will-build
run.sh                         set -o pipefail
README.md                      § Workarounds (new), § Feature tree, § Features
DEC-036, DEC-053               path references
mem.fact.flakes.availableon-limits   path
```

README § Workarounds holds the probe shape, the check's states and when they
appear, lastGood with its leaf-app rule, `last-good`, `will-build`, and the
two fix forms with an example each.

New backlog item: a chore for shell_cmds and yEd (§ Skip list). Noted, not
filed here: `stable` is nixos-24.11, which is EOL (research), so an
improvement to bump it.
