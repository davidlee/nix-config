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
  see [design doc](./modules/DESIGN.md`)

## Notes 

### Bootstrap macOS

Lix and Homebrew must already be installed. The `Davids-MacBook-Pro` target
uses the existing `david` account and leaves the installer-managed Lix in
place (`nix.enable = false`). This replaces the previous `fusillade` target.

From `~/flakes`:

```sh
nix build 'path:/Users/david/flakes#darwinConfigurations.Davids-MacBook-Pro.system' --override-input emacs path:/Users/david/flakes/emacs --out-link result-darwin --no-write-lock-file
sudo -H ./result-darwin/sw/bin/darwin-rebuild switch --flake 'path:/Users/david/flakes#Davids-MacBook-Pro' --override-input emacs path:/Users/david/flakes/emacs --no-write-lock-file
```

With `just` installed, `just darwin-switch` runs both steps. Both use the local
`emacs/` flake so package-list fixes apply without a push and input update.

Use an explicit `path:` reference because the dotfiles repository at `~/.git`
is bare; automatic Git discovery otherwise fails with “this operation must
be run in a work tree”. `sudo -H` gives root its own home directory and avoids
the `$HOME` ownership warning. Only activation needs root.

### Feature flags

Coarse on/off switches, resolved per host and threaded into **all three**
configs: `specialArgs` for NixOS and darwin, `extraSpecialArgs` for standalone
home-manager. (Darwin runs home-manager as a darwin module and reuses
`specialArgs` as its `extraSpecialArgs`, so one entry covers both its halves.)

| file | role |
|------|------|
| `modules/features.nix` | option declarations and defaults |
| `features.nix` | resolver — `lib.evalModules`, once, per host |
| `hosts/<hostname>/features.nix` | that host's overrides (optional) |

Deliberately **not** a NixOS option. The three configs evaluate independently —
separate nixpkgs (`nixpkgs` vs `nixpkgs-home`), separate `switch` — so an option
declared in one is invisible to the others. Evaluating the option set once,
outside all of them, and injecting the result keeps one source of truth.

Being a specialArg is also what lets `features` gate `imports`: imports are
resolved before `config` exists, so a real option could not do this.

```nix
# hosts/Sleipnir/config.nix
imports =
  [ ...unconditional... ]
  ++ lib.optional features.desktop.sway ../../modules/nixos/sway.nix
  ++ lib.optional features.games.enable ../../modules/nixos/games.nix;
```

Import-gating is the mechanism, not in-module `mkIf`: it reads as the direct
replacement for commenting out an import, the import list shows what is on, and
it works even for modules that cannot evaluate.

**Defaults and nesting.** A flag may default to another flag —
`games.gamescope` and `games.mangohud` follow `games.enable` unless a host pins
them. Overrides go in `hosts/<hostname>/features.nix`, which is an ordinary
module, so `mkForce` and friends work:

```nix
{
  games.enable = true;
  games.gamescope = false;   # steam, but no gamescope session
}
```

A missing host file means the host takes every default unchanged.

| flag | default | gates |
|------|---------|-------|
| `desktop.{sway,niri}` | `true` | `modules/nixos/<wm>.nix` + `modules/home/linux/<wm>.nix` |
| `desktop.{cosmic,kde,mango}` | `true` | `modules/nixos/<wm>.nix` |
| `games.enable` | `false` | `modules/nixos/games.nix` (steam, wine, its `nix-ld` libraries) |
| `games.gamescope` | ← `games.enable` | `modules/nixos/gamescope.nix` |
| `games.mangohud` | ← `games.enable` | `modules/home/linux/games.nix` |
| `ai.{llama-cpp,rocm}` | `true` | `modules/nixos/<name>.nix` |
| `hardware.{openrgb,microcode,ssd}` | `false` | `modules/nixos/<name>.nix` |
| `virt.qemu` | `true` | `modules/nixos/qemu.nix` |
| `virt.docker` | `false` | `modules/nixos/docker.nix` (rootless; podman is unconditional) |
| `apps.{appimage,flatpak}` | `true` | `modules/nixos/<name>.nix` |
| `apps.cad` | `true` | `modules/home/linux/cad-3d.nix` |
| `fonts`, `printing`, `speech`, `webserver` | `true` | `modules/nixos/<name>.nix` |
| `snooze` | `true` | `modules/nixos/snooze.nix` + `modules/home/linux/snooze.nix` |
| `dictate` | `true` | `modules/home/linux/dictate.nix` |
| `mpd` | `false` | `modules/nixos/mpd.nix` |
| `sunshine` | `false` | `modules/nixos/sunshine.nix` |

**Parked is not a feature.** `modules/nixos/{hyprland,kmscon}.nix` and
`modules/home/linux/danksearch.nix` stay commented out in their import lists.
They do not evaluate — `hyprlandPlugins.hyprexpo` is gone, `services.kmscon.fonts`
was removed upstream, danksearch's flake input is commented out — so a flag
would promise a switch that breaks the build when flipped. Repair first, then
promote to a flag.

### Hosts

`hosts.nix` builds every configuration from the `hosts/` directory: each
`hosts/<host>/meta.nix` is plain data, and `hosts/<host>/config.nix` is the
entry point.

```nix
# hosts/Sleipnir/meta.nix
{ kind = "nixos"; system = "x86_64-linux"; home = true; }
```

| kind | output | home-manager |
|------|--------|--------------|
| `nixos` | `nixosConfigurations.<host>` | standalone, `homeConfigurations."david@<host>"` from `home.nix`, when `home = true` |
| `darwin` | `darwinConfigurations.<host>` | darwin module (`darwin/`) |

Adding a host means adding a directory. The justfile selects the
configuration by `hostname`; override with `just host=<other> system-build`
(or `home-build`). `run.sh <cmd> <host>` takes it as its second argument.
`homeConfigurations.david` is a transitional alias for `david@Sleipnir`.
See [MULTIHOST.md](./MULTIHOST.md) for the plan this is part of.

### Dictation

`modules/home/linux/dictate.nix` + `modules/home/linux/bin/dictate` — streaming
speech-to-text, typed at the cursor as you speak. Local and CPU-only.

```
F9 ──> dictate toggle ──SIGUSR1──> dictate.service (model resident, mic closed)
                                     pw-record ──100ms──> Nemotron ──> wtype
```

The model is NVIDIA's [Nemotron 3.5 ASR streaming 0.6B](https://huggingface.co/nvidia/nemotron-3.5-asr-streaming-0.6b)
(cache-aware FastConformer encoder with an RNN-T decoder, punctuation and
capitals included), as sherpa-onnx's int8 export with 560 ms chunks. One
thread decodes at about 1/7 real time, so live dictation costs about a seventh
of one core. Idle, the daemon holds about 1.5 GB of RAM and no CPU.

Typing as you speak depends on the transcript only growing: cache-aware
streaming emits each token once, so each new piece is typed and earlier text
is never revised. If a revision ever happens, `edit` backspaces it.

A toggle starts dictation; a second toggle, or `DICTATE_IDLE` (10 s) without
new words, stops it. A toast says when the mic opens and closes. The bind is in
`~/.config/umbriel/binds.toml`; a ZMK key sending F9 is enough.

```bash
just test                       # behaviour tests, no mic or model
DICTATE_MODEL=<unpacked model> modules/home/linux/bin/dictate-test   # + real model
journalctl --user -u dictate -f
```

Language is `DICTATE_LANG` in the module (`en`, `fr`, …, or `auto`); a wrong
hint garbles the output rather than degrading gracefully. Push-to-talk would
need start/stop signals in place of the toggle, and a key-release bind.
Measurements and open options: [DICTATE.md](./DICTATE.md).

### Sleipnir Doctor

`modules/home/nixos/sleipnir-doctor.nix` — at-a-glance system health check. Run `sleipnir-doctor`.

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

**Shipped provider:** `sleipnir-doctor-emacs` calls `emacsclient -e '(sleipnir-doctor-checks)'` for server uptime and eglot/LSP health. Elisp side lives in `~/.emacs.d/lisp/dl-sleipnir-doctor.el`.

### OOM resilience

`modules/nixos/oom.nix` — tunes `systemd-oomd` and reserves resources so the desktop stays usable under memory pressure.

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

`modules/home/linux/snooze.nix` + `modules/nixos/snooze.nix` — nags the machine
to bed each night, and wakes it via RTC alarm.

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

Bedtime and the wake time are in the `let` blocks at the top of each module;
the ladder, the absence window and the night window are `SNOOZE_*` defaults at
the top of the script.

```bash
just test                                              # behaviour tests, no display needed
SNOOZE_GRANTS='2 1' SNOOZE_UNIT=1 SNOOZE_ABSENT=1 snooze-nag   # the whole ladder in seconds
journalctl --user -u snooze-nag -f
```

### Printing

`modules/nixos/printing.nix` — CUPS with drivers for Brother HL-L2445DW (laser) and Canon TR8600 (inkjet via gutenprint).

**Printers:** both discovered via Avahi/mDNS (`avahi.nix`). The `laser` queue is the default printer. Assign static DHCP leases on the router so IPP URIs don't break.

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

`modules/nixos/llama-cpp.nix` — `llama-server` on `127.0.0.1:8080` (OpenAI-compatible
API + web UI), serving [Ternary-Bonsai-2-27B](https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf)
on the RX 9070 XT via ROCm. Gated by `ai.llama-cpp` — **currently off** on
Sleipnir (no use case a hosted model doesn't cover better); the config is kept
working. Flip the flag in `hosts/Sleipnir/features.nix` and `system-switch` to
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

`ai.rocm` is not needed — it sets `rocmSupport` globally and rebuilds much of nixpkgs.

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

See [ALARM.md](./ALARM.md). `modules/home/nixos/alarm.nix` — plays a playlist through speakers at scheduled times via `spotifyd` + `spotify_player` + systemd user timers.

### Emacs

emacs-unstable-pgtk (emacs-macport on darwin) plus a hand-maintained package
list, built via [nix-community/emacs-overlay](https://github.com/nix-community/emacs-overlay).

| file | role |
|------|------|
| `emacs/emacs.nix` | the package list (`emacsWithPackages`) |
| `emacs/flake.nix` | its own flake with its own nixpkgs/overlay pins, shared with the `~/.emacs.d` and satan devshells |
| `modules/home/shared/emacs.nix` | installs it on PATH and as the `services.emacs` daemon |

**Two package sources:**

```
use-package foo
  ├─ foo in emacs/emacs.nix ──> nix store, on load-path at startup   (default)
  └─ :vc (:url …)           ──> package-vc clones into ~/.emacs.d/elpa at runtime
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
still runs, to activate what is in `~/.emacs.d/elpa`. Prefer nix, and don't
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

`modules/nixos/network.nix` — `environment.etc."gai.conf"` sets `precedence ::ffff:0:0/96 100`, flipping getaddrinfo to prefer IPv4 over the RFC 6724 default (which prefers v6).

**Why:** the ISP's v6 egress goes intermittently dead — the router keeps advertising a v6 default route and delegating a global prefix (`2403:5802:…`), but outbound v6 `connect()` blackholes ~3s then fails. Because a global v6 address exists, RFC 6724 makes apps dial the dead v6 first on every dual-stack name, so everything stalls seconds per attempt. It surfaced as a nix FOD hanging forever in `bun install --frozen-lockfile` (fresh `HOME` cache → full download, each dep dialling dead v6 first).

**Why this fix and not others:** interface-agnostic (covers wired + wifi + future, one place — no per-NM-profile duplication) and **self-healing** — when the ISP's v6 recovers, apps just work again, still preferring v4. The alternative (`ipv6.ignore-auto-routes` per NM profile) hard-kills the v6 default route and has to be reverted by hand once v6 is back.

**Diagnosing:** `curl -sS -o /dev/null -w '%{remote_ip}\n' https://registry.npmjs.org/` should connect via a v4 addr. If v6 is truly dead, `curl -6 https://…` fails after a few seconds while `curl -4 …` returns instantly.

**Removal:** harmless to leave (v4 preference costs nothing when v6 works). Drop it only if you want strict RFC 6724 v6-preference back once the ISP is reliably dual-stack.

## Jailed Agents 

template setup for bubblewrap-jailed agents, with secure 1password-managed API keys, assuming some conventions:

```zsh
nix flake init -t /home/david/flakes#agents                    # local
nix flake init -t github:davidlee/nix-config?dir=flakes#agents # anywhere
```

See [README](./pub/README.md) 
