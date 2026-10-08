# Multi-host: modular hosts, profiles, and a NixOS VM target

Strategy and execution plan in one doc, after the REFACTOR.md / EXECUTION.md
pattern. Written to be picked up cold by an agent session: read **Context**
and **Working rules** first, then take the first ⬜ slice in **Status**.

## Goal

Make adding a host cheap. The immediate consumer is `nixosvm` (placeholder
name): a headless aarch64 NixOS guest under UTM on a personal M2 MacBook, used
as a persistent dev environment over SSH. Near-term: a work Mac (darwin, no
personal tooling, probably M3+ so the capsule can run in a guest there).
Longer-term options this should keep open, but not build:

- x86_64 and aarch64 guests of the same profile (e.g. VMs on Sleipnir)
- Lima / microvm-style hosts
- guest-mounted sources (VirtioFS) instead of a self-contained checkout

Modularity is the point as much as the VM. Every slice should leave the repo
easier to extend even if the VM never lands.

## Context (current state, as of 2026-10-09)

```
flake.nix  (flake-parts)
├─ nixosConfigurations.Sleipnir      x86_64-linux   hand-rolled let-block, one host
├─ darwinConfigurations.Davids-MacBook-Pro
│                                    aarch64-darwin hand-rolled, HM as darwin module
└─ homeConfigurations.david          x86_64-linux   standalone HM, Sleipnir hardwired
```

- **Feature flags** (`modules/features.nix` declarations, `features.nix`
  resolver, `hosts/<host>/features.nix` overrides) are injected as a
  `specialArg` and gate **imports**. See README § Feature flags. Most flags
  default to `true`, i.e. defaults describe Sleipnir, not "a host that says
  nothing".
- **NixOS modules** are listed flat in `hosts/Sleipnir/config.nix`: base,
  desktop, hardware and Sleipnir-only modules interleaved. No shared base.
- **Home**: `profiles/linux-desktop.nix` = `modules/home/shared` +
  `modules/home/linux`. `home/linux/default.nix` unconditionally imports
  desktop apps. Personal / Sleipnir-only home modules (satan*, behaviour,
  nudge, goad, eca, walker, chatgpt, sleipnir-doctor) are listed in
  `hosts/Sleipnir/home.nix`. `darwin/home.nix` imports `home/shared/*`
  file-by-file (skipping `shpool.nix`, which is systemd).
- **x86_64 hardcoding**: `systems` in flake.nix; `overlays/agents.nix:10`
  (`inputs.agents.lib.x86_64-linux` — the comment explains why it can't read
  `prev.system`); `modules/nixos/nix.nix:92` (nix-search-tv);
  `legacyPackages` / `packages` outputs.
- **Host hardcoding**: `run.sh` (`#Sleipnir`), justfile `home-*` (`.#david`),
  `network.nix` (Sleipnir's static `enp8s0` profile), `alarm.nix`
  (`spotifydDevice = "Sleipnir"`).
- **Capsule (oubliette)** is smeared across `capsule.nix`, `network.nix`
  (`vm-capsule` firewall + `capsule-forward` nftables table), `security.nix`
  (sudo rule for `nft list table inet capsule-forward`), `user.nix`
  (`assigner` user). The capsule is a microvm, so it needs KVM; in a UTM guest
  that means nested virt (Apple: M3+ / macOS 15+). M2 → off.
- **Jailed agents**: `overlays.agents` (system + home pkgs), `nix.nix`
  `registry.agents`, `eca.nix`, `chatgpt.nix`. Should become a flag.
- **Local-path inputs** (panopticon, satan-patcher, satan-attrd, goad,
  oubliette via override) exist only on Sleipnir. Nix fetches inputs lazily, so a
  config that never touches them evaluates elsewhere (darwin already relies on
  this). The VM's config must not reach them, which the `personal` profile
  boundary below enforces.

## Target shape

```
flake.nix ── imports ./hosts.nix (flake-parts module)
                │
                ├─ host table: readDir ./hosts → hosts/<host>/meta.nix
                │               { kind = "nixos"; system = "aarch64-linux"; home = true; }
                ├─ mkNixos  { hostname, system }  → nixosConfigurations.<host>
                ├─ mkHome   { hostname, system }  → homeConfigurations."david@<host>"
                └─ mkDarwin { hostname, system }  → darwinConfigurations.<host>

profiles/                         (composition only — lists of imports)
  nixos-base.nix       nix, user, ssh, network(base), cli, env, security, locate, maintenance, podman …
  nixos-desktop.nix    audio, greeter, wayland*, x11, xdg, qt, umbriel, oom, desktop flags …
  home-base.nix        home/shared (cross-platform) — used by darwin too
  linux-headless.nix   home-base + shpool + linux CLI bits
  linux-desktop.nix    linux-headless + home/linux desktop apps
  personal.nix         satan*, behaviour, nudge, goad, alarm …  (layer, not flag)

hosts/
  Sleipnir/   config.nix = nixos-base + nixos-desktop + hardware + Sleipnir bits
              home.nix   = linux-desktop + personal + sleipnir-doctor
  nixosvm/    config.nix = nixos-base + guest hardware
              home.nix   = linux-headless
  Davids-MacBook-Pro/  (darwin host bits; darwin/ stays the shared darwin base)

features:  defaults all off; each host opts in.
           new: agents.enable, agents.capsule
```

Two gating mechanisms, each for its own job:

| mechanism | for | example |
|---|---|---|
| feature flag | a coarse, independent on/off switch | `agents.capsule`, `desktop.niri` |
| profile layer | a coherent role made of many modules | `personal`, `nixos-desktop` |

Profiles are plain import lists. A flag is right when a host might want the
switch independently. A profile is right when the modules only make sense
together.

## Working rules (all slices)

- **No `git stash`, no `git checkout`, no `git clean`.** `~` is the work tree.
- **New files must be `git add`ed before eval.** `.` is a git flake; untracked
  files are invisible to Nix and you'll get "path does not exist".
- Lint/format after every file: `nix fmt` (treefmt: alejandra + statix),
  zero warnings. **`nix fmt` re-locks `emacs/emacs-overlay`**: the committed
  lock is stale against flake.nix's `inputs.emacs-overlay.url` override. Don't
  commit that drift in a slice. Restore with
  `git show HEAD:flakes/flake.lock > flake.lock`, or pass `--no-write-lock-file`.
- Conventional commits, one per slice (or a few small ones); `git add ~/flakes/…`.
- The user commits to this repo between slices. **Re-read every file you touch
  at slice start**; do not trust line numbers in this doc.
- Update README.md for whatever the slice changes (feature table, hosts,
  justfile usage) in the same slice.
- Update the **Status** table (status, commit, notes) at the end of the slice.
- Prefer the smallest diff that achieves the slice. Note any design
  opportunities you spot in **Notes / findings** rather than widening scope.

### The gate: derivation identity

Most slices are refactors and must not change what Sleipnir (or the Mac)
builds. Compare `.drvPath` (evaluation only, no build) before and after:

```bash
just drvs > "$SCRATCH/before"   # BEFORE editing — snapshot of the tree as found
# … make the slice's changes, git add new files …
just drvs > "$SCRATCH/after"
diff "$SCRATCH/before" "$SCRATCH/after"
```

- Baseline = the tree as you found it, user's uncommitted edits included. That
  is why no checkout is needed and why the user's work never blocks a slice.
- A diff is a **red gate** unless the slice lists it as expected. Investigate
  with `nix-diff <before.drv> <after.drv>`. A difference caused only by
  ordering (e.g. a list that merges in a different order because an import moved)
  can be accepted if it is understood and written down in Notes.
- aarch64 hosts: **eval only** (`drvPath` resolves). Do not build; no binfmt.
- Darwin evaluates from Linux (verified S0).
- `drvs` pins two values that vary with the repo rather than the config
  (see the justfile comment): the `agents` registry path (the flake's own
  source, so any edit under flakes/ changed Sleipnir's drv) and darwin's
  `configurationRevision`. If a later slice adds another reference to
  `inputs.self` / `self.rev`, the gate goes noisy. Pin it in `drvs` the same
  way.
- stderr is chatty (fetch logs, nixpkgs warnings); redirect it when
  snapshotting: `just drvs 2>/dev/null > …`.

### Lessons from S0–S2 (read before S3+)

- **Moving an import changes list order.** Merged list options
  (`environment.systemPackages`, `sudo.extraRules`, `extraGroups`, …) are
  concatenated in import-tree DFS order. Moving modules into a profile, or
  one level deeper, reorders them and changes the drv without changing the
  closure. S4/S5 will hit this constantly. To keep the gate exact, put the
  profile import **where the modules were**, with the same internal order.
  When it still differs, prove it's ordering-only:
  ```bash
  nix-diff OLD.drv NEW.drv | head -40      # find the first differing input drv
  # then compare that drv's env (structured attrs live in env.__json):
  nix derivation show X.drv | python3 -c 'import json,sys; e=list(json.load(sys.stdin).values())[0]["env"]; print(json.dumps(json.loads(e.get("__json","{}")),indent=1,sort_keys=True))'
  ```
  It's ordering-only if the same store paths appear and only their order
  differs. Record each accepted one in Notes, with the new baseline.
- **Use `git add -N` (intent-to-add) for new files** before any eval. It makes
  them visible to the git flake without staging their content.
- **The `~` work tree is dirty outside flakes/.** Commit explicit paths only;
  never `git add -A` / `git commit -a`.
- **`just -n` doesn't run backticks**, so a dry run prints `` `hostname` ``
  literally. Use `just --evaluate host` to see the value.
- **Unexplained, and moot because of the pin:** darwin's `configurationRevision`
  was `<rev>-dirty` before a commit and null after it, even though `~` stays
  dirty. Don't build anything on `self.rev` / `self.dirtyRev` behaving
  predictably under Lix with `?dir=flakes`.
- `just drvs` takes about a minute. Snapshot in the background while you read code.

## Slices

Each slice ends green, committed, and leaves main usable.

### S0 — gate tooling

Add a `drvs` recipe to the justfile that prints `name drvPath` for **every**
configuration (generic via `--apply builtins.mapAttrs …`, so new hosts are
covered automatically), using the same `--override-input` flags as the
matching switch target (`system_override` for nixos, `home_override` for home
and darwin). Evaluation only.

Exit: `just drvs` prints Sleipnir system, `david` home, darwin (or Notes
explains why not). Expected diff: n/a.

### S1 — parameterise `system`

- `systems` += `aarch64-linux`.
- `overlays/agents.nix`: take `system` as an argument instead of hardcoding
  (`{inputs, system}: inputs.agents.lib.${system}.agentsOverlay {}`); callers
  pass it. Keep the comment explaining why `prev.system` is off-limits.
  **Check** `inputs.agents.lib` has `aarch64-linux`; if not, record it. It
  then blocks `agents.enable` on the VM (S6/S8), not this slice.
- `nix.nix`: `inputs.nix-search-tv.packages.${pkgs.stdenv.hostPlatform.system}`.
- `legacyPackages` / `packages`: produce for each linux system (move into
  `perSystem` or map over a list. Keep the existing comments' reasoning).

Exit: gate identical for Sleipnir + home.

### S2 — host factories

- New `hosts.nix` flake-parts module (imported like `overlays.nix`) with
  `mkNixos`, `mkHome`, `mkDarwin`. `flake.nix` `flake = {…}` shrinks to
  templates + outputs from `hosts.nix`.
- Host table is **derived from directories**, not hand-written: `readDir
  ./hosts`, and each `hosts/<host>/meta.nix` is a plain attrset
  (`{ kind = "nixos" | "darwin"; system = "…"; home = true; }`). Adding a host
  = adding a directory. Darwin's host dir is created here (holding at least
  `meta.nix`); `darwin/` stays the shared base.
- Per-host overlays: keep Sleipnir's list as-is in its table entry for now;
  record in Notes which could move into the module that needs them
  (e.g. `llama-prism` → `llama-cpp.nix`).
- `homeConfigurations."david@Sleipnir"`, plus `david` as an alias to the same
  value until the user drops it.
- `mkDarwin` takes `hostname`. Move host-specific darwin bits into
  `hosts/Davids-MacBook-Pro/` only if trivially separable; otherwise note.
- justfile / `run.sh`: host argument defaulting to `$(hostname)`
  (`system-switch host=…`, `home-switch host=…` → `.#david@{{host}}`).

Exit: gate identical (the `david` alias must produce the same drvPath as
before). Expected diff: new `david@Sleipnir` line only.

### S3 — collect capsule; `agents.capsule` flag

- Move capsule's pieces from `network.nix`, `security.nix`, `user.nix` into
  `capsule.nix` (comments travel with them).
- Add `agents.capsule` (declare under a new `agents` group in
  `modules/features.nix`; default `true` for now, inverted in S7). Gate the
  import in `hosts/Sleipnir/config.nix`.

Exit: gate identical, or an ordering-only diff in the sudo rules / users
explained in Notes.

### S4 — NixOS profiles

- Classify every active `modules/nixos/*.nix` as base / desktop / hardware /
  Sleipnir-only. First pass below. **Verify each by reading it**; a module that
  mixes concerns gets split, and the split is noted.

  | class | modules (first pass, unverified) |
  |---|---|
  | base | nix, user, ssh, network (minus Sleipnir wired profile), cli, env, security, locate, maintenance, podman, cargo, lib, boot, 1password(?), programs(?), postgresql(?) |
  | desktop | audio, bluetooth, greeter, keyring, qt, umbriel, wayland, wayland_packages, x11, xdg, util (dconf), oom, avahi(?) |
  | Sleipnir hardware | radeon, keyboard, kernel(?), hardware-configuration |
  | Sleipnir-only config | network's `enp8s0` static profile → `hosts/Sleipnir/network.nix` |

  `(?)` = likely mixed or personal. `programs.nix` and `1password.nix` in
  particular probably mix GUI and CLI. `postgresql` may belong to `personal`
  (satan's queue).
- Create `profiles/nixos-base.nix`, `profiles/nixos-desktop.nix`. Desktop
  feature-gated imports (sway, niri, cosmic, kde, mango, fonts, printing, …)
  move into `nixos-desktop.nix`. The rest stay in the host or base, by what
  they are.
- `hosts/Sleipnir/config.nix` becomes: profiles + hardware + Sleipnir bits.

Exit: gate identical or ordering-only (explained).

### S5 — home profiles + `personal`

- `profiles/home-base.nix`: the cross-platform `home/shared` set (what
  `darwin/home.nix` imports today, plus the `cli.nix` both hosts import
  separately). `darwin/home.nix` uses it.
- `profiles/linux-headless.nix`: home-base + `shpool.nix` + any linux-only CLI.
- Split `home/linux/default.nix`: desktop apps stay behind
  `profiles/linux-desktop.nix` = linux-headless + desktop set.
- `profiles/personal.nix`: satan, satan-patcher, satan-attrd, behaviour,
  nudge, goad, alarm (+ whatever S4 found, e.g. postgresql on the nixos side:
  give `personal` a nixos half if needed). sleipnir-doctor, walker stay
  Sleipnir host-level.
- Agent tooling (eca, chatgpt): leave host-level here; S6 gates it.

Exit: Sleipnir home identical or ordering-only; darwin identical or
ordering-only (explained).

### S6 — `agents.enable` flag

- Gate the jailed-agents surface: the agents overlay (system + home pkgs —
  `mkNixos`/`mkHome` can read `features` to choose overlays), `registry.agents`
  in `nix.nix` (split out to e.g. `modules/nixos/agents.nix`), eca, chatgpt
  (or chatgpt → personal; decide and note).
- Default `true` for now; inverted in S7.

Exit: gate identical.

### S7 — invert feature defaults

- Every flag defaults to `false` (`follows` stays). Sleipnir's
  `features.nix` names every flag it uses, including the ones it previously got
  by default (`snooze`, `agents.*`, …).
- README feature table: defaults column updated; text "defaults describe a
  host that says nothing" now true.

Exit: gate identical (Sleipnir resolves to the same flag set). Darwin: check
it reads no flag whose default flipped, or give it a features file.

### S8 — `nixosvm` host

- Host table entry: `system = "aarch64-linux"`.
- `hosts/nixosvm/`:
  - `hardware.nix`: hand-written, not generated. `qemu-guest.nix` profile,
    filesystems **by label** (`nixos`, `boot`), virtio initrd modules,
    `nixpkgs.hostPlatform`. Labels make the install reproducible: format with
    them, and the config is correct without running `nixos-generate-config`.
  - `config.nix`: `nixos-base` + `hardware.nix`. Networking via DHCP (no
    static profile). **DNS is open**: the user may want it through ControlD
    (as Sleipnir), or a work-specific setup. Ask before choosing; S4's base/host
    split of `network.nix` should keep the ControlD bits easy to opt into. Optional `virtualisation.rosetta.enable` behind a comment:
    it needs UTM's Apple Virtualization backend, not QEMU.
  - `features.nix`: `agents.enable = true` (if S1 found aarch64 support),
    `agents.capsule = false` (M2: no nested virt), everything else default off.
  - `home.nix`: `linux-headless`.
- `homeConfigurations."david@nixosvm"`.
- README: **Hosts** section (table of hosts, systems, profiles) and a
  **UTM guest install** runbook: Apple Virtualization backend, NixOS aarch64
  minimal ISO, partition + label, `nixos-install --flake …#nixosvm`, then clone
  `~/.cfg` per the Dotfiles section and `just home-switch`.

Exit: `just drvs` shows `nixosvm` system + home drvPaths (eval only);
Sleipnir/darwin identical. Real install is the user's, outside this plan.

### S9 — tidy (opportunistic, optional)

Candidates, each its own small commit; expected diffs allowed if explained:

- `user.nix` `extraGroups`: each module appends its own group (docker,
  libvirtd, caddy, gamemode, jackaudio …) instead of one central list.
- `alarm.nix` device name ← `hostname`.
- per-host overlays → the modules that need them (from S2 Notes).
- `sleipnir-doctor` naming, if it should become host-generic.

## Status

| # | slice | status | commit | model | notes |
|---|---|---|---|---|---|
| S0 | gate tooling | ✅ | `63017d80` | Sonnet-ok | ~1 min; pins registry + darwin rev |
| S1 | parameterise `system` | ✅ | `a7771764` | Opus | gate identical; agents has aarch64-linux |
| S2 | host factories | ✅ | `2ad1a83e` | Opus | nixos/home identical; darwin ordering-only |
| S3 | collect capsule + flag | ⬜ | | Sonnet-ok | |
| S4 | NixOS profiles | ⬜ | | Opus | classification judgement; mixed modules |
| S5 | home profiles + personal | ⬜ | | Opus | darwin + linux both affected |
| S6 | `agents.enable` | ⬜ | | Sonnet-ok | |
| S7 | invert defaults | ⬜ | | Sonnet-ok | mechanical; gate catches misses |
| S8 | `nixosvm` host | ⬜ | | Opus | first aarch64 eval |
| S9 | tidy | ⬜ | | Sonnet-ok | optional |

**Any red gate → escalate to Opus** regardless of the slice's model rec.

## Notes / findings

(append per slice: decisions, accepted ordering diffs, deferred opportunities)

### S0

- Baseline 2026-10-09: Sleipnir `ryda2g8d…`, home `3b3z5wbw…`, darwin
  `y59pa79x…` (pinned values; not comparable to unpinned drvPaths).
- The darwin pin also shows that the repo's state changes the real darwin system
  on every commit (`darwin-version.json`). That's intended (it's how
  `darwin-version` reports the rev), just not something the gate should see.

### S1

- `inputs.agents.lib` and `llm-agents.packages` both have `aarch64-linux`,
  so S6/S8 aren't blocked.
- `overlays/agents.nix` is now `{inputs}: system: overlay`, bound once as
  `agentsOverlay` in flake.nix's `flake = let …`. **`overlays.agents` is gone
  from the flake outputs**: a function of system isn't a valid overlay output,
  and nothing outside this flake consumed it (grepped ~/flakes, ~/dev).
- `legacyPackages` / `packages` are generated per `linuxSystems`, which is also
  the source of `systems`. Darwin isn't included (no registry use there).
- Opportunity: `modules/nixos/nix.nix` installs nix-search-tv twice — the
  flake input's package and `pkgs.nix-search-tv`. Pick one (S9).
- Opportunity (outside this plan): the committed `flake.lock` vs `nix fmt`
  re-lock above. A deliberate `nix flake update emacs` would settle it.

### S2

- `hosts.nix` (flake-parts module): `readDir ./hosts` → `meta.nix`
  (`kind`, `system`, `home`) → `mkNixos` / `mkHome` / `mkDarwin`. All three
  receive the same specialArgs core (`inputs username hostname features`,
  + `stable` on linux, + `pkgs` on darwin). Home gained `hostname` (unused so
  far, so no drv change).
- Every host's entry point is `hosts/<host>/config.nix`. Darwin's is new and
  just imports `../../darwin` (the shared darwin base).
- Sleipnir's package-fix overlays (llama-prism, whisper-rocm,
  click-threading-fix) moved from flake.nix into `hosts/Sleipnir/config.nix`,
  via `inputs.self.overlays`. mkNixos appends the agents overlay after them,
  the same order as before, so the drv is identical. `meta.nix` stays pure data.
- **Accepted ordering-only diff (darwin):** system-path's `chosenOutputs`
  holds the same 16 paths, but nix-darwin's own tools (`darwin-rebuild`,
  `-option`, `-version`, `-uninstaller`) now come after the user packages,
  because `darwin/` is imported one level deeper. It only matters for file
  collisions in buildEnv, and these packages don't overlap. New darwin
  baseline: `vv9yqd3i…`.
- `homeConfigurations.david` = alias of `david@Sleipnir` (identical drv).
  The justfile uses `david@{{host}}`, with ``host := `hostname` ``. `run.sh` uses
  `$(hostname)`. `regenerate-hardware` writes to `hosts/{{host}}/`.
  `darwin-*` recipes keep their explicit host default (macOS `hostname` may
  return `….local`).
- Not done: `nixpkgs.hostPlatform` vs `meta.system` can disagree (nixos
  hosts take hostPlatform from hardware config). S8's hand-written
  `hardware.nix` should set it from the same value, or mkNixos should assert.
- Darwin host bits not split from `darwin/`. Nothing there is obviously
  per-machine yet. Revisit when the work Mac arrives.

### Considered: srid/nixos-unified (2026-10-09) — not adopted

A flake-parts module: `mkLinuxSystem` / `mkMacosSystem` /
`mkHomeConfiguration` wrappers, directory autowiring
(`configurations/{nixos,darwin,home}/<host>`, `modules/*` → exported
`*Modules`), and an `activate` app. Not adopted as the framework, because:

- its `mk*` functions fix specialArgs to `{ flake = { self, inputs, config }; }`.
  Our `features` must be a specialArg to gate `imports`; working around that
  means calling `nixosSystem` directly, which leaves the wrappers with nothing to do.
- autowired NixOS hosts always embed home-manager as a NixOS module; we keep
  standalone HM on linux (separate `nixpkgs-home`, fast `home-switch`).
- autowiring re-exports every module as `nixosModules.*` etc., the
  indirection REFACTOR.md removed.
- modules would read `flake.inputs` instead of `inputs`, which touches every
  module that uses inputs.

Taken from it: the host table derived from `hosts/*/` (S2, `meta.nix`).

**Revisit `activate`** when deploying from Sleipnir to a VM matters. Its remote
mode `nix copy`s the flake source + overridden inputs to `ssh-ng://<target>`
and runs the build/activation **on the target**, which sidesteps x86 → aarch64
cross-building and replays `--override-input` checkouts via a per-host
`nixos-unified.overrideInputs` option. It reads `config.nixos-unified.*` from
each host, so it needs that options module imported. Check whether it can be
used without the rest before relying on it. Until then, run `just` inside the
guest.
