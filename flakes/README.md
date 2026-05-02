# Dotfiles & NixOS, nix-darwin & home-manager system config

[uses this approach](https://www.atlassian.com/git/tutorials/dotfiles) for some things, nix to draw the rest of the owl.

## Principles

- keep a fairly lean core system
- separate userspace & system build using home-manager
- prefer dotfiles over nix. Include raw dotfiles (custom config) in generated nix configs.
- share the things worth sharing (especially cli tooling) across Darwin / macOS
- minimal but secure secret management (out of version control)
- use nix-direnv for project-local dev environments.
- use templates to make this easy
- prefer unstable; pin to stable as an escape hatch for broken packages
- use modules for maintainability and easy coarse-grained configuration changes
  see [design doc](./modules/DESIGN.md`)

## Notes for myself

### OOM resilience

`modules/nixos/oom.nix` — tunes `systemd-oomd` and reserves resources so the desktop stays usable under memory pressure.

**systemd-oomd:** enabled for root, system, and user slices. Kills when swap hits 90%. Default memory pressure duration 20s.

**User session protection:** `user@1000` gets `CPUWeight=200` and `MemoryLow=512M`, guaranteeing the compositor and a rescue terminal get CPU time and memory even when the system is thrashing.

**Emergency kill:** `Super+Ctrl+Delete` opens a floating sticky `htop` for manual triage.

**swayosd:** rate limits relaxed (`StartLimitBurst=10`, `StartLimitIntervalSec=60`, `RestartSec=5s`) so transient crashes don't permanently kill the service. The `exec_always` workaround in `sway.conf` has been removed — it fought with `Restart=always` and caused a crash loop (107 restarts in 4 minutes) that amplified memory pressure.

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

`modules/home/nixos/alarm.nix` — plays a playlist through speakers at scheduled times.

**Stack:** `spotifyd` (headless Spotify Connect device) + `spotify_player` (CLI control) + systemd user timers.

**Timers:** `spotify-alarm` (weekdays) and `spotify-alarm-weekend`. Change times in `alarm.nix`, then `home-manager switch` — no manual systemctl needed.

**First-time setup** (after a rebuild or re-install):
```bash
spotifyd authenticate          # OAuth via browser, stored in keyring
spotify_player authenticate    # OAuth via browser, token cached
systemctl --user enable --now spotify-alarm.timer
systemctl --user enable --now spotify-alarm-weekend.timer
```

**Audio routing:** `Super+a` toggles default sink between speakers and headphones (script: `~/.config/sway/scripts/toggle-audio-sink`). The alarm always forces speakers regardless of current default.

**Reliability:** the alarm script has three phases, each handling a class of silent failure:
1. **Connect spotifyd:** `nm-online` (best effort), then restart spotifyd and poll its log for `active device is` (proof it reached Spotify's servers). Retries up to 3 rounds — handles S3 resume where the network takes 10-30s to stabilize.
2. **Activate device:** query the Spotify API for Sleipnir device IDs and try each with `connect --id`, verifying `is_active` via the API after each attempt. Handles ghost device registrations (old + new both named Sleipnir) where `connect --name` silently fails.
3. **Start playback:** `playback start context` + `playback play` + `playback volume`.

All three commands (`connect`, `playback start`, `playback volume`) return exit 0 regardless of success — the script verifies actual state changes instead of trusting exit codes.

**Watchdog:** `spotifyd-watchdog.timer` (every 5 min) restarts spotifyd if: (a) the last log line is a websocket WARN, or (b) spotifyd has been running >2 min with no `active device is` line (stuck after S3 resume with no network). Skips when playback is active.

