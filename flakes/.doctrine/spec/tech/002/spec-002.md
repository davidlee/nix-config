# SPEC-002: Host composition

<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

Host composition turns a directory of hosts and a tree of features into the
flake's configurations. Each host chooses features. One resolver, run once
per host outside every module evaluation, checks the choice and hands each
of the host's evaluations the modules it selected.

```
hosts/<h>/meta.nix ──host-meta.nix──> host table (kind, system, home)
hosts/<h>/features.nix ─imports─> features/profiles/*.nix
          │                                   │
          └─────────────┬─────────────────────┘
                        ▼
features/ (tree) ──> features.nix: one lib.evalModules per host
                        │  structural checks, then selection checks; any failure throws
                        ▼
                 modules.{nixos, homeManager, darwin}
                        │  appended after the host's own entry module
          ┌─────────────┼──────────────────────┐
          ▼             ▼                      ▼
       mkNixos       mkHome                 mkDarwin
  nixosConfigurations homeConfigurations   darwinConfigurations
  .<h>               ."david@<h>"          .<h>
     ▲ nixpkgs          ▲ nixpkgs-home        ▲ nixpkgs
     └ modules/nixos    └ modules/home/{linux,darwin} └ modules/darwin
       (base)             (home base + layer)           (darwin base)

coverage.<target>: the same factories, with a feature no host selects turned on
```

C4 level: container. Its parts (resolver, factories, bases, coverage) are
sections below, not specs of their own. There is no product spec; the why
is the goal in RFC-001: adding a host should be cheap, and a capability
should be switchable per host without surgery.

**Posture: retrospective.** This describes composition as shipped by SL-001
to SL-010 (2026-10). Requirements are `pending` until reconciled against
evidence; the tests named in each are where that evidence lives
(`features-test.nix` and `host-meta-test.nix` run as
`checks.<system>.{features,host-meta}` in `just test`).

ADR-001 to ADR-005 are this container's architecture. This spec composes
them with the decisions that followed; where it restates an ADR, the ADR
wins.

**Reading order.** Someone adding a feature, profile or host reads § Author
contract. A maintainer reads on. Operations (commands, the current feature
list, notes on specific features) stay in README § Features and § Hosts.

## Author contract

What a feature, profile or host author may rely on and must do. It changes
only by decision.

### Features

A feature is a plain attribute set, never itself a module (ADR-002 D1):

```nix
{
  name = "snooze";                   # required: non-empty, no "."
  nixos = _: { … };                  # one ordinary module per evaluation it touches
  homeManager = _: { … };
  darwin = _: { … };
  requires = [ "<area>.<name>" … ];  # prerequisites; never selected for you
  platforms = lib.platforms.linux;   # absent: every system (DEC-030)
}
```

No other key is allowed. A misspelt class key would otherwise drop that half
silently.

**Addressing.** A feature is `<area>.<name>`, never a file path. An area is
one file, `features/<area>.nix`, a written list of its features.
`features/default.nix` lists the areas. List order is projection order.
Nothing is discovered from directories (ADR-002 D2, D7; DEC-015).

**Placement.** A feature's halves stay together and are never split by
platform. A feature that would dominate its area file (about 100 lines
prompts the judgement) moves to `features/<area>/<name>.nix` and is listed
as `(import ./<area>/<name>.nix)`. A record too big for that file may import
modules of its own from `features/<area>/<name>/`, listed in the half that
uses them. Assets sit beside their feature (ADR-002 D3).

**Switch.** Each feature gets `feature.<area>.<name>.enable`, default
`false`. Nothing is selected automatically (FR-006).

### Profiles and hosts

A profile (`features/profiles/*.nix`) is an outer module that selects with
`lib.mkDefault`. A host's `hosts/<h>/features.nix` imports profiles and
overrides any of them with a plain definition (ADR-001 D3).

| who selects | what | why |
|---|---|---|
| `personal` | editors and every cli feature; portable | the user's own machines, either platform (DEC-033) |
| `personal-linux`, `personal-darwin` | `personal`, plus that platform's personal features | Linux-only records cannot reach a Mac (DEC-030) |
| `workstation` | desktop stack, pipewire, docker, snooze, app formats, dictate; Linux-only | what any desktop workstation wants (DEC-024) |
| the host | what is bound to its hardware, site, data or taste: compositors, games, printing, capsule | wrong to inherit (DEC-024) |

A profile that selects a feature also selects its prerequisites (ADR-001
D4).

### Refusals

Every check is enforced: a failure throws, so no part of the result can be
read. There are two scopes.

| scope | refused when | requirement |
|---|---|---|
| every host | an area or feature is not a record (a listed path is named as such); a name is missing, empty, dotted or repeated; `requires` or `platforms` is not a list of strings; a descriptor key is unknown; `requires` names no feature; an outer option sits at a feature's path (a second switch, DEC-025) | FR-003 |
| this host | a selected feature's prerequisite is not selected | FR-001 |
| this host | a selected feature has no module for any of the host's evaluations, or its `platforms` omit the host's system | FR-002 |
| this host | a hand-written `assertions` entry in an outer module is false | NF-001 |
| every host | a `meta.nix` has an unknown key, a wrong type or a missing option | FR-008 |

A host-scoped failure refuses all of that host's evaluations, its home
included (NF-001).

Diagnostics differ by kind:

| error | names |
|---|---|
| structural | the area and feature path, or the position in the list (`feature #3 in area virt is a path …`) |
| selection | feature paths only (`feature.a.x requires feature.a.y, which is not selected`) |
| meta | the file, through the module system (`while validating hosts/<h>/meta.nix`) |
| inside a projected module | file, line and feature: `features/session.nix:20 (session.snooze#nixos)`, from its `_file` (FR-005) |

### What an author may rely on

- **Unselected is unevaluated.** An off feature's modules and package
  expressions are never forced, so a broken one blocks no host (FR-004).
  Only the record itself (its keys, `name`, `requires`, `platforms`) is read.
  A *parse* error in an area file still breaks every host; `nix fmt` parses
  every file.
- **Order is the written order** (FR-005). Moving a feature between areas
  moves it in every merged list; see § Concerns, merge order.
- **No module sees the selection** (FR-007). A module cannot ask whether
  another feature is on. A conditional that depends on the selection is
  written in the composition layer, visibly, and never expands the
  selection (ADR-004 D2, D3).
- **Settings are not selection** (ADR-004 D6). Setting a value never
  selects a feature. Where a value lives:
  - Tunable of one selected implementation: an ordinary downstream option,
    declared by the feature and set by the host (ADR-004 D5). Setting an
    option *declared only by an unselected feature* is an evaluation error,
    by design. An upstream option (`services.postgresql.*`) is declared
    whether or not the feature is selected, so setting it succeeds; using
    it to recreate an excluded capability breaks a convention (§ Concerns),
    not a check.
  - Shared by system and home, or needed during composition: a typed option
    in the outer evaluation; or, for a fixed fact or a value a consumer
    outside the flake needs, a plain constant in one file every consumer
    imports (ADR-004 D4). Today only the second form exists
    (`agents/gateway.nix`). The resolver returns only modules (FR-007), so a
    typed outer setting would need the result extended to carry values,
    without carrying the selection. That is unbuilt.

### Where config lives

Each piece of config belongs to exactly one of these. This replaces
`modules/DESIGN.md`'s checklist, which placed code by evaluation class.

| class | where | holds |
|---|---|---|
| NixOS base | `modules/nixos/default.nix` and its imports | what every NixOS host needs to function (DEC-027, DEC-042, DEC-044) |
| darwin base | `modules/darwin/default.nix` and its imports | what every darwin host needs |
| home base | `modules/home/default.nix`, under one platform layer `modules/home/{linux,darwin}/` | what every home needs (DEC-031, DEC-042) |
| feature | a record in `features/` | anything optional |
| machine config | `hosts/<h>/machine.nix` | bound to the machine's parts: microcode, mounts, GPU, swap (DEC-019) |
| host config | `hosts/<h>/config.nix`, `home.nix` and files beside them | bound to the host's site, account or tuning: stateVersion, DNS, OOM tuning (DEC-028) |
| parked | `parked/` | does not evaluate; imported by nothing; promised nothing (ADR-005, DEC-043) |

Deciding, in order:

1. Would some host of this kind work without it? Then it is not base.
2. Bound to this machine's parts? Machine config.
3. Bound to this host's site, account or tuning? Host config.
4. Otherwise a feature. Within the record, the system half takes daemons,
   root and system users. The home half takes interactive userland, which
   breaks more often and gains from the faster, sudo-less home cycle
   (§ Concerns, lifecycles).
5. Broken, with no plan to repair it now? Parked, not an off feature.

Each package or config file is provided once. The system and the home
should not both install the same thing. This is a convention; nothing
checks it.

### Configuration style

Nix is the package manager, not the configuration language. Prefer plain
dotfiles, tracked in the home repo, over `programs.*` wrappers. Where Nix
configuration is unavoidable, keep it slim: `programs.<x>.enable`, pointed
at a static file. Exceptions are pragmatic, where Nix buys something (a
store path, a generated value).

## Responsibilities

- Read the host table from `hosts/*/meta.nix` and validate it (FR-008).
- Resolve each host's feature selection once, outside every module
  evaluation (ADR-001).
- Refuse a malformed tree or an invalid selection before anything is built
  (FR-001, FR-002, FR-003, NF-001).
- Project selected features into each evaluation in tree order (FR-005).
- Build each host's system and home as separate configurations on separate
  pins (NF-002).
- Hold the NixOS base, the darwin base, the home base and its platform
  layers.
- Keep off features evaluated through coverage targets (FR-009).

Not its job: what any one feature configures (the LLM gateway is SPEC-001);
the jail library (`agents/`, CHR-020); the emacs flake; workaround probes
(README § Workarounds); the dev-checkout override and lock policy, which cut
across containers (DEC-037, DEC-038; CHR-019's context spec).

## Mechanism

### Host table

`hosts.nix` reads `./hosts`: every directory holding a `meta.nix` is a host.
Each `meta.nix` is validated by `host-meta.nix`, an `evalModules` schema
(`kind` ∈ {nixos, darwin}, `system`, `home` default false), and the whole
table is forced with `deepSeq`, so reading any host validates every one
(DEC-039). A host's evaluations are its kind, plus `homeManager` when
`home = true` (`classesOf`).

The justfile picks the host by `hostname -s`; `just host=<h> …` overrides.
`homeConfigurations.david` is a transitional alias for `david@Sleipnir`.

### Resolver

`features.nix` is `lib -> { tree, classes, system, modules } -> { modules }`:

```
tree ──flatten──> records (area, name, path, descriptor)
   │
   ├─ options: feature.<area>.<name>.enable (mkEnableOption), assertions
   ├─ checks:  per selected record, requires / lands-somewhere / platforms
   ▼
lib.evalModules { options, checks, host features.nix, profiles, extras }
   │
   ├─ structural ≠ [] ──> throw "feature tree is malformed"
   ├─ failed assertions ≠ [] ──> throw "feature selection failed"
   ▼
modules.<class> = map { _file = "<file>:<line> (<path>#<class>)"; imports = [ descriptor.<class> ]; }
                  over selected records that have <class>, in tree order
```

The structural checks run in two stages. Shapes that later reads cannot
take (a non-record, a non-string name, a non-list `requires`) are reported
alone. A missing attribute or a type error there would abort uncatchably.
`imports = [ value ]` never forces the value, so projection keeps the
exclusion boundary (ADR-002 D4). Provenance comes from
`builtins.unsafeGetAttrPos "name"`. It is flake-relative for records
written here; a record built by a helper reports the helper's line.

### Factories

One resolution per host (`selections`), shared by every factory for that
host (NF-001). A factory passes host identity only
(`specialArgs = { inputs, username, hostname }`), plus one injected module;
the evaluator builds `pkgs` (DEC-016):

| factory | pkgs from | injected | entry module |
|---|---|---|---|
| `mkNixos` | `nixpkgs` (evaluator) | `nixpkgs.hostPlatform`, `stable` module arg | `hosts/<h>/config.nix` |
| `mkHome` | bare `import nixpkgs-home` | `allowUnfree`, overlays (lem, claude-desktop, llm-agents), `stable` | `hosts/<h>/home.nix` |
| `mkDarwin` | `nixpkgs.source` (evaluator; darwin follows `nixpkgs`) | as NixOS, plus `configurationRevision` | `hosts/<h>/config.nix` |

`stable` is a module argument, not a `pkgs` attribute: `callPackage` would
feed a `pkgs.stable` to every `stable ? …` default (DEC-016,
`mem.fact.nix.callpackage-autoargs`). Local package fixes are overlay
modules beside their consumer. `checks.factories` asserts that a darwin
module's overlay reaches darwin `pkgs` (ISS-004), and that `classesOf`
holds over kind × home.

### Bases and layers

The NixOS base is an import list every NixOS host imports first in its
`config.nix`. It has no switch (DEC-027). The home base cannot pick imports
by platform, so it sits under two layers, `modules/home/linux` and
`modules/home/darwin`, and each `home.nix` imports exactly one (DEC-031).
Bases hold only what every host of their kind needs; everything optional
is a feature, often as the system half of an existing one (DEC-042,
DEC-044).

### Availability filter

Portable cli features list packages through `features/available.nix`. It
keeps what `lib.meta.availableOn` accepts for the host platform, minus the
names `features/platform-skips.nix` lists for that system (DEC-036, DEC-052).
`availableOn` reads metadata only, so a package that fails to build or is
uncached on a platform is skipped by name. A transient skip also gets a
workaround probe (DEC-056).

### Coverage and isolation

`flake.coverage` holds handwritten targets built by the same factories:
`<host>+<feature>` selects one off feature on top of the host's own
selection (FR-009). `base@aarch64-linux` and `home@aarch64-linux` evaluate
the NixOS base and the home base with its Linux layer alone, headless and
off x86 (DEC-027, DEC-034). `just coverage` forces each target's system
`drvPath` or home activation `drvPath`. Targets sit off every switch path
and outside `just drvs`. `nix flake check` warns about the unknown output,
which is expected.

**What a target covers.** A target forces only the evaluation its factory
builds, on that factory's system. Every `<host>+<feature>` target today is
built by `mkNixos`, so it covers the feature's `nixos` half on
`x86_64-linux`, and nothing else: a selected half the target does not build
is never forced. FR-009 reads ADR-005 D1 as an obligation per half and per
platform: an off feature is covered when each half it has is forced by some
target on a system its `platforms` allow. The five off features today have
only a `nixos` half, so their targets meet it. The same holds for selected
features: a half no host evaluates (a `darwin` half of a feature only
Sleipnir selects) is off in effect, and uncovered.

**Isolation.** `just isolation` evaluates the lean homes
(`home@aarch64-linux`, Draupnir's home) with every input on the
dev-checkout list (`inputs` in `bin/dev-checkouts`, the one place it is
written; today fleet, goad, panopticon, satan-patcher, satan-attrd) replaced by `features/stub`, a flake whose
outputs are empty (NF-003). That fails any use of the input's outputs
(`packages`, `homeManagerModules`, …). It does not fail a use of the
input's source path, which the stub still has as `outPath`. So it proves the
lean homes need none of those inputs' outputs, not that they never
reference or fetch them (DEC-034, amended 2026-10-18 to say so).

### The derivation-identity gate

A refactor of composition must not change what any configuration builds
(`mem.pattern.flakes.drv-gate`). Three measures, each snapshotted before
the change and diffed after:

| measure | prints | shows |
|---|---|---|
| `just drvs` | every configuration's `drvPath` (and packages, legacyPackages, templates) | whether anything changed |
| `just drvs-sets` | per configuration, a count and a hash of its sorted package `drvPath`s | whether a package change is ordering-only |
| `just probe <dir> [attr]` | built measures: link maps of the system and home paths and home files, groups, kernel params, ports, udev rules, fonts | who wins a collision |

Acceptance (ADR-002 D5, DEC-035): `drvs` identical; or, where it differs,
every reorder proven harmless: the probe identical, or `nix-diff` shows list
order only. Matching `drvs-sets` alone proves neither, since a sorted set
cannot show which of two colliding paths wins. A flipped collision winner
stops the change. `just probe` measures one host's system and home by
default; a change that moves another configuration probes it by attr, or
says why the measured one stands for it. The probe has no darwin system
mode, so a darwin system that moves is proven by `nix-diff`.

## Concerns

- **Lifecycles and pins** (ADR-003). The system follows `nixpkgs`, updated
  conservatively by `just update-system`. The home follows `nixpkgs-home`,
  updated more often by `just update-home`, and activates without sudo.
  Both track `nixos-unstable`; they differ in when they move. `stable`
  (`nixos-24.11`) is the escape hatch for a package broken on unstable. A
  feature's two halves can be live at different generations. System and
  home cannot read each other's config, so a cross-boundary dependency (home
  services on a system PostgreSQL) is a `requires` edge, checked as intent
  only.
- **Merge order.** List options merge in reversed breadth-first import order
  (`mem.fact.nix.merge-order`), so moving a feature or reordering areas can
  change derivations without changing meaning. Every such move passes the
  gate. A flipped collision winner stops the move (ADR-002 D5, DEC-035).
- **Exclusion boundary limits.** The boundary isolates evaluation failures,
  not parse errors. The resolver must never traverse into a class value:
  testing that an attribute is present is fine, reading one is not.
- **Conventions nothing enforces.** A module can enable an upstream service
  (`services.postgresql.enable`) whether or not the matching feature is
  selected (ADR-001 D6). One provider per package (§ Where config lives) is
  not checked either.
- **Coverage completeness is by hand.** Nothing checks that every half of
  every feature is forced by some host or target on a supported system
  (§ Coverage and isolation). `testOffFeatures` pins four of the five off
  features (not `hardware.openrgb`). `Sleipnir+speech` is now redundant:
  Sleipnir selects `audio.speech` (commit `53c79623`), so the host itself
  covers it.
- **Coverage is evaluation only** (ADR-005 D5). An upstream build failure
  in an off feature stays hidden until it is built.

## Hypotheses

- Two levels of addressing (`<area>.<name>`) are enough; no area needs
  sub-areas.
- No graph composition is needed: prerequisites stay shallow enough that a
  host or profile listing them by hand is cheaper than automatic expansion
  (ADR-001 Neutral: a reference closure could be added on top if one is
  needed).
- A handwritten coverage set stays small (five off features today).
- The descriptor walk stays cheap enough to run for every host on every
  evaluation (IMP-013 would walk the tree once).

## Decisions

The decisions this spec composes. Read one with `doctrine show DEC-NNN`.

| area | ADRs and decisions |
|---|---|
| selection, profiles | ADR-001, DEC-024, DEC-025, DEC-033 |
| feature shape, tree | ADR-002, DEC-015, DEC-023, DEC-026, DEC-032, DEC-035 |
| platforms, availability | DEC-030, DEC-036, DEC-052, DEC-056 |
| lifecycles, factories | ADR-003, DEC-016, DEC-017, DEC-018, DEC-039 |
| integrations, settings | ADR-004 |
| bases, placement | DEC-019, DEC-027, DEC-028, DEC-031, DEC-042, DEC-043, DEC-044 |
| coverage | ADR-005, DEC-022, DEC-034 |

## Open questions

- **A completeness check for coverage.** Should `just test` assert that
  every half of every feature is forced by some host or target on a system
  its `platforms` allow, and that no target is redundant? It would measure
  (feature, class, system) triples, not feature names. That would close the
  gap in § Concerns (IMP-039).
- **Isolation's strength.** Is "needs none of the stubbed inputs' outputs"
  enough for the planned guest, or must it also never fetch them? The
  stronger claim needs stronger evidence than an empty-output stub (§
  Coverage and isolation; DEC-034).
- **darwin's nix settings.** `modules/darwin/nix-core.nix` is imported by
  nothing (IMP-014).
- **Lean defaults and new hosts.** A headless profile for the planned
  aarch64 guest (RFC-001 W7), lean selection defaults (IMP-006) and a
  username per host (IMP-011) would each extend the author contract.
- **Parent.** This is a root container until CHR-019's context spec exists
  to hold it.
