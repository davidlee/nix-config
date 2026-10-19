# NixOS, nix-darwin & home-manager system config

Declarative config for my development and thought crime workstation, Sleipnir,
plus laptop.

NixOS / MacOS (Nix-Darwin), home-manager, zsh, emacs / neovim, wayland + sway.

It's modular Nix, and there's a decent amount of it, but I actively prefer
plain old dotfiles for application config.

Nix is amazing, but it's tag line should be:

> An awful implementation of the only thing that makes sense.

So I keep `$HOME` itself in git for what makes sense, and use Nix to draw the rest of the owl.

## Dotfiles

`$HOME` is the worktree of this repo. The repository lives in `~/.cfg`; `~/.git`
is a one-line pointer to it, so plain `git` works anywhere under `~` (no alias).

```
~/.git  "gitdir: ~/.cfg"  ──►  ~/.cfg/   core.worktree = $HOME
                                         status.showUntrackedFiles = no
```

New machine (bash):

```bash
cd ~
git clone --no-checkout --separate-git-dir="$HOME/.cfg" \
  git@github.com:davidlee/nix-config.git ~/.cfg-tmp
mv ~/.cfg-tmp/.git ~/.git && rmdir ~/.cfg-tmp
git config core.worktree "$HOME"
git config status.showUntrackedFiles no
git reset            # index ← HEAD; files on disk are not touched
git status           # review: tracked files that differ from ~ or are missing
git restore -- .     # write them out (overwrites conflicting files)
```

Never `git stash` under `~`: it acts on the whole home directory, and with
`-u` it would sweep away every untracked file in it. The same goes for `git clean`.

## Principles

- keep a fairly lean core system
- separate userspace & system build using home-manager
- don't rewrite dotfiles in nix. Load raw custom config from generated nix stubs.
- share the things worth sharing (especially cli tooling) across Darwin / macOS
- minimal but secure secret management (1password-cli)
- use nix-direnv for project-local dev environments.
- use templates to make this easy
- prefer unstable; pin to stable as an escape hatch for broken packages
- use modules for maintainability and easy coarse-grained configuration changes
  see [SPEC-002](.doctrine/spec/tech/002/spec-002.md), host composition

## Notes 

### Bootstrap macOS

Lix and Homebrew must already be installed. The `Draupnir` target uses the
existing `david` account and leaves the installer-managed Lix in place
(`nix.enable = false`). Like Sleipnir, it has a nix-darwin system and a
standalone home-manager home (`homeConfigurations."david@Draupnir"`), each
switched on its own.

From `~/flakes`, with `just` installed:

```sh
just darwin-switch     # system: build as the login user, then darwin-rebuild as root
just home-switch       # home
```

The recipes pick the host by `hostname -s`; pass `host=Draupnir` while the
machine still has another name. `home-switch` runs through `nom`
(§ Workarounds) once a home has it; the first switch prints plain output.
The recipes build
`emacs/` and `agents/` from the checkout; the Mac has no `~/dev`, so every
other input comes from the lock (§ Dev checkouts).

On the Mac the flake is referenced as `path:<justfile dir>`, because the
dotfiles repository at `~/.git` is bare; automatic Git discovery otherwise
fails with “this operation must be run in a work tree”. `sudo -H` gives root
its own home directory and avoids the `$HOME` ownership warning. Only
activation needs root.

#### Cut-over from embedded home-manager

Earlier generations ran home-manager inside the darwin system. The first
switch to a standalone home builds everything first, then activates only those
prebuilt store paths:

```sh
# 1. build both, switch nothing; note the current system generation
just host=Draupnir darwin-build                    # -> ./result-darwin
nix build "path:$PWD#homeConfigurations.\"david@Draupnir\".activationPackage" \
  --override-input emacs "path:$PWD/emacs" --override-input agents "path:$PWD/agents" \
  --no-write-lock-file --out-link result-home
sudo darwin-rebuild --list-generations | grep current

# 2. activate the prebuilt system (what darwin-rebuild switch does after building).
#    Embedded home-manager leaves: home packages leave PATH, dotfile links stay.
sudo nix-env -p /nix/var/nix/profiles/system --set "$(readlink result-darwin)"
sudo ./result-darwin/activate

# 3. first standalone home generation; orphaned links are cleaned and
#    colliding files moved aside to *.backup (home.backupFileExtension)
./result-home/activate

# 4. in a new login shell: which emacs nvim zoxide (nu login too; atuin is off on darwin, ISS-007)
# 5. from now on: just home-switch
```

Steps 2 and 3 build nothing, but step 2 is not offline: homebrew updates and
upgrades on activation (`modules/darwin/brew.nix`), so run the cut-over online.

Between steps 2 and 3 nothing provides `nu`, and the old home's path,
`/etc/profiles/per-user/david/bin/nu`, is gone for good. Anything that names it
breaks: a terminal started before the cut-over keeps it in `$SHELL` until it is
quit and relaunched, and the zsh login hook (`~/.config/zsh/login.zsh`, outside
the repo) must hand over by PATH lookup, which survives both layouts and a
rollback: `command -v nu >/dev/null && exec -l nu`.

**Recovery runs forward.** The standalone home does not depend on the system
activation finishing.

- Step 2 fails (for example in the homebrew stage): run step 3 anyway; it
  restores home packages and links. Fix the cause and re-run step 2 with the
  same `result-darwin`.
- Step 3 fails (for example a collision with an existing `*.backup`): fix it
  and re-run `./result-home/activate`. Nothing is built or fetched.
- Last resort: `sudo darwin-rebuild --switch-generation <noted>`, not
  `--rollback`, which picks the generation below the current one, not
  necessarily the noted one. It restores embedded home-manager and its
  packages, and sets the hostname back to `Davids-MacBook-Pro`, so name the
  host explicitly (`just host=Draupnir …`) until the next switch.

### Dev checkouts

Every flake input is declared by its remote URL, and `flake.lock` holds no
local path (`just test` refuses one). Read-only recipes build from local
sources instead, so an edit lands without a push and a re-lock:

```
tree_override   agents/, emacs/                       in this repo, always present
dev_override    fleet goad malebolge panopticon       ~/dev/<input>, where checked out
                satan-attrd
                fleet: $FLAKES_FLEET (default /srv/fleet)
```

`bin/dev-checkouts` holds the list, and is the only place it is written.
A checkout is present when `$FLAKES_DEV/<input>/.git` exists (default
`~/dev`), so a machine without one, such as the Mac, uses the lock and needs
nothing. `fleet`, this host's private capsule declarations (a consumer of
oubliette's `mkFleet`), is the one exception: it lives at `$FLAKES_FLEET`.
Overrides are `git+file`: only tracked files reach the store, as GitHub
would give them.

Lock-writing recipes never override. To move the lock to your local work,
push, then `just update-local`, which warns about any checkout ahead of its
upstream and re-locks every input under development from its remote.

### Features

Optional modules are features: plain data under `features/`, selected per
host and projected into each evaluation's module list. How it works, what an
author may rely on, and every refusal: [SPEC-002](.doctrine/spec/tech/002/spec-002.md)
(`doctrine show SPEC-002` adds its requirements). This section is operations.

```
hosts/<host>/features.nix ──imports──> features/profiles/*.nix
          │                                     │
          └──────────────┬──────────────────────┘
                         ▼
                  features.nix <── features/ (tree)
                         │  (one lib.evalModules per host, checks enforced)
                         ▼
          modules.{nixos,homeManager,darwin}
          ─> appended by mkNixos / mkHome / mkDarwin
```

#### Feature tree

A feature is a self-named record holding an ordinary module for each
evaluation it touches, halves together:

```nix
# features/session.nix
_: [
  {
    name = "snooze";
    homeManager = _: { … };      # user half: the nag
    nixos = _: { … };            # system half: the wake alarm
    # darwin = …;  requires = [ "<area>.<name>" ];   platforms = [ "<system>" … ];   (all optional)
  }
]
```

An area is one file, `features/<area>.nix`, listing its features;
`features/default.nix` lists the areas. List order is projection order. A
feature that outgrows its area file moves to `features/<area>/<name>.nix`,
whole, and is listed as `(import ./<area>/<name>.nix)`.

```
features/
  default.nix         [ hardware session virt non-nix-packages games ai agents audio services desktop compositor
                        shell editor notes dev docs data files net web system text office security media
                        graphics comms fun terminal attention satan ]
  hardware.nix        [ openrgb bluetooth qmk tablet logitech ]
  session.nix         [ snooze ]
  session/            snooze-nag  snooze-nag-test     assets, beside their feature
  virt.nix            [ (import ./virt/capsule.nix) sandbox qemu docker podman ]
  virt/capsule.nix    a feature big enough for its own file
  non-nix-packages.nix [ appimage flatpak ]           app formats managed outside Nix
  games.nix           [ steam gamescope mangohud ]    gamescope requires steam
  ai.nix              [ llama-cpp rocm claude-desktop ]  llama-cpp, rocm: coverage targets
  agents.nix          [ registry (import ./agents/gateway.nix) eca chatgpt ]  registry: nixos only; gateway: nixos only, requires nothing; eca: linux only, requires gateway (personal-linux)
  agents/             gateway.nix  gateway/           the gateway record; its Python, tests and constants
  audio.nix           [ pipewire mpd speech dictate alarm ] alarm requires media.spotify
  audio/              dictate  dictate-test  say  say-test  alarm/   assets, beside their feature
  services.nix        [ avahi printing postgresql webserver ssh sunshine ]  printing requires avahi; sunshine: coverage target
  desktop.nix         [ (import ./desktop/core.nix {inherit lib;}) greeter (import ./desktop/fonts.nix) ]
  desktop/            core.nix  fonts.nix             features big enough for their own file
  desktop/core/       wayland.nix  xdg.nix  gui.nix …  home.nix   modules the core record imports; home.nix its home half
  compositor.nix      [ (import ./compositor/sway.nix) niri cosmic kde mango umbriel ]   each requires desktop.core
  compositor/         sway.nix
  shell.nix           [ noctalia walker ]
  editor.nix          [ (import ./editor/emacs.nix) neovim kakoune misc zed lem ]
  editor/             emacs.nix  neovim/              the emacs record; modules the neovim record imports
  notes.nix           [ terminal joplin ]
  dev.nix             [ scm build runtimes runners tools ]
  docs.nix            [ diagrams typeset markdown help ]
  data.nix            [ structured hex ]
  files.nix           [ manage disk archive search sync locate ]
  net.nix             [ tools tailscale ]             tailscale: linux only
  web.nix             [ browsers terminal ]
  system.nix          [ monitor process ]
  text.nix            [ tools pagers dictionary ]
  office.nix          [ calc calendar ]
  security.nix        [ credentials research ]
  media.nix           [ view convert players spotify obs ]  obs requires desktop.core
  graphics.nix        [ paint modelling color cad ]
  comms.nix           [ chat mail feeds ]
  fun.nix             [ toys ]
  terminal.nix        [ emulators utils zsh ]
  terminal/           zsh.nix                         the zsh record's home module
  attention.nix       [ (import ./attention/behaviour.nix {inherit lib;}) nudge goad ]
  attention/          behaviour.nix  nudge/           the behaviour record; nudge's scripts, run from the checkout
  satan.nix           [ harness attrd runner ] each its own file under satan/
  available.nix       the cli availability filter: availableOn minus platform-skips.nix (DEC-036)
  platform-skips.nix  per-system names the cli features skip though availableOn accepts them (plain data)
  profiles/           workstation.nix  personal.nix  personal-linux.nix  personal-darwin.nix
  stub/               flake.nix                       empty flake: just isolation's stand-in for local inputs
```

Each feature gets `feature.<area>.<name>.enable`, default `false`. A profile
sets those with `mkDefault`; a host imports profiles and overrides any of
them with a plain definition:

```nix
# hosts/Sleipnir/features.nix
{
  imports = [../../features/profiles/workstation.nix];   # snooze, docker, fonts, …
  # feature.session.snooze.enable = false;               # would turn it off
  feature.virt.capsule.enable = true;                    # a host property, no profile
}
```

Nothing is selected automatically, prerequisites included: a host that
selects `services.printing` also selects `services.avahi`. A Linux-only
record says so with `platforms = lib.platforms.linux`, or the Mac's home
would get it. A cli package that fails on a platform although `availableOn`
accepts it goes in `features/platform-skips.nix`; a transient skip also
gets a probe (§ Workarounds).

**Coverage.** A feature no host selects is still evaluated, each half by a target in
`flake.coverage`: `"Sleipnir+openrgb"`, `"Sleipnir+podman"`,
`"Sleipnir+llama-cpp"`, `"Sleipnir+rocm"`, `"Sleipnir+sunshine"`.
`"Sleipnir+speech"` predates Sleipnir selecting `audio.speech` and is now
redundant. `base@aarch64-linux` and `home@aarch64-linux` evaluate the NixOS
base and the home base alone, headless and off x86. A new off feature gets a
target beside them in `hosts.nix`.

```bash
just coverage    # one drvPath per target, then just isolation
just isolation   # lean homes evaluate with every dev checkout stubbed
just test        # resolver and meta tests (checks.<system>.{features,host-meta}), then the script tests
```

`nix flake check` warns about the unknown `coverage` output; that is
expected.

**docker and podman.** Docker is rootless only: `modules/nixos/security.nix`
refuses the rootful daemon on every host. Both ship `bin/docker` (podman
through `dockerCompat`), and the system profile silently keeps whichever is
listed first, so the `docker` feature refuses podman. podman is a feature no
host selects; `Sleipnir+podman` swaps it in for docker (IMP-018).

**Parked is not a feature.** Parked modules live in `parked/` at the flake
root (DEC-043). Nothing imports them, so nothing evaluates them.

- `hyprland.nix` and `kmscon.nix` do not evaluate: `hyprlandPlugins.hyprexpo`
  is gone and `services.kmscon.fonts` was removed upstream.
  `hosts/Sleipnir/config.nix` keeps their `../../parked/…` import lines
  commented out. Repair first, then promote to a feature.
- `shpool.nix` evaluates but is unused: emacs session restore uses zmx
  (`editor.emacs`, IMP-001).

### Hosts

`hosts.nix` builds every configuration from the `hosts/` directory. Where
each kind of config belongs (base, feature, machine, host) is SPEC-002
§ Where config lives.

```
hosts/<host>/
  meta.nix                    kind, system, home (validated before anything resolves)
  features.nix                profiles and overrides (optional)
  config.nix                  system entry point: imports the base, then host config
  home.nix                    home entry point: one home layer, identity, stateVersion
  machine.nix                 bound to the machine's parts, beside hardware-configuration.nix
  <name>.nix                  host config too big for config.nix (Sleipnir: dns, oom, doctor)
```

```nix
# hosts/Sleipnir/meta.nix
{ kind = "nixos"; system = "x86_64-linux"; home = true; }
```

| kind | output | home-manager |
|------|--------|--------------|
| `nixos` | `nixosConfigurations.<host>` | standalone, `homeConfigurations."david@<host>"` from `home.nix`, when `home = true` |
| `darwin` | `darwinConfigurations.<host>` | standalone, as for `nixos`, when `home = true` |

The NixOS **base** (`modules/nixos/default.nix`) holds nix, user, boot,
kernel, env, maintenance, security, network (NetworkManager, a firewall with
no open ports, nftables, `hostName`, `timeServers`), programs (nix-ld,
rust-motd, root's helix) and the inspection set of cli tools. Root's login
shell is NixOS's default, bash, and so are the system users that take the
default (`assigner`, `postgres`); the user's own shell stays nushell. The
base installs every terminal's terminfo, so root's bash works from any
emulator. ssh, locate, tailscale, avahi, sandboxing and the system zsh are
features: a NixOS host that does not select `services.ssh` runs no sshd.

The **home base** (`modules/home/default.nix`) holds nushell, direnv and the
base cli. Each `home.nix` imports exactly one platform layer over it:

```
hosts/Sleipnir/home.nix ──> modules/home/linux/default.nix ──┐
                                                             ├──> modules/home/default.nix
hosts/Draupnir/home.nix ──> modules/home/darwin/default.nix ─┘
```

The darwin system base is `modules/darwin/default.nix`, imported by a darwin
host's `config.nix`.

Adding a host means adding a directory. The justfile selects the
configuration by `hostname -s`; override with `just host=<other> system-build`
(or `home-build`). `run.sh <cmd> <host>` takes it as its second argument.
`homeConfigurations.david` is a transitional alias for `david@Sleipnir`.
The roadmap this is part of is RFC-001 (`doctrine show RFC-001`).

### Workarounds

A transient upstream breakage (a package uncached, or failing to build, on
the current pin) gets two things: a local fix beside the module that
consumes the package (DEC-016), and a probe that says when the fix can go
(DEC-053). The probe applies nothing; it names the fix so it can be found
and reverted.

```
workarounds/default.nix    probes, plain data; applies nothing
   │  validated by workarounds/probes.nix
   ▼
flake.workaroundProbes     each probe + storePath (unpatched: from the pin, no overlays)
   │
   ▼
workarounds/check [pin]    GET cache.nixos.org/<hash>.narinfo, per probe
   200    candidate: remove <sites> (<issue>: <reason>)       exit 1
   404    ok <attr> (<system>)
   other  unknown <attr>: <HTTP nnn | curl's error>
   -      manual <attr> (<issue>): check by hand              signal = "manual": never asked
```

**Probe.** One record per fix, in `workarounds/default.nix`:

```nix
{
  attr = ["atuin"];            # path in the pin's package set
  pin = "nixpkgs-home";        # "nixpkgs" | "nixpkgs-home"
  system = "aarch64-darwin";   # one of the flake's systems
  issue = "ISS-007";           # the backlog item tracking it: ISS|IMP|CHR|RSK|IDE-NNN
  reason = "18.23.0 not cached for aarch64-darwin; local build fails";
  sites = [                    # every file to revert, repo-relative
    "modules/home/cli.nix"
    "modules/home/darwin/default.nix"
    "features/platform-skips.nix"
  ];
  # signal = "manual";         # never asked: a runtime bug, or an unfree package
}
```

ISS-007 tracks atuin, disabled on the Mac. `signal = "manual"` marks what
the cache cannot answer: a runtime bug (a cached build says nothing about
it) and an unfree package, which is never on cache.nixos.org (`yed` is one). An
unfree probe without it is an evaluation error, as is an unknown or missing
key, a wrong type, or an `attr` the pin lacks; the error names the probe
(`workarounds/default.nix, probe 2 (killall)`). The `stable` input cannot
be probed.

**The check.** `workarounds/check` reads each probe's store path, built
from the pin alone with no overlays (what Hydra, nixpkgs' build farm, builds), and asks
cache.nixos.org for it (DEC-055). Cached means the build failure is gone
upstream, not that a runtime bug is fixed; the first build without the fix
still proves the removal. Exit 0: no candidate; 1: a candidate; 2: usage, or
the probes failed to evaluate. Offline, every probe is `unknown`. It runs:

- at the end of `just update-system` (pin `nixpkgs`) and `just update-home`
  (pin `nixpkgs-home`), non-fatally, so `update` and `everything` go on;
- on demand, `just workarounds-check [pin]`, which fails on a candidate;
- never in `just test` or the gate: it needs the network.

**Fixes.** Both forms are local. Every fix gets a probe; removing one means
reverting every site and deleting the probe.

- *A skip, override or patch*, in the module that consumes the package:
  `lib.mkForce false`, `lib.optional isLinux`, a `features/platform-skips.nix`
  entry (atuin uses all three; its probe lists the three sites), or an
  overlay set in a NixOS or home module's `nixpkgs.overlays`. A library
  other packages depend on is patched this way. The click-threading fix,
  removed once its unpatched build was cached (commit 28861d6c):

  ```nix
  _final: prev: {
    python314 = prev.python314.override {
      packageOverrides = _: pyPrev: {
        click-threading = pyPrev.click-threading.overridePythonAttrs (_: {doCheck = false;});
      };
    };
  }
  ```

- *lastGood*, for a leaf app only: the package from an earlier nixpkgs
  revision, built for pkgs' system with pkgs' config. It brings its own
  closure, beside the current one (DEC-054). Import
  `workarounds/last-good.nix` by path and paste the revision that
  `workarounds/last-good <input>` prints:

  ```nix
  final: prev: {foo = lastGood {rev = "…"; narHash = "…";} prev ["foo"];}
  home.packages = [(lastGood {…} pkgs ["foo"])];
  ```

`workarounds/last-good` prints `{ rev = "…"; narHash = "…"; }` for a root
input, from a committed lock in `~/.cfg` (`FLAKES_GIT_DIR`):

| working `flake.lock` vs HEAD's | reads |
|---|---|
| differs (any byte) | HEAD's lock: the update is not committed yet |
| same | the lock before the latest lock change |

That is the previous lock, not the previous nixpkgs: if only other inputs
moved, it prints the current revision. It refuses (exit 2) an unknown
input, one that follows another, and one not locked to github NixOS/nixpkgs.
`last-good stable` gives the stable input's revision. There is no just
recipe.

**will-build.** `just will-build [system|home|all]` (default `all`)
dry-runs the switch and sorts what it would build (DEC-057):

```
== home (Draupnir)
will build locally (1):
  foo-1.2.3
config (12): home-manager-generation home-manager-files hm_… …
will fetch: 40 paths
```

Config is generated files that build in seconds: a known name, or a
derivation that sets `preferLocalBuild`. The two counts must add up to
nix's own, or it fails: nothing is dropped. It runs last in `update-system`
and `update-home`, non-fatally. A dry run counts the local store, so a
derivation already built here but not cached is not listed; the probe
answers that.

**nom.** `just home-switch` and `just home-build` stream through
`nom --json` (nix-output-monitor, in the home base) with `pipefail`, so a
failed build still exits non-zero. Where `nom` is not on PATH yet (a home
that predates it), they print home-manager's plain output instead.

```bash
just workarounds-check                # every probe
just workarounds-check nixpkgs-home   # one pin
workarounds/last-good nixpkgs-home    # {rev; narHash} for lastGood
just will-build home
just test                             # offline: check, last-good and will-build tests, checks.<system>.workarounds
```

### Dictation

`features/audio.nix` (`audio.dictate`) + `features/audio/dictate` — streaming
speech-to-text, typed at the cursor as you speak. Local and CPU-only.

```
F9        ──> dictate toggle ──SIGUSR1────┐
`=` held  ──> dictate start  ──SIGRTMIN───┼──> dictate.service (model resident, mic closed)
`=` up    ──> dictate stop   ──SIGRTMIN+1─┘      pw-record ──100ms──> Nemotron ──> wtype
```

The model is NVIDIA's [Nemotron 3.5 ASR streaming 0.6B](https://huggingface.co/nvidia/nemotron-3.5-asr-streaming-0.6b)
(cache-aware FastConformer encoder with an RNN-T decoder, punctuation and
capitals included), as sherpa-onnx's int8 export with 560 ms chunks. One
thread decodes at about 1/7 real time, so live dictation costs about a seventh
of one core. Idle, the daemon holds about 1.5 GB of RAM and no CPU.

Typing as you speak depends on the transcript only growing: cache-aware
streaming emits each token once, so each new piece is typed and earlier text
is never revised. If a revision ever happens, `edit` backspaces it.

Each command sets whether the daemon should be listening; `DICTATE_IDLE` (10 s)
without new words also stops it. A toast says when the mic opens and closes.

**Push-to-talk.** umbriel binds fire on press only, so the keyboard splits the
key: holding the `=` combo (left middle + index, home row) makes ZMK's `ptt`
macro tap F13, and releasing it taps F14. Tapping the combo still types `=`.
The binds in `~/.config/umbriel/binds.toml` use xkb's names for those keys,
`XF86Tools` and `XF86Launch5`. The ZMK side is in `~/dev/kb/zmk-config`
(`config/combos.dtsi`). F9 toggles, for any keyboard.

```bash
just test                       # behaviour tests, no mic or model
DICTATE_MODEL=<unpacked model> features/audio/dictate-test   # + real model
journalctl --user -u dictate -f
```

Language is `DICTATE_LANG` in the module (`en`, `fr`, …, or `auto`); a wrong
hint garbles the output rather than degrading gracefully.
Measurements and open options: [DICTATE.md](./DICTATE.md).

### Speech

`features/audio.nix` (`audio.speech`) + `features/audio/say` — text to speech,
played on any PipeWire sink. Local; voices are pinned in the module, so
neither engine downloads anything at runtime.

```
say [-e piper|kokoro] [-d SINK] [TEXT...]     (TEXT, else stdin)

piper  ──raw PCM, per sentence──> pw-play --raw --rate <voice config>   streams
kokoro ──whole wav──────────────> pw-play                               ~5 s model load first
```

piper (default) is fast and starts speaking after the first sentence; kokoro
sounds better but loads its model on every call. `SINK` is a node.name from
`pw-cli ls Node`. Defaults: `SAY_ENGINE`, `SAY_DEVICE`, `PIPER_VOICE`,
`KOKORO_VOICE`, `KOKORO_SPEED`.

The module wraps both engines: `piper` gets `--data-dir` of the pinned voices
(also linked at `/etc/piper-voices`, where `say` reads sample rates), and `kokoro` gets
spaCy's `en_core_web_sm` plus an offline Hugging Face cache of Kokoro-82M. To
add a piper voice, add its two file hashes to the module's list.

```bash
just test                       # say-test: behaviour tests, no engine or speakers
say hello
```

### Sleipnir Doctor

`hosts/Sleipnir/doctor.nix` (host config; scripts in `hosts/Sleipnir/doctor/`) — at-a-glance system health check. Run `sleipnir-doctor`.

Built-in checks cover disk, memory, swap, thermals, OOM kills, kernel mismatch, time sync, load, zombies, systemd failed units, daemon liveness, nix store/generations/GC roots/journal, network, and git status.

**External checks:** drop an executable in `~/.config/sleipnir-doctor/checks.d/`. Doctor runs each one (10s timeout), parses stdout as JSON, and renders the results alongside built-in checks.

**Protocol:** stdout must be a JSON array of check objects:

```json
[
  {"category": "Emacs", "name": "server", "status": "OK",   "detail": "pid 1234, uptime 3:42"},
  {"category": "Emacs", "name": "LSP",    "status": "WARN", "detail": "1/3 servers dead"}
]
```

| Field      | Required | Values                        |
|------------|----------|-------------------------------|
| `category` | no       | group heading (defaults to script name) |
| `name`     | yes      | check label                   |
| `status`   | yes      | `OK`, `WARN`, or `CRIT`       |
| `detail`   | no       | free text                     |

Exit code is ignored (non-zero logs stdout/stderr as a single WARN). A single object instead of an array is accepted.

**Shipped provider:** `sleipnir-doctor-emacs` calls `emacsclient -e '(sleipnir-doctor-checks)'` for server uptime and eglot/LSP health. Elisp side lives in `~/.config/emacs/lisp/dl-sleipnir-doctor.el`.

### OOM resilience

`hosts/Sleipnir/oom.nix` — tunes `systemd-oomd` and reserves resources so the desktop stays usable under memory pressure. Host config: it names this host's UID and compositors (IMP-022 parametrises it per host). The 16G swap file is in `hosts/Sleipnir/machine.nix`.

**systemd-oomd:** enabled for root, system, and user slices. Kills when swap hits 90%. Default memory pressure duration 20s.

**Session protection:** two layers of `CPUWeight=200` + `MemoryLow`:

```
user-1000.slice           1536M  ← vs system services
└─ user@1000.service
   ├─ session.slice       1G     ← vs your own apps
   │   ├─ umbriel.service
   │   ├─ pipewire, wireplumber, dbus, portals
   │   └─ emergency-htop (rescue term)
   └─ app.slice           —      browsers, electron, terminals, noctalia
```

A child's `MemoryLow` is capped by its parent's, so `user-1000` must cover `session.slice`.

**earlyoom:** `--avoid` biases away from (does not exempt) the compositor, shell and session daemons. Patterns match `/proc/PID/comm`, truncated to 15 chars, so nix-wrapped binaries appear as `.umbriel-wrappe` / `.noctalia-wrapp`. Children have their own comm — a runaway `rustc` in kitty is not shielded.

**Emergency kill:** `Super+Ctrl+Delete` opens a floating sticky `htop` (kitty, class `emergency-htop`). The bind (`~/.config/umbriel/binds.toml`) launches it via `systemd-run --user --scope --slice=session.slice` so it lands in the protected slice rather than `app.slice`.

**swayosd:** rate limits relaxed (`StartLimitBurst=10`, `StartLimitIntervalSec=60`, `RestartSec=5s`) so transient crashes don't permanently kill the service.

### Snooze (bedtime ratchet)

`features/session.nix` — the `snooze` feature: its home half (the nag) and
its system half (the wake alarm); `features/session/snooze-nag` with its
test. Selected by the `workstation` profile. Nags the machine to bed each
night, and wakes it via RTC alarm.

A fixed-time suspend has one failure mode: you turn it off, and then you stay
up. So nothing suspends on a clock any more. At 23:20 `snooze-nag.timer` starts
`~/.local/bin/snooze-nag`, which asks, and keeps asking on a shortening leash.

```
23:20  ┌─ morning yet? (05:00–21:59) ──> stop; the timer starts it again tonight
       │
       ├─ toast: "Go to bed"   [Bed now]  [Snooze 20m]
       │    │
       │    ├─ Bed now                    ──> suspend
       │    ├─ no answer for 5 min        ──> nobody's here ──> suspend
       │    └─ Snooze, or toast dismissed ──> costs a rung ──┐
       └──────────────────────────────────────────────────── ┘
            grants: 20, 15, 10, 5, 5, 5, … the last rung repeats
```

Three properties it is built around:

- **Dismissing is not an escape.** Swiping the toast away costs a rung like any
  other answer. Only *Bed now*, or your absence, ends it.
- **Absence suspends.** Silence for the whole five-minute window means you are
  not at the machine — which is what the old fixed-time suspend assumed. So
  does a prompt that cannot be drawn at all (no session, no notification
  daemon): unanswerable is unanswered, and it says so in the journal. A nag
  that loops silently without ever suspending would be the failure this
  replaces, wearing a different hat.
- **The ladder survives the suspend.** `systemctl suspend` returns as soon as
  the suspend begins, so the loop lives on and is pinned to its floor. Wake the
  machine at 3am and it asks again within five minutes. The old 00:00 and 00:30
  retries existed to patch exactly that hole, and are gone.

The nag is a `notify-send --wait --action=…` toast; noctalia renders the
buttons and prints the pressed action on stdout. `timeout` is the only thing
that can end a prompt without a human, and that is how absence is told apart
from a dismissal.

**System half** is now only `snooze-wake`: an RTC alarm (`WakeSystem=true`) for
07:00, which needs a system timer. Suspending does not — an active session may
`systemctl suspend` unprivileged — so it lives next to the person being asked.

Bedtime and the wake time are in the `let` blocks at the top of each half;
the ladder, the absence window and the night window are `SNOOZE_*` defaults at
the top of the script.

```bash
just test                                              # behaviour tests, no display needed
SNOOZE_GRANTS='2 1' SNOOZE_UNIT=1 SNOOZE_ABSENT=1 snooze-nag   # the whole ladder in seconds
journalctl --user -u snooze-nag -f
```

### Printing

`features/services.nix` (`services.printing`) — CUPS with drivers for Brother HL-L2445DW (laser) and Canon TR8600 (inkjet via gutenprint).

**Printers:** both discovered via Avahi/mDNS (the `services.avahi` feature, which `services.printing` requires; Sleipnir selects it explicitly in `hosts/Sleipnir/features.nix`, since `requires` never selects). The `laser` queue is the default printer. Assign static DHCP leases on the router so IPP URIs don't break.

**GUI:** `system-config-printer` for queue management, or `http://localhost:631` for the CUPS web interface.

**Common commands:**
```bash
lp file.pdf                   # print to default printer
lp -d laser file.pdf          # print to specific printer
cat file | lp                 # pipe to printer
lpstat -t                     # queue status
cancel laser-14               # cancel a job
cancel -a laser               # cancel all jobs on a queue
lpadmin -d laser              # set default printer
lpadmin -p laser -v ipp://IP:631/ipp/print  # change printer URI
```

### llama.cpp (Bonsai 2)

`features/ai.nix` (`ai.llama-cpp`) — `llama-server` on `127.0.0.1:8080` (OpenAI-compatible
API + web UI), serving [Ternary-Bonsai-2-27B](https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf)
on the RX 9070 XT via ROCm. **Currently off** on
Sleipnir (no use case a hosted model doesn't cover better); the config is kept
working. Set `feature.ai.llama-cpp.enable = true;` in `hosts/Sleipnir/features.nix` and `system-switch` to
bring it back; the first build compiles HIP kernels for a long while.

**What to expect** (measured 2026-10): decode 38–48 tok/s, prompt processing
450–1000 tok/s. Tool calls in pi worked; reasoning is noticeably weaker than
a hosted frontier model. The model thinks at `xhigh` by default — `/thinking
medium` in pi (or `reasoning_effort: "medium"`) is faster at little cost.

**Why a fork.** Bonsai stores weights as ternary values {−1, 0, +1} in new GGUF
types (`PQ2_0`, `PTQ1_0`) that stock llama.cpp rejects. `overlays/llama-prism.nix`
builds [PrismML's fork](https://github.com/PrismML-Eng/llama.cpp) on the nixpkgs
`llama-cpp` recipe, swapping only `src`, and compiles HIP kernels for `gfx1201` only.

```
flake input llama-cpp-prism-src (release tag) ──> overlays/llama-prism.nix ──> pkgs.llama-cpp-prism-rocm
                                                                                ├─ services.llama-cpp
                                                                                └─ systemPackages (llama-cli, llama-bench)
```

**Router mode.** The server starts without `--model` and loads models on demand
from a preset INI, generated from the `presets` attrset in the module.
Command-line flags override presets, so `settings` holds only router-level
flags (host, port, `models-max`); per-model options live in the preset.
`load-on-startup` loads Bonsai when the service starts.

VRAM at 128k context: model 6.5 GB + q8_0 KV 4.3 GB + compute 0.7 GB ≈ 11.8 GB,
leaving ~1 GB with the desktop running. Context checkpoints (150 MB each, up
to 32) live in host RAM. Bonsai's hybrid attention can only rewind its cache
to a checkpoint, hence `checkpoint-min-step = 1024` (default 8192) to limit
re-processing when an agent rewrites recent history. To see buffer sizes, add `verbosity = 4` to the preset.

**pi** (needs router mode): `/login llama.cpp` with `http://127.0.0.1:8080`, no
API key, then `/model`. Use `127.0.0.1`: node may resolve `localhost` to `::1`,
where nothing listens.

The `ai.rocm` feature is not needed — it sets `rocmSupport` globally and rebuilds much of nixpkgs.

**Model files** are fetched by hand, not by nix (7 GB in the store, per bump, is a poor trade):

```sh
nix shell nixpkgs#python3Packages.huggingface-hub -c \
  hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PQ2_0.gguf --local-dir /srv/models
```

`/srv/models` is created by tmpfiles. `PQ2_0` (7.2 GB) is the faster packing for
prompt processing; `PTQ1_0` (6 GB) is the denser one.

**Bump the fork:** change the tag on `llama-cpp-prism-src` in `flake.nix`, run
`nix flake update llama-cpp-prism-src`, then rebuild. If the web-UI deps
changed, the build fails with a hash mismatch: copy the `got:` hash into
`npmDepsHash`.

**Usage notes** (from the model's
[KNOWN_ISSUES](https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf/blob/main/KNOWN_ISSUES.md)):
it's a reasoning model, so give requests a large `max_tokens` (≥16k) or the
answer is cut off mid-thought. `reasoning_effort` accepts `none`, `low`, `medium` or `xhigh`
(`high` returns HTTP 500); `medium` is the practical setting. Send exactly one
system message, first.

### Spotify Alarm

See [ALARM.md](./ALARM.md). `features/audio.nix` (`audio.alarm`, selected by Sleipnir) — plays a playlist through speakers at scheduled times via `spotifyd` + `spotify_player` + systemd user timers.

### Emacs

emacs-unstable-pgtk (emacs-macport on darwin) plus a hand-maintained package
list, built via [nix-community/emacs-overlay](https://github.com/nix-community/emacs-overlay).

| file | role |
|------|------|
| `emacs/emacs.nix` | the package list (`emacsWithPackages`) |
| `emacs/flake.nix` | its own flake with its own nixpkgs/overlay pins, shared with the `~/.config/emacs` and satan devshells |
| `features/editor/emacs.nix` | the `editor.emacs` feature: installs it on PATH and as the `services.emacs` daemon |

**Two package sources:**

```
use-package foo
  ├─ foo in emacs/emacs.nix ──> nix store, on load-path at startup   (default)
  └─ :vc (:url …)           ──> package-vc clones into ~/.config/emacs/elpa at runtime
```

- **nix (default).** Add the name to `emacs/emacs.nix`, then `just home-switch`.
  The justfile overrides the `emacs` input with the local checkout, so no push
  or `nix flake update` is needed. `just melpa-list` writes every available
  name to `emacs-packages.txt`.
- **package-vc.** For packages not in nixpkgs, or that need a writable
  directory (ghostel builds a native module in place). Declared with `:vc` on
  the `use-package` form; Emacs records them in `custom-vars.el`'s
  `package-vc-selected-packages`.

Emacs never downloads from an archive: `early-init.el` sets
`package-archives nil` and `use-package-always-ensure nil`. A `use-package`
form for a package in neither source simply fails to load. `package-initialize`
still runs, to activate what is in `~/.config/emacs/elpa`. Prefer nix, and don't
keep a package in both places.

**The same `emacs` derivation** is used for both `home.packages` (PATH) and `services.emacs.package` (daemon). If these diverge, `emacsclient` connects to a daemon with different packages than `emacs --batch`.

**Gotchas:**

- **`:init` vs `:config`:** any `use-package` block that calls a mode function (e.g. `(vertico-mode)`) must use `:demand t` + `:config`, not `:init`. Without `:demand t`, `use-package` defers loading until a trigger fires, and the mode function won't exist yet.

- **Broken upstream autoloads.** Nix loads each package's generated autoloads at startup; one that errors logs `Error loading autoloads: …` and silently drops the rest of that file — often its `auto-mode-alist` entry. Declare the missing bits in `use-package` (`:mode`, `:commands`). Example: `typst-ts-mode` 0.12.2, see `lang/dl-typst.el`.

- **Variable names follow the nix version, not upstream HEAD.** A package's README may describe newer option names than the pinned version has. Check with `describe-variable` before copying settings.

### crates.io fetch workaround (temporary)

`modules/nixos/nix.nix` — sets `systemd.services.nix-daemon.environment.NIX_CURL_FLAGS = "-A nixpkgs-fetchurl"`.

**Why:** crates.io rate-limits (1 req/sec) and `403`s the `curl/*` User-Agent on its `/api/v1/crates/.../download` endpoint. nixpkgs `importCargoLock` (used by any `cargoLock.lockFile` build, e.g. `pub/zerostack.nix`) fetches every crate from there, so `home-switch`/`system-switch` fail with `curl: (22) ... 403` once a rust dep enters the closure. A non-`curl` UA gets the `302` to `static.crates.io`, which `curl` then follows. `fetchurl` honours `NIX_CURL_FLAGS` via `impureEnvVars`, and the env is read from the **daemon**, not your shell — hence the systemd service env (a daemon restart, i.e. `system-switch`, is required before it takes effect).

**Upstream fix:** [nixpkgs#524985](https://github.com/NixOS/nixpkgs/pull/524985) (commit `c0a89c3`, merged to master 2026-05-27) switches the `importCargoLock` registry to `static.crates.io` directly. `fetchurl` is content-addressed, so the workaround and the fix produce identical crate store paths — swapping is a no-op rebuild-wise.

**Removal:** the merge date is *not* the trigger — the nixpkgs input tracks the unstable channel, which lags master by days. Check whether your pin actually contains the fix:

```bash
rev=$(nix flake metadata --json | jq -r '.locks.nodes.nixpkgs.locked.rev')
gh api repos/NixOS/nixpkgs/compare/c0a89c3...$rev --jq '.status'
```

When it returns `ahead` (or `identical`), delete the `NIX_CURL_FLAGS` line and `system-switch`. Until then it is load-bearing.

### Prefer IPv4 (gai.conf)

`hosts/Sleipnir/config.nix` — `environment.etc."gai.conf"` sets `precedence ::ffff:0:0/96 100`, flipping getaddrinfo to prefer IPv4 over the RFC 6724 default (which prefers v6).

**Why:** the ISP's v6 egress goes intermittently dead — the router keeps advertising a v6 default route and delegating a global prefix (`2403:5802:…`), but outbound v6 `connect()` blackholes ~3s then fails. Because a global v6 address exists, RFC 6724 makes apps dial the dead v6 first on every dual-stack name, so everything stalls seconds per attempt. It surfaced as a nix FOD hanging forever in `bun install --frozen-lockfile` (fresh `HOME` cache → full download, each dep dialling dead v6 first).

**Why this fix and not others:** interface-agnostic (covers wired + wifi + future, one place — no per-NM-profile duplication) and **self-healing** — when the ISP's v6 recovers, apps just work again, still preferring v4. The alternative (`ipv6.ignore-auto-routes` per NM profile) hard-kills the v6 default route and has to be reverted by hand once v6 is back.

**Diagnosing:** `curl -sS -o /dev/null -w '%{remote_ip}\n' https://registry.npmjs.org/` should connect via a v4 addr. If v6 is truly dead, `curl -6 https://…` fails after a few seconds while `curl -4 …` returns instantly.

**Removal:** harmless to leave (v4 preference costs nothing when v6 works). Drop it only if you want strict RFC 6724 v6-preference back once the ISP is reliably dual-stack.

### LLM gateway

`features/agents.nix` (`agents.gateway`, selected by `personal-linux`, so
Sleipnir) with `features/agents/gateway.nix` and `features/agents/gateway/`.
A LiteLLM proxy holds the provider keys. A jail holds only its own gateway
key: useful on this host alone, within its budget and its model list. Clients
are the jailed `eca` (key `eca`) and the jails that take
`gatewayClient "pi"` (shared key `pi`): the Emacs devshell, `~/dev/doctrine`
and projects made from the agents template. The unjailed `eca` is unchanged.
It serves DeepSeek, OpenRouter and Fireworks models.

**What it is, and what clients may rely on:**
[SPEC-001](.doctrine/spec/tech/001/spec-001.md) (`doctrine show SPEC-001`
adds its requirements). Its § Client contract is the reference for anyone
writing a client: address, routes, allowed body fields, reasoning effort
(DEC-074), model names and refusal codes. This section is operations only.

```
jail ──127.0.0.1:4000──> llm-gateway-relay ──/run/llm-gateway/api.sock──> llm-gateway.service
                                                                            keys.db  /var/lib/llm-gateway
                                                                            credentials /etc/credstore.encrypted
```

**First run.** The service cannot start until a provider credential exists.
On the first switch systemd itself refuses the unit at credential setup
(`status=243/CREDENTIALS`; `journalctl -u llm-gateway` shows "Failed to set
up credentials: No such file or directory"), before the launcher runs.
The switch reports a failed `llm-gateway` unit; the new generation is active.
That is expected. `just gateway-credentials` (with no argument, every provider's
1Password item: deepseek, openrouter, fireworks; name the ones a host has
otherwise) clears the start limit those
failures hit, restarts the service, and returns once the gateway's socket
exists (it gives up after 90 s, naming `systemctl status llm-gateway`).

```bash
just system-switch          # llm-gateway.service fails: no credential yet (expected)
just gateway-credentials    # one 1Password unlock; encrypts with host+TPM2; restarts, waits until serving
llm-gateway issue eca --models deepseek-flash --budget 5 \
  --out ~/.config/llm-gateway/keys/eca   # 0600; refuses an existing file
llm-gateway issue pi --models deepseek-flash --budget 50 \
  --out ~/.config/llm-gateway/keys/pi    # the key every pi-client jail shares
just home-switch
```

A pi jail also gets a generated `models.json` that points pi at the gateway;
see `agents/README.md` § Gateway mode.

The launcher's own message (it names the credential and
`just gateway-credentials`) appears only when the credential directory lacks
a provider by some other route.

Then point eca's provider at the gateway in `~/.config/eca/config.json`
(`url`, `key`, and the model names the gateway serves; no key value goes in
the file):

```json
"deepseek": {
  "url": "http://127.0.0.1:4000/v1",
  "key": "${env:LLM_GATEWAY_KEY}",
  "models": { "deepseek-flash": {} }
}
```

**Providers.** Each is an entry in `defaults.providers` in
`features/agents/gateway/proxy.nix`: key variable, 1Password ref, `reportsCost`.

| provider | key variable | cost source |
|---|---|---|
| deepseek | `DEEPSEEK_API_KEY` | packaged price map |
| openrouter | `OPENROUTER_API_KEY` | `reportsCost`: OpenRouter's per-request `usage.cost` |
| fireworks | `FIREWORKS_API_KEY` | packaged price map |

Cost sources: SPEC-001 § Served models and cost.

**Admin.** `llm-gateway` runs as the `llm-gateway` user via sudo on the
SQLite file (DEC-050). Keys travel on stdin, never argv.

| command | does |
|---|---|
| `issue ALIAS --models M,… --budget USD [--out FILE]` | issue a key; printed once, or written to a new 0600 file |
| `list` | every key: alias, models, budget, spent, revoked |
| `revoke ALIAS` | revoke a key |
| `budget ALIAS USD` | set the lifetime budget |
| `models ALIAS M,…` | replace a key's model list; the key is unchanged, live at once, no restart; refuses a revoked key and unserved models |
| `reset ALIAS` | set spend back to 0 |
| `credentials [PROVIDER…]` | encrypt provider keys from 1Password for the service; a failed read leaves the stored one |

**Rotation.**

- Provider key: rotate it in 1Password, then `just gateway-credentials`
  (re-encrypts, restarts the service).
- Client key: a key is never re-keyed in place. Issue a new one under a new
  alias (DEC-051: a revoked alias is never reissued). A client's `keyFile` is
  the fixed path `…/keys/<client>` (`eca`, `pi`); the alias is only the ledger's name. A running jail
  keeps the key it launched with until that key is revoked.
- Model list: replaced in place with `llm-gateway models` (DEC-071), under the
  same alias. A revoked key cannot be edited.

```bash
mv ~/.config/llm-gateway/keys/eca{,.old}       # --out refuses an existing file
llm-gateway issue eca-2 --models … --budget … --out ~/.config/llm-gateway/keys/eca
llm-gateway revoke eca && rm ~/.config/llm-gateway/keys/eca.old
```

A failed `--out` write revokes the key it just issued, so that alias is
spent too; pick the next one.

**Adding a client.** Another jail passes
`gateway = jailLib.gatewayClient "<client>"` (key file
`~/.config/llm-gateway/keys/<client>`, address from `agents/gateway.nix`),
drops its `apiKeys`, and gets a key issued with `--out` that path. A feature
record in this repo also adds `requires = ["agents.gateway"]`. See
`agents/README.md` § Gateway mode.

**Adding a model.** It needs a cost source, or the build fails naming it
(SPEC-001 § Served models and cost): its provider reports cost, or it sets
both `params.input_cost_per_token` and `params.output_cost_per_token`, or it
is in LiteLLM's packaged price map.

1. An entry in the `models` of `agents/gateway.nix`: name
   `<provider>/<upstream id>` (DEC-069), `model`, `provider`, optional `params`
   (merged into LiteLLM's params under that model and key, DEC-070) and optional
   `pi` (a model without it is not offered to pi; the block is described in
   `agents/README.md` § pi in gateway mode). An OpenRouter id is one more line
   in `routed [ … ]`; its helper already allows `reasoning_effort`.
2. `just system-switch` (restarts the gateway, ~25 s).
3. `llm-gateway models ALIAS M,…` for each key that should get it.

**Adding a provider** (DEC-067: credentials first, then switch). A provider
without its credential makes systemd refuse the whole unit, DeepSeek included
(DEC-048).

```bash
# entry in defaults.providers (features/agents/gateway/proxy.nix): env, ref, reportsCost?
just system-build                                   # nothing switched; leaves ./result
./result/sw/bin/llm-gateway credentials <provider>  # the new build's CLI; restarts the old unit
just system-switch                                  # starts with every credential
```

The `llm-gateway` on PATH is the old build's and refuses a provider it does not
know, so `just gateway-credentials` cannot be used here. There are two ~25 s
outages, at the `credentials` restart and at the switch; in-flight requests are
cut off, so run it when no client is mid-request. If you switch first, the unit
fails `243/CREDENTIALS` as on first run; `just gateway-credentials <provider>`
(the PATH CLI is now the new one) fixes it, with every model down until then.
`services.llm-gateway.providers` is the option behind `defaults.providers`: a
host that defines it replaces the whole set, so edit `proxy.nix` instead.

**What it does not cover.**

- OAuth/subscription logins (claude, codex and the like sign in their own way; OpenAI through a subscription is IMP-035). OpenAI
  API-billed models are not configured (DEC-072).
- Jails not on the gateway still get provider keys through `op run`: the other
  `~/dev/*` project flakes (IMP-034) and satan (IMP-030). The unjailed `eca`
  keeps its own keys.
- Anything off this host: the relay is loopback only.
- Budgets are lifetime USD per key, not per period.

**Tests.** `just test` runs `keystore-test`, `checks.<system>.llm-gateway`
(the real proxy app, offline, with a fake OpenRouter: cost to the ledger, the
body guard) and the jail tests.

## Jailed Agents 

template setup for bubblewrap-jailed agents, assuming some conventions:

```zsh
nix flake init -t /home/david/flakes#agents                    # local
nix flake init -t github:davidlee/nix-config?dir=flakes#agents # anywhere
```

The template starts every jail in gateway mode: no provider key enters the jail,
only a key for the local LLM gateway (opt out with `gateway = null`). See § LLM gateway and [agents/README.md](./agents/README.md).

See [README](./pub/README.md) 
