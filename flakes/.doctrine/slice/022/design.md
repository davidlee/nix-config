<!-- doctrine:section sec-1 -->
## Arrangement and goal

Careful: two package sets are in play, and the whole design turns on which one instantiates what.
The **project** supplies the *tools*; the **consumer** supplies the *sandbox*. Nothing else moves.

```
   ~/dev/smut  (unchanged producer)            ~/flakes/dev-envs  (new consumer)
   packages.<system>.dev-tools ─────────────►  project input
   devShells.default  (stays its own)            │
                                                 ├─ packages.jail           jailed-pi, project tools inside
                                                 ├─ packages.devTools       the project's bundle, passed through
                                                 ├─ packages.quotient-read  delegate entry points
                                                 ├─ packages.quotient-write
                                                 ├─ devShells.jail          project tools + launcher + codex
                                                 └─ checks.stub, .quotient-forms
                                                       ▲                    ▲
        ~/dev/smut/.envrc (untracked) ─────────────────┘                    │
        use_dev_envs → use flake dev-envs#jail                              │
                       --override-input project git+file:<root>             │
                                                                            │
        ~/flakes/bin/dev-envs-forms → nix build -o .quotient/result-<c> ────┘
                                      → link .quotient/forms/<c>; then `quotient allow`
```

Today every project flake is two things at once. Smut's lock shows the cost: 7 root
inputs, 21 nodes, 11 of them reachable only through `agents`; two nixpkgs pins
stale and un-followed; and `nix flake update` in that project bumps `jail-nix`,
`llm-agents` and `bun2nix` into its public diffs.

The correction is an ownership split. A project owns "a shell that can build and
test this crate" — its `packages.<system>.dev-tools`, its own devshell, its gate.
This repo owns "a jail with my agents, profiles and packages". Three roles follow:
a **producer** exports `dev-tools`, a **consumer** (this slice) takes one and
builds a shell and a jail from it, and a **re-publisher** (Oubliette, `/srv/fleet`)
hands a bundle to a third party. Only the consumer is built here.

What this slice adds: one subflake, one direnv helper, one host linker, one
README section. What it does not touch: the root `flake.nix`/`flake.lock`, the
system or home evaluations, `_templates/agents`, `/srv/fleet`, and every tracked
file in Smut.

<!-- doctrine:section sec-2 -->
## The flake, in full

Everything the consumer is lives in one file. The sections after this one explain
each decision in it; the one thing to hold on to while reading is that **two package
sets are in play** — the project supplies the *tools*, the consumer supplies the
*sandbox* — and that no `follows` anywhere keeps each substitution visible at its
call site.

```nix
{
  description = "Personal development environments: a project's dev-tools, plus agents, forms and a jail";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # The jail library, declared by remote like the root flake's `emacs` and
    # `agents`; a read-only recipe overrides it to the in-tree checkout, so an
    # edit there lands without a push. `path:./agents` could not work: it would
    # have to resolve inside this flake's own store copy, where no such
    # directory exists (`?dir=flakes/dev-envs` and the Mac both hit it).
    agents.url = "github:davidlee/nix-config?dir=flakes/agents";

    # quotient's form-family builder. Passed in here rather than carried by
    # every project — which is the whole point of the split.
    quotient.url = "github:davidlee/quotient/v0.6.0";

    # The project whose tools this environment carries. A RELATIVE path, so the
    # lock records `path = "./stub-project"` and a store copy still resolves it.
    # Every real use overrides it, read-only:
    #   --override-input project "git+file:$(git rev-parse --show-toplevel)"
    #   --no-write-lock-file
    # Without the second flag the override is written into this lock and pins
    # one machine's checkout (ISS-006's class of bug).
    project.url = "path:./stub-project";
  };

  outputs = {
    nixpkgs,
    agents,
    quotient,
    project,
  }: let
    # bubblewrap is Linux-only, and the direnv helper refuses any other host
    # before it touches nix, so there are no Darwin outputs to define: an
    # attribute that cannot evaluate poisons `nix flake check`.
    systems = ["x86_64-linux" "aarch64-linux"];
    forAll = f: nixpkgs.lib.genAttrs systems f;

    perSystem = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) lib;

      # The jail's SANDBOX comes from here; its TOOLS come from the project.
      jailLib = agents.lib.${system}.mkJailedAgents {inherit pkgs;};

      # The producer contract, named once, so its absence says what to do
      # instead of naming an attribute path at the bottom of a stack trace.
      devTools =
        project.packages.${system}.dev-tools or (throw ''
          dev-envs: the project flake exposes no packages.${system}.dev-tools.
          The producer contract is packages.<system>.dev-tools = buildEnv { … }:
          every tool the project's gate needs.
        '');

      # $PWD is bound read-write at /workspace/<project> and the jail starts
      # there (the library's default, DEC-078). Workspace dependencies arrive
      # through JAIL_WORKSPACE_DEPS{,_RW}, the library's own mechanism.
      jail = jailLib.makeJailedPi {
        profile = "specDev";
        allowSelfAsSubagent = true;
        maxSubagentDepth = 2;
        gateway = jailLib.gatewayClient "pi";
        extraPkgs = [devTools]; # a buildEnv is ONE derivation, not a list
      };

      # A form is a delegate's world, so it carries the same tools as the jail.
      forms = jailLib.quotientFormFamily {
        inherit quotient;
        packages = [devTools];
      };
    in {
      packages = {
        inherit jail devTools;
        quotient-read = forms.read;
        quotient-write = forms.write;
      };

      # What the project's own devshell used to borrow from its jail block: the
      # agent CLI, from the same evaluation as the jail's agents — one pin.
      devShells.jail = pkgs.mkShell {
        packages = [devTools jail jailLib.unjailed.codex];
      };

      checks = {
        # The contract, executable. `packages.jail` is NOT the launcher: with a
        # gateway it is `gatewayJail.wrap inner` (agents/gateway-jail.nix), which
        # checks the key file and run directory and then `exec`s the real one, so
        # the bundle sits one indirection down and grepping the wrapper finds
        # nothing. Follow exactly one `exec` — a deeper chain fails at the check
        # rather than being chased — and resolve the target through
        # `builtins.readFile`: a store *reference* of the wrapper is not a build
        # input, while reading it carries the reference in the string's context.
        #
        # Observed on the built stub jail: the inner launcher carries
        # `--setenv PATH …:<dev-tools>/bin:…`, i.e. the bundle's own path, and
        # nothing flattens it into member paths. So the bundle is the one needle
        # and the stub's `probe` stays the contract's fixture, not a needle.
        stub = let
          launcher = "${lib.getBin jail}/bin/jailed-pi";
          execTargets =
            lib.filter (l: lib.hasPrefix "exec ${builtins.storeDir}/" l)
            (lib.splitString "\n" (builtins.readFile launcher));
          inner =
            if execTargets == []
            then ""
            else lib.elemAt (lib.splitString " " (lib.head execTargets)) 1;
          needles = [devTools];
        in
          pkgs.runCommand "dev-envs-stub-check" {} ''
            … # grep each needle in $launcher and in $inner, then touch $out
          '';

        # The only static guard on the forms' bwrap line, which must stay plain
        # words: anything quotient cannot resolve without running it fails here.
        quotient-forms = quotient.lib.checkFormFamily {
          inherit pkgs;
          family = forms;
        };
      };
    };
  in {
    packages = forAll (system: (perSystem system).packages);
    devShells = forAll (system: (perSystem system).devShells);
    checks = forAll (system: (perSystem system).checks);
  };
}
```

| output | for whom | content |
|---|---|---|
| `packages.<system>.jail` | the operator, the shell | `makeJailedPi`; bin name `jailed-pi` |
| `packages.<system>.devTools` | the pin oracle | `project.packages.<system>.dev-tools`, untouched |
| `packages.<system>.quotient-read` | the host Quotient, via the linker | the `read` form |
| `packages.<system>.quotient-write` | the same | the `write` form |
| `devShells.<system>.jail` | direnv | `[ devTools jail jailLib.unjailed.codex ]` |
| `checks.<system>.stub` | this repo's gate | the producer contract, executable |
| `checks.<system>.quotient-forms` | this repo's gate | `checkFormFamily` over the family |

There is deliberately **no `default` alias**: a bare `dev-envs#` must not silently
mean one project's agent. `devTools` is spelled differently from the producer's
`dev-tools` on purpose — the producer's name is a contract it signs, this one is a
pass-through, and the two must not be confusable in the `nix eval` comparison that
proves the pins survived (§ Verification).

<!-- doctrine:section sec-3 -->
## Reaching a project (DEC-100)

The project is a flake input so it can be overridden per checkout. The committed
default is a relative path inside the flake (see § The flake, in full); Nix records
it as `path = "./stub-project"` — **relative**, verified by experiment rather than
assumed, which is what lets a store copy still resolve it.

Every real reach overrides it, in exactly three places and nowhere else: the direnv
helper, the host linker, and the `justfile` (which overrides `agents`, never
`project`). The helper is the whole interaction:

```bash
#!/usr/bin/env bash
# shellcheck shell=bash
# direnv helper for the layered dev environments (SL-022). A project's .envrc:
#
#   source_env_if_exists ~/flakes/envrc/dev-envs.sh
#   use_dev_envs || use flake .
#
# `||`, not `if has …; then …; else …; fi`: a guard that returns 1 inside the
# `then` branch does not run the `else`, which is how every absent case below
# falls back to the project's own devshell.
#
# source_env watches this file, so an edit here reloads every project sourcing it.

# `use_dev_envs [args]`: land in ~/flakes/dev-envs#jail with this checkout as the
# project input. Extra args pass through to `use flake`.
use_dev_envs() {
  # bubblewrap is Linux-only. Not a fallback: the caller's `||` is.
  [[ $(uname -s) == Linux ]] || return 1

  # git+file, not path: tracked content only, so a target/ directory never
  # enters the store. The toplevel, not $PWD: running from a subdirectory must
  # still name the project, and the jail binds the launch directory.
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1

  # The agents lib reads JAIL_WORKSPACE_DEPS{,_RW} with getEnv, which pure
  # evaluation answers with "", so either set means --impure.
  local impure=()
  [[ -n ${JAIL_WORKSPACE_DEPS:-}${JAIL_WORKSPACE_DEPS_RW:-} ]] && impure=(--impure)

  # A project edit changes the tools, so reload on its flake; a consumer edit
  # changes the jail, so reload on that too (`use flake` watches the ref it was
  # given, which is the consumer, but being explicit costs two lines).
  watch_file "$root/flake.nix" "$root/flake.lock" \
             "$HOME/flakes/dev-envs/flake.nix" "$HOME/flakes/dev-envs/flake.lock"

  # --no-write-lock-file: the override must never land in dev-envs' lock.
  use flake "path:$HOME/flakes/dev-envs#jail" \
    --override-input project "git+file:$root" \
    --no-write-lock-file "${impure[@]}" "$@"
}
```

The three disciplines, and why each is not optional:

- **`git+file:`, not `path:`.** `path:` copies the whole directory on every
  evaluation, `target/` and untracked scratch included; `git+file:` takes tracked
  content only (a project's dirty *tracked* edits still participate).
- **`git rev-parse --show-toplevel`, not `$PWD`.** A shell opened in `src/` must
  still name the checkout, and the jail binds the launch directory.
- **`--no-write-lock-file`, always.** Without it the override is recorded into
  `dev-envs/flake.lock` as a `path`/`git file:` node, and the consumer silently
  pins this machine's checkout. `nix print-dev-env` accepts the flag (checked), so
  the direnv path can carry it.

`envrc/agents.sh` is **not** refactored to share this. The two helpers differ in
kind, not in arguments: `use_flake_local` retargets inputs of the *current* flake,
while this one substitutes a *different* flake for the current one. A shared helper
would parameterise away the only thing they have in common. That trailing arguments
reach `nix print-dev-env` through nix-direnv is not an assumption — `use_flake_local`
relies on it today, and `envrc/agents-test` covers it.

<!-- doctrine:section sec-4 -->
## The jail (DEC-101)

One jail, and its record is Smut's own `jailed-pi` record with the project's bundle
substituted — so gate parity is inherited rather than invented.

```nix
jailLib = agents.lib.${system}.mkJailedAgents { inherit pkgs; };   # pkgs = dev-envs' nixpkgs

jail = jailLib.makeJailedPi {
  profile = "specDev";              # shared persistent home, network on, SSH push blocked,
                                    # sandboxed git identity
  allowSelfAsSubagent = true;
  maxSubagentDepth = 2;
  gateway = jailLib.gatewayClient "pi";
  extraPkgs = [ devTools ];         # [ projectTools ] ++ [] — the buildEnv is ONE derivation
};
```

Supplying `pkgs` to `mkJailedAgents` is the whole point of the split: the launcher's
`rust`, `just`, `mold`, `sccache` are the project's pins, while its `bwrap`, `zsh`
and the subagent bridges are the consumer's. The agent binary itself comes from
`llm-agents` inside `agents`, which keeps its own pin on purpose.

Fixed in this slice, deliberately: the launcher name and agent (`pi`), the profile,
the gateway, the subagent set, packages beyond the project bundle, and the forms
list. A configuration surface designed against one project is a guess; the
per-project record map (`jails.<name>`, extras files, project keys) returns in step
4, when a second real project needs one.

Defaults that are part of the jails' behaviour, not of this flake: `mountLaunchDir`
binds `$PWD` read-write at `/workspace/<project>` and starts there (DEC-078), and
workspace dependencies arrive through `JAIL_WORKSPACE_DEPS{,_RW}` — the library's
own mechanism, which is why the helper adds `--impure` only when one is set.

Consequence, accepted: two nixpkgs in one closure. Collisions are reported at the
outer `buildEnv`; noise there is expected, a real collision is a finding.

<!-- doctrine:section sec-5 -->
## Quotient forms (DEC-102)

A form is a delegate's world, so it must carry the same tools as the jail it belongs
to — otherwise a delegate behaves differently from the agent that spawned it, and
"works for the form, fails for the jail" is the hardest bug in this pattern.
`quotientFormFamily` forwards `packages` to quotient's `mkFormFamily`
(`agents/jailed-agents.nix:213-236`; `quotient/nix/form-family.nix:9`), and
`packages` is what a form's PATH is built from (see § The flake, in full).

A family member is two derivations, and the link must name the outer one. The
family's default prefix names the *launchers* `jailed-quotient-read` /
`jailed-quotient-write`; the member itself is
`writeShellScriptBin "quotient-<c>"`, which takes the session directory and
`exec`s that launcher from another store path. The flake names the outputs
`quotient-<capability>`, so the link target is
`<result>/bin/quotient-<capability>` — an executable regular file, which is what
quotient's `probeProjectForm` requires. Linking the launcher instead is dangling,
and quotient refuses it (`form-invalid`). The *linked file* name is the bare
capability word, which is what the host's Quotient reads.

Neither the jail nor the shell carries a form derivation. Building forms into every
jail would enlarge each jail's closure and still not select them — selection needs
files in the checkout, and approval is a human act. So the build belongs to the
consumer, the installation to the operator:

```bash
#!/usr/bin/env bash
# Link this checkout's Quotient forms: build the consumer's form packages for the
# project in this checkout, and point .quotient/forms/<c> at each one.
#
#   dev-envs-forms [--project <flake-ref>] [read|write…]      default: read write
#
# `-o .quotient/result-<c>` is what keeps a form alive: that store symlink is a GC
# root, and the outward link in .quotient/forms is not. Selection and approval
# stay outside this script — `quotient allow` is the operator's act.
set -euo pipefail

repo=$(cd "$(dirname "$0")/.." && pwd)
flake="path:$repo/dev-envs"
project=""
capabilities=()

usage() { echo "usage: dev-envs-forms [--project <flake-ref>] [read|write…]" >&2; }

while [[ $# -gt 0 ]]; do
  case $1 in
    --project) project=${2:?--project needs a flake ref}; shift 2 ;;
    -h | --help) usage; exit 0 ;;
    -*) usage; exit 2 ;;
    *) capabilities+=("$1"); shift ;;
  esac
done

if [[ -z $project ]]; then
  root=$(git rev-parse --show-toplevel 2>/dev/null) \
    || { echo "dev-envs-forms: not in a git checkout; pass --project <flake-ref>" >&2; exit 1; }
  project="git+file:$root"
fi

[[ ${#capabilities[@]} -gt 0 ]] || capabilities=(read write)

mkdir -p .quotient/forms
for c in "${capabilities[@]}"; do
  nix build -o ".quotient/result-$c" \
    "$flake#quotient-$c" \
    --override-input project "$project" \
    --no-write-lock-file
  # The target is `bin/quotient-<c>` — the wrapper that takes the session
  # directory and execs `bin/jailed-quotient-<c>` from another derivation. Quotient
  # refuses a link that does not resolve to an executable file, so the design's
  # first draft, which linked the launcher, was dangling.
  ln -sfn "$(readlink -f ".quotient/result-$c")/bin/quotient-$c" ".quotient/forms/$c"
  echo "dev-envs-forms: linked .quotient/forms/$c"
done
```

It never approves. `quotient allow` stays an explicit operator act, and because a
form's executable identity changes when the project's toolchain does, a toolchain
change means re-running the linker and re-approving — a line for the README, not a
mechanism to automate away.

<!-- doctrine:section sec-10 -->
## The stub project and the repo gates (DEC-103, DEC-104)

A factory that refuses without an override cannot be checked, and cannot tell "my
input is wrong" from "your project is wrong". So the flake carries the producer
contract's smallest executable form as its default input.

```nix
# dev-envs/stub-project/flake.nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = {nixpkgs, ...}: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAll = f: nixpkgs.lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});
  in {
    packages = forAll (pkgs: {
      dev-tools = pkgs.buildEnv {name = "stub-dev-tools"; paths = [pkgs.hello];};
      probe = pkgs.hello; # the same derivation, named for the check
    });
    devShells = forAll (pkgs: {default = pkgs.mkShell {packages = [pkgs.hello];};});
  };
}
```

`probe` exists for one reason: `jail.nix` may render a bundle into PATH as the
bundle's own `/bin` or flatten it into its members. The check (§ The flake, in
full) accepts either, and neither happens unless composition worked. It is a
fixture, not a contract term. No `stub-project/flake.lock` is committed: the stub
is a `path:` input, so its `nixpkgs` is locked in `dev-envs/flake.lock` as
`project/nixpkgs`.

The consumer joins this repo's gate the way its other subflakes do — invoked by
`path:`, read-only, from `just test`:

```make
  if [ "$(uname -s)" = Linux ]; then nix build "path:{{justfile_directory()}}/dev-envs#checks.$(nix config show system).stub" --override-input agents "path:{{justfile_directory()}}/agents" --no-link --no-write-lock-file; fi
  if [ "$(uname -s)" = Linux ]; then nix build "path:{{justfile_directory()}}/dev-envs#checks.$(nix config show system).quotient-forms" --override-input agents "path:{{justfile_directory()}}/agents" --no-link --no-write-lock-file; fi
  envrc/dev-envs-test
  bin/dev-envs-forms-test
```

`--override-input agents` appears **only** in these read-only recipes, the same way
`tree_override` works at the repo root: the committed lock keeps the published
`agents` flake, while local edits to `agents/` still land. `--no-write-lock-file`
on every line, because a check never re-locks. No new `just` verb: a second entry
point is a second thing to forget.

The lock guard is a **second, sharper rule** than the root's, and the difference is
deliberate:

```sh
# root (existing, justfile:64): no local source may be locked at all
jq -e '[.nodes[].locked // empty | select(.type == "path" or ((.url // "") | startswith("file:")))] == []' flake.lock

# dev-envs: the stub is legitimately a *relative* path node
jq -e '[.nodes[].locked // empty | select(((.url // "") | startswith("file:")) or (.type == "path" and ((.path // "") | startswith("/"))))] == []' dev-envs/flake.lock
```

The root rule forbids every path node, and `./stub-project` is one — applying it
verbatim would fail by construction and be deleted by the first person it blocked.
Both expressions were exercised during design against synthetic locks: the sharp
one passes a relative node and fails an absolute one.

<!-- doctrine:section sec-6 -->
## Failure modes (DEC-105)

Two questions deserve opposite answers: *is the personal layer available?* (absence
is normal — a contributor, the Mac, a fresh clone) and *is the personal layer
correct?* (never normal). So: degrade to **less** environment, never to a
**different** one silently.

| situation | behaviour | good? |
|---|---|---|
| no `.envrc` in a project | `use flake .` — the project's own devshell | yes; a fresh clone's default |
| `envrc/dev-envs.sh` absent | same; `source_env_if_exists` makes a missing file a no-op | yes |
| non-Linux host | `use_dev_envs` returns 1 before touching nix; the `.envrc`'s `\|\|` takes `use flake .` | yes |
| not a git checkout | same — the helper returns 1, because the project can only be reached as `git+file:` | yes |
| a `JAIL_WORKSPACE_DEPS*` set | the helper adds `--impure`; unset, evaluation stays pure | yes |
| personal flake fails to evaluate | **loud**: direnv shows the nix error, and the project devshell is *not* substituted | yes — a silently different shell is unresolvable |
| jail fails to build | **loud** | yes |
| project has no `packages.<system>.dev-tools` | **loud**, naming the attribute and the producer contract, at the input site | yes |
| project has no forms to link | the linker builds the consumer's own form outputs, so this is a build failure, not a silent no-op | yes |
| a form's binary changed | `quotient` re-asks for approval (its contract); the linker never approves | yes |
| Darwin | no outputs at all; the project devshell | yes |

<!-- doctrine:section sec-7 -->
## Code impact

| path | change |
|---|---|
| `dev-envs/flake.nix` | new: inputs, four package outputs, the shell, two checks (§ The flake, in full) |
| `dev-envs/flake.lock` | new: `nixpkgs`, `agents` (GitHub), `quotient`, `project` (the relative stub) |
| `dev-envs/stub-project/flake.nix` | new: the producer contract's smallest executable form |
| `envrc/dev-envs.sh` | new: `use_dev_envs`, the direnv entry point |
| `envrc/dev-envs-test` | new: bash behaviour test, direnv's stdlib stubbed as `agents-test` does |
| `bin/dev-envs-forms` | new: the host linker |
| `bin/dev-envs-forms-test` | new: bash behaviour test |
| `justfile` | four `test` lines (two checks, two script tests) and one lock-guard line |
| `README.md` | § Jailed Agents gains the producer/consumer split, the join steps, the form workflow, the fallback rule |

Not touched: root `flake.nix` / `flake.lock`, `agents/`, `emacs/`, `dev-tools/`,
`_templates/agents/`, `/srv/fleet`, any tracked file in `~/dev/smut`, and the system
and home evaluations — the whole slice sits outside every host and home evaluation,
which is also why `just drvs` cannot move.

<!-- doctrine:section sec-8 -->
## Verification

**VT** — by test, in the repo's existing idiom.

- `dev-envs#checks.<system>.stub`: the stub's `dev-tools` reach the launcher's
  bwrap line; builds the stub bundle and the launcher only.
- `dev-envs#checks.<system>.quotient-forms`: `quotient.lib.checkFormFamily` over
  the consumer's family — the only static guard on the forms' bwrap line.
- `envrc/dev-envs-test`: the absent cases return 1 (non-Linux, no git root, not a
  checkout); a checkout yields `--override-input project git+file:<toplevel>`;
  `--impure` appears exactly when a workspace-dep variable is set; `watch_file`
  names the project's and the consumer's flake.
- `bin/dev-envs-forms-test`: `read` and `write` linked into `.quotient/forms/`,
  each resolving to a form binary; `.quotient/result-<c>` exists as the GC root; a
  second run is idempotent; `--project <ref>` overrides the toplevel; outside a
  checkout without `--project` it exits 1 and says so.

**VA** — by agent, because they need a real build and a real checkout.

- **Pin fidelity.** `nix eval ~/dev/smut#packages.<system>.dev-tools.drvPath` equals
  `nix eval "path:$HOME/flakes/dev-envs#packages.<system>.devTools.drvPath"
  --override-input project "git+file:$HOME/dev/smut" --no-write-lock-file`.
  Inequality is a design failure, not a test flake.
- **Gate parity.** `nix develop "path:$HOME/flakes/dev-envs#jail" --override-input
  project "git+file:$HOME/dev/smut" --no-write-lock-file --command just gate` is
  green, and the run reports the same `rustc`/`just`/`mold` store paths as Smut's own
  devshell.
- **The jail works.** `jailed-pi` launches from the shell, binds the checkout at
  `/workspace/<project>`, answers through the LLM gateway, and carries no provider
  key.
- **No host drift.** `just drvs` before and after is identical.
- **Smut untouched.** `git -C ~/dev/smut status --porcelain` shows nothing new on
  tracked paths.

A flakeref does not expand `~`. `path:~/…` and `git+file:~/…` reach nix with a
literal tilde and fail, and an unquoted `#` in an interactive zsh with
`extendedglob` is a glob operator — so every ref above is written with `$HOME`
inside double quotes, which is what `envrc/dev-envs.sh` does too. A bare argument
may keep `~`, because there the shell expands it at the start of the word.

**VH** — by the operator.

- `~/flakes/bin/dev-envs-forms` in a Smut checkout, then `quotient allow`, then a
  `read` delegate runs in the linked form.
- Optionally, point Smut's untracked `.envrc` at `use_dev_envs` and confirm the same
  gate from a fresh shell — one line, reversed in one line, no tracked file changed.

<!-- doctrine:section sec-9 -->
## Handover to planning

What the phase plan should take from this design.

**Three phases, in this order:**

1. **The flake and its contract.** `dev-envs/flake.nix`, `flake.lock`,
   `stub-project/`, and `checks.stub`. Ends green on
   `nix flake check`/`nix build` against the stub, with no helper existing yet — the
   factory must be provable before anything consumes it.
2. **The two entry points.** `envrc/dev-envs.sh` + `envrc/dev-envs-test`, then
   `bin/dev-envs-forms` + `bin/dev-envs-forms-test`. Ends green on the two bash
   tests.
3. **Wiring and the proof.** The `justfile` lines and both lock guards, the README
   section, then the VA/VH evidence against an unmodified Smut (pin fidelity, gate
   parity, jail launch, forms approval). Ends green on `just test` and the
   pin-fidelity comparison.

Phase 3 is deliberately last: everything before it can be built and tested without
touching a project, and the proof is worth nothing until the thing it proves exists.

**What a phase must not do**, because each is a decision above rather than a choice
to re-open: add a `follows` to any input; add an extras file, project key or second
jail; edit `envrc/agents.sh`; touch any tracked file in Smut or anything under
`/srv/fleet`; give the jail the form derivations; or let a `path:` override reach a
committed lock.

**One environment caveat the phase sheets must carry.** In a confined agent session
the home repo's git directory (`~/.cfg`) and `~/.cache` are read-only: `git add -N`
and commits fail, and a git-resolved flake ref cannot see a file the session just
created. Phases therefore evaluate through `path:~/flakes/dev-envs#…` with
`XDG_CACHE_HOME` redirected to a writable directory, and the operator (or a
non-confined session) does the staging and the commit
(`mem.fact.flakes.confined-session-ro`). Builds themselves work.

**Where the review should look hardest.** Two claims are the ones that would hurt
most if wrong: that `quotientFormFamily`'s `packages` really is what a form's PATH
is built from (it is asserted from `form-family.nix`'s signature, not from a form
that was built and inspected), and that `jail.nix` renders the project bundle into
the launcher's text in one of the two forms the stub check accepts. Both are cheap
to falsify in phase 1 — build the launcher and read it.

