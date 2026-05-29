# NixOS, nix-darwin & home-manager system config

Declarative config for my development and thought crime workstation, Sleipnir,
plus laptop.

NixOS / MacOS (Nix-Darwin), home-manager, zsh, emacs / neovim, wayland + sway.

It's modular Nix, and there's a decent amount of it, but I actively prefer
plain old dotfiles for application config.

Nix is amazing, but it's tag line should be:

> An awful implementation of the only thing that makes sense.

So I [use this approach](https://www.atlassian.com/git/tutorials/dotfiles) for what makes sense, Nix to draw the rest of the owl.

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

**User session protection:** `user@1000` gets `CPUWeight=200` and `MemoryLow=512M`, guaranteeing the compositor and a rescue terminal get CPU time and memory even when the system is thrashing.

**Emergency kill:** `Super+Ctrl+Delete` opens a floating sticky `htop` for manual triage.

**swayosd:** rate limits relaxed (`StartLimitBurst=10`, `StartLimitIntervalSec=60`, `RestartSec=5s`) so transient crashes don't permanently kill the service.

### Snooze (sleep/wake timer)

`modules/nixos/snooze.nix` + `modules/home/nixos/snooze.nix` — suspends the machine nightly and wakes it via RTC alarm.

**System timers** (`nixosModules.snooze`): `snooze-suspend` runs `systemctl suspend` at 23:20. `snooze-wake` sets an RTC alarm (`WakeSystem=true`) for 07:00.

**User timer** (`homeModules.snooze`): `snooze-warn` sends a critical notification 5 minutes before suspend (23:15).

Times are configurable in the `let` blocks at the top of each module.

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

### Spotify Alarm

See [ALARM.md](./ALARM.md). `modules/home/nixos/alarm.nix` — plays a playlist through speakers at scheduled times via `spotifyd` + `spotify_player` + systemd user timers.

### Emacs

`modules/home/emacs.nix` — emacs-unstable-pgtk with nix-managed packages via [nix-community/emacs-overlay](https://github.com/nix-community/emacs-overlay).

**How it works:** `emacsWithPackagesFromUsePackage` parses all `.el` files in `~/.emacs.d/{core,apps,lang,lisp,editing,completion}/` for `(use-package ...)` forms and bundles the named packages into the nix derivation. `alwaysEnsure = true` (nix-side) means every `use-package` form is treated as a package to install — no `:ensure t` needed in elisp.

**The same `emacs` derivation** is used for both `home.packages` (PATH) and `services.emacs.package` (daemon). If these diverge, `emacsclient` connects to a daemon with different packages than `emacs --batch`.

**Gotchas:**

- **Path resolution:** `emacsDir` must be a relative nix path (`../../../.emacs.d`), not an absolute path constructed via string interpolation. Flake eval copies the git tree into the store; absolute paths like `/. + "/home/..."` bypass this and resolve to nothing. The `builtins.pathExists` guard silently returns `false`, producing an empty config string and zero packages with no error.

- **Git tracking:** flake eval only sees git-tracked files. New `.el` files must be `git add`ed before `home-manager switch` will pick them up.

- **Runtime package management is disabled.** `dl-package-loader.el` sets `use-package-always-ensure nil` and does not call `package-initialize` or `package-refresh-contents`. Nix owns package installation; emacs should not try to install anything at runtime.

- **`:init` vs `:config`:** with nix-managed packages, autoloads may not be activated when `:init` runs. Any `use-package` block that calls a mode function (e.g. `(vertico-mode)`, `(doom-modeline-mode 1)`) must use `:demand t` + `:config`, not `:init`. Without `:demand t`, `use-package` defers loading until a trigger fires, and the mode function won't exist yet.

- **Built-in packages:** `recentf`, `saveplace`, `savehist` etc. produce harmless `trace:` warnings during build — they ship with emacs and aren't in MELPA/ELPA.

- **EAF and other attrset-valued epkgs:** a few entries in `epkgs` are not derivations but factory attrsets — e.g. `epkgs.eaf` is `{ override, overrideDerivation, withApplications }` (you call `.withApplications { enabledApps = [...]; }` to get a derivation). `emacsWithPackagesFromUsePackage` sees the bare `(use-package eaf ...)`, tries to coerce the attrset to a path, and fails with `error: cannot coerce a set to a string`. Add `:ensure nil` to any `use-package` form whose name matches an attrset-valued epkg; nix-side, install the real derivation via `extraEmacsPackages` (see `eaf-with-reinput` in `emacs.nix`).

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

## Jailed Agents 

template setup for bubblewrap-jailed agents, with secure 1password-managed API keys, assuming some conventions:

```zsh
nix flake init -t /home/david/flakes#agents                    # local
nix flake init -t github:davidlee/nix-config?dir=flakes#agents # anywhere
```

See [README](./pub/README.md) 

