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

**Reliability:** three issues conspire to break the alarm:
- **S3 resume race:** the alarm timer wakes the machine from suspend, but the network isn't ready yet. The script runs `nm-online --timeout=30` before doing anything.
- **Stale websocket:** spotifyd's websocket to Spotify dies silently overnight (WARNs but doesn't exit, so `Restart=on-failure` never trips). The alarm script does `systemctl --user restart spotifyd` to get a fresh connection.
- **Ghost devices:** after restart, Spotify's API briefly lists both the old and new device registrations under the same name. `connect --name` silently picks the wrong one. The script polls spotifyd's log for the `active device is <id>` line and uses `connect --id`.

**Watchdog:** `spotifyd-watchdog.timer` (every 5 min) inspects spotifyd's last 15 min of logs; if the most recent line is a websocket WARN, it restarts spotifyd. Skips when playback is active.

**Command order matters:** `connect --id` → `playback start context …` → `playback volume`. Activating the device *first* avoids `no active playback found` and 500s.

