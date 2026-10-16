<!-- doctrine:section sec-1 -->
## Shape

Two root causes, three changes, plus a meta schema. Nothing here touches the
resolver, the feature record shape or the agents flake.

```
before                                          after
──────                                          ─────
flake.nix  goad/panopticon/satan-* = ~/dev      every input = github:…
flake.lock agents, oubliette → local sources    no path / file:// node (guarded)
justfile   agents_ / home_ / system_override    local_override = tree + dev
           oubliette hard-coded                 dev = checkouts present (bin/dev-checkouts)
hosts.nix  meta = bare import                   meta = host-meta.nix (evalModules)
           agentsOverlay → system, home,        agentsOverlay → legacyPackages only
           legacyPackages
modules/   nix.nix: registry.agents (base)      features/agents.nix:
           home/linux/{eca,chatgpt}.nix           registry · eca · chatgpt
hosts/Sleipnir/home.nix imports eca, chatgpt    personal-linux selects agents.*
```

Decisions: DEC-037 (dev checkouts), DEC-038 (remote declarations, lock),
DEC-039 (meta validation), DEC-040 (overlay scope), DEC-041 (agents area).
Evidence: `research/research.md`.

Sleipnir's effective selection is unchanged (ADR-001 D7). Every derivation
change is named in § Phases and verification.

<!-- doctrine:section sec-2 -->
## Dev checkouts and the lock

### One script owns the checkout list

`bin/dev-checkouts` (bash, beside `bin/gate-probe`) holds the list of inputs
developed in a local checkout, and is the only place it is written:

```
oubliette goad panopticon satan-patcher satan-attrd
```

The checkout root is `${FLAKES_DEV:-$HOME/dev}`; a checkout is present when
`<root>/<input>/.git` exists. The overrides travel as one space-separated string
(just recipes, `read -ra` in `bin/gate-probe`), so the script refuses a root
containing whitespace, with an error naming it, rather than emit flags that
split wrongly (RV-019 F-3). Four verbs:

| verb | prints | used by |
|---|---|---|
| `override` | `--override-input <i> git+file://<root>/<i>` for each present checkout | `dev_override` |
| `stub` | `--override-input <i> path:<repo>/features/stub` for every listed input, present or not (the stub path from the script's own location) | `stub_override` |
| `ahead` | one warning line per present checkout ahead of its upstream (stderr); exit 0 | `update-local` |
| `names` | the input names, space-separated | `update-local` |

`satan` stays off the list: it is a GitHub input with no override today, and
adding one would change what Sleipnir builds.

`git+file`, not `path:`: only tracked files reach the store, which is what a
`github:` fetch of the same revision gives the Mac. panopticon, satan-patcher
and satan-attrd were `path:` and their checkouts hold ignored files (87 in
panopticon), so their consumers' derivations may change once (named in P1).

### The justfile

```just
# in-tree inputs: present wherever this justfile is
tree_override := "--override-input agents path:" + justfile_directory() + "/agents" \
  + " --override-input emacs path:" + justfile_directory() + "/emacs"
dev_override := `bin/dev-checkouts override`
local_override := tree_override + " " + dev_override
stub_override := `bin/dev-checkouts stub`
```

just runs backticks in the justfile's directory, so `bin/…` resolves there;
the script builds absolute URLs (`mem.fact.flakes.home-gate-derived-hash`:
a relative `path:` resolves against `$HOME`).

`agents_override`, `home_override` and `system_override` are removed. Every
recipe that carried any of them carries `local_override`:

| recipes | change |
|---|---|
| `test`, `gate`, `run`, `system-*`, `home-*`, `darwin-*`, `drvs`, `drvs-sets`, `coverage` | `local_override` |
| `isolation` | `tree_override` + `stub_override`, never `dev_override`, so no input is overridden twice |
| `bin/gate-probe` | evaluates `local_override` in both modes (was `home_override` / `system_override`) |
| `templates` line of `drvs` | unchanged (no override) |

Overriding an input an output does not use is inert, so one override set for
every recipe costs at most an extra checkout fetch.

### Lock-writing recipes

No lock-writing recipe passes `--override-input` (ISS-006; DEC-038):

```just
update-system:  nix flake update nixpkgs
update-home:    nix flake update nixpkgs-home home-manager neovim-nightly-overlay antigravity-nix
update-local:   bin/dev-checkouts ahead
                nix flake update satan agents emacs $(bin/dev-checkouts names)
```

`update-local` re-locks every input under development from its remote, after
warning about checkouts ahead of origin. It never pushes; `push-local` stays a
separate, explicit recipe (user, 2026-10-16).

### Declarations and the one-time re-lock

| input | declared as (after) |
|---|---|
| panopticon | `github:davidlee/panopticon` |
| satan-patcher | `github:davidlee/sloptower` |
| satan-attrd | `github:davidlee/satan-attrd` |
| goad | `github:davidlee/goad` |
| oubliette, agents | unchanged (already GitHub) |

All five `~/dev` repos were pushed on 2026-10-16 (`just push-local`). The
re-lock is `nix flake update agents oubliette goad panopticon satan-patcher
satan-attrd`, no override. The `flake.nix` and justfile comments about
ISS-006 go with it.

### The lock guard

`just test` fails when `flake.lock` holds a node whose locked source is local:

```
jq -e '[.nodes[].locked // empty | select(.type == "path" or ((.url // "") | startswith("file:")))] == []' flake.lock
```

That makes ISS-006 a regression test rather than a convention.

### What the Mac sees

The in-tree overrides exist there; no `~/dev` checkout does, so `dev_override`
is empty and the dev inputs come from the lock (GitHub). DEC-016's
consequence "every Mac evaluation must override the agents input" lapses: the
lock no longer names a Linux path. A Mac that later clones a checkout into
`~/dev` gets its override automatically (IMP-023's goad).

<!-- doctrine:section sec-3 -->
## Validating meta.nix

`host-meta.nix` (repo root, beside `features.nix`):

```nix
# lib: file: meta: validated meta
lib: file: meta:
  (lib.evalModules {
    modules = [
      {
        options = {
          kind = lib.mkOption {type = lib.types.enum ["nixos" "darwin"];};
          system = lib.mkOption {type = lib.types.str;};
          home = lib.mkOption {type = lib.types.bool; default = false;};
        };
      }
      {_file = file; config = meta;}
    ];
  }).config
```

- **Unknown keys** are refused by evalModules ("The option `x' does not
  exist"), naming `file`.
- **Wrong types** ("not of type one of nixos, darwin") name `file` too.
- **Missing `system`** reports "used but not defined" without the file;
  wrap with `builtins.addErrorContext "while validating ${file}"` so the trace
  names it. Exact wording is P2's.
- The returned config holds `_module`; strip it (`removeAttrs … ["_module"]`)
  so `hosts.<h>` stays plain data.

`hosts.nix` builds `hosts` through it, with `file` relative to the flake root
(`hosts/<h>/meta.nix`), and `deepSeq`s the result so a bad meta fails every
evaluation, not only that host's (ADR-002 D4 rule, DEC-006 `throw`). It runs
before `selections`. `meta.home or false` becomes `meta.home` (hosts.nix:48,
141). The header comment points at `host-meta.nix` instead of restating the
schema.

### Tests

`host-meta-test.nix`, the `features-test.nix` idiom (`lib.runTests`;
`tryEval` loses the message, so each failing fixture has a passing twin):

| test | fixture |
|---|---|
| `testMetaPasses` | `{kind = "nixos"; system = "x86_64-linux";}` → `home == false` |
| `testMetaUnknownKindFails` / twin | `kind = "nixso"` |
| `testMetaUnknownKeyFails` / twin | extra `homee = true` |
| `testMetaMissingSystemFails` / twin | no `system` |
| `testMetaHomeTypeFails` / twin | `home = "yes"` |

Wired as `checks.host-meta` in `perSystem.nix`, built by `just test`. The
existing `checks.factories` `classesOf` check stays.

<!-- doctrine:section sec-4 -->
## Agents

### The overlay applies only to legacyPackages (DEC-040)

`hosts.nix` drops `nixpkgs.overlays = lib.mkAfter [(agentsOverlay meta.system)]`
from `platformModule` (line 79) and the `agentsOverlay` entry from
`homeModule`'s overlay list (line 102). `legacyPackages` keeps it (line 202):
it is what `nix shell agents#codex` resolves through `nix.registry.agents`
(DEC-018, restated).

No module uses an injected name (research X-2, ✓ grep). The risk is
callPackage auto-arguments (`mem.fact.nix.callpackage-autoargs`): removing
`pkgs.codex`, `pkgs.claude`, … could change a package that takes one as a
defaulted argument. The drv gate decides; a diff means `/consult`, not a fix
forward.

`overlays/agents.nix` stays (legacyPackages' one user). The comment in
`hosts/Sleipnir/config.nix:10-11` about mkAfter ordering is updated.

### The agents area (DEC-041)

`features/agents.nix`, listed after `ai` in `features/default.nix`:

```nix
# Agents features, in projection order. Shape: README § Feature tree.
{lib, ...}: [
  {
    name = "registry";
    nixos = {inputs, ...}: { nix.registry.agents.to = { type = "path"; path = inputs.self.outPath; }; };
  }
  {
    name = "eca";
    platforms = lib.platforms.linux;   # bubblewrap jail
    homeManager = { … today's modules/home/linux/eca.nix body … };
  }
  {
    name = "chatgpt";                  # pkgs.llm-agents.chatgpt builds on aarch64-darwin too
    homeManager = {pkgs, ...}: { home.packages = [pkgs.llm-agents.chatgpt]; };
  }
]
```

- The registry's rationale comment moves with it from
  `modules/nixos/nix.nix:11-22`.
- eca needs no `requires`: it uses the `emacs` and `agents` *inputs*, not the
  `editor.emacs` feature.
- `features/profiles/personal-linux.nix` selects all three with `mkDefault`.
  Sleipnir imports it, so its effective selection is unchanged; Draupnir
  imports `personal-darwin`, so it gets none.
- Removed: `modules/home/linux/{eca,chatgpt}.nix`, their imports and the "W2
  exceptions" comment in `hosts/Sleipnir/home.nix:5-8`, the registry block in
  `modules/nixos/nix.nix`.
- `agents.registry` has only a nixos half. A home-only Linux host importing
  `personal-linux` would be refused (ADR-005 D6); none exists.

`features-test.nix`'s Sleipnir selection tests gain the three paths.

<!-- doctrine:section sec-5 -->
## Phases and verification

The SL-006..008 gate carries over (`mem.pattern.flakes.drv-gate`): `just drvs`,
`drvs-sets`, `probe`, `coverage`, `gate` immediately before the first edit of
each phase and after it. New files are `git add -N`ed before the gate
(`mem.fact.flakes.git-add-n`). One commit per phase.

| # | phase | allowed diff | proof |
|---|---|---|---|
| P1 | **dev checkouts and lock**: `bin/dev-checkouts` + tests, justfile variables and recipes, `bin/gate-probe`, declarations, one-time re-lock, lock guard, comments | `flake.lock`; Sleipnir drvs of consumers of panopticon, satan-patcher, satan-attrd (path: → git+file), each explained | script tests red first; lock guard red on the old lock, green after; with `FLAKES_DEV=/nonexistent`, `drvs` and `probe` evaluate; `drvs` matches the run with checkouts wherever the checkout is clean at its locked revision, and every remaining diff is attributed to a dirty or ahead checkout (RV-019 F-1; oubliette had a modified tracked file on 2026-10-16); `isolation` passes and still fails its negative control |
| P2 | **meta validation**: `host-meta.nix`, tests, `hosts.nix` | none | tests red first; every `drvs` line identical; a misspelled kind in a scratch copy fails `nix eval .#homeConfigurations` naming the file |
| P3 | **overlay scope** | none | every `drvs` line identical, `legacyPackages` included |
| P4 | **agents area**, README, `config.nix` comment | Sleipnir home: reorder only (`.manpath` hash; masked diff empty); `coverage."base@aarch64-linux"` loses the registry entry | system drvs identical (registry value unchanged); Sleipnir probe: packages and `home-path-links` identical; Draupnir identical; negative control: `agents.eca = mkForce false` drops `eca` from `home-path` |

A diff not in the table stops the phase (`/consult`).

**Absence simulation.** `FLAKES_DEV=/nonexistent` stands in for "a machine
without `~/dev`". It covers ISS-003 on Linux; the Mac's `os()` branch (the
`path:` flake reference) is covered by the VH run.

**VH (user, on Draupnir):** `just drvs` and `just probe` succeed; `just
isolation` passes.

**Close:** `git grep -n 'agents_override\|home_override\|system_override\|/home/david/dev'`
over tracked files under `flakes/` (excluding `.doctrine/`) finds nothing;
`jq` lock guard green; `just gate` and `just coverage` green.

<!-- doctrine:section sec-6 -->
## Code impact and docs

| path | change | phase |
|---|---|---|
| `bin/dev-checkouts` (new) + `bin/dev-checkouts-test` (new) | the checkout list and its three verbs; behaviour tests | P1 |
| `justfile` | override variables, recipes, lock guard in `test`, `update-*`; comments | P1, P2 (test line) |
| `bin/gate-probe` | `local_override` | P1 |
| `flake.nix` | four declarations; ISS-006 comments | P1 |
| `flake.lock` | re-lock | P1 |
| `host-meta.nix`, `host-meta-test.nix` (new) | schema, tests | P2 |
| `perSystem.nix` | `checks.host-meta` | P2 |
| `hosts.nix` | meta via schema; header; overlay out of platformModule/homeModule | P2, P3 |
| `hosts/Sleipnir/config.nix` | overlay-ordering comment | P3 |
| `features/agents.nix` (new), `features/default.nix` | the area | P4 |
| `features/profiles/personal-linux.nix` | selects `agents.*` | P4 |
| `features-test.nix` | Sleipnir selection tests | P4 |
| `modules/nixos/nix.nix` | registry block out | P4 |
| `modules/home/linux/eca.nix`, `chatgpt.nix` | deleted | P4 |
| `hosts/Sleipnir/home.nix` | imports out | P4 |
| `README.md` | § Feature tree (agents area), § Bootstrap macOS (override paragraph), a short § Dev checkouts | P1, P4 |

### Records at reconcile

| record | change |
|---|---|
| ISS-003, ISS-006, IMP-010 | resolved |
| IDE-002 | closed, not adopted (DEC-037) |
| DEC-016 | overlay clause and Mac-override consequence amended by DEC-040 |
| DEC-018 | restated: legacyPackages is the overlay's only carrier |
| DEC-027, DEC-031 | content: registry out of the base; eca/chatgpt exception ended |
| DEC-034 | the stub set is the dev-checkout list (oubliette added) |
| HYP-001 | evidence: W2 needed no factory selection read |
| RFC-001 | W2, W6 done |

