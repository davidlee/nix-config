# Spotify Alarm

`modules/home/nixos/alarm.nix` — plays a playlist through speakers at scheduled times.

**Stack:** `spotifyd` (headless Spotify Connect device) + `spotify_player` (CLI control) + systemd user timers.

**Timers:** `spotify-alarm` (weekdays 07:30) and `spotify-alarm-weekend` (Sat/Sun 08:30). Change times in `alarm.nix`, then `home-manager switch` — no manual systemctl needed.

**First-time setup** (after a rebuild or re-install):
```bash
spotifyd authenticate          # OAuth via browser, stored in keyring
spotify_player authenticate    # OAuth via browser, token cached
systemctl --user enable --now spotify-alarm.timer
systemctl --user enable --now spotify-alarm-weekend.timer
```

**Audio routing:** `Super+a` toggles default sink between speakers and headphones (script: `~/.config/sway/scripts/toggle-audio-sink`). The alarm always forces speakers regardless of current default.

## Reliability

The alarm script has three phases, each handling a class of silent failure.

### Phase 1 — Connect spotifyd

`nm-online` (best effort), then restart `spotifyd` and poll its log for `active device is` (proof it reached Spotify's servers). Retries up to 3 rounds, 30s each — handles S3 resume where the network takes 10–30s to stabilize.

### Phase 2 — Activate the correct device

1. **Refresh `spotify-player`.** Unconditionally `systemctl --user restart spotify-player.service` and wait up to 15s for the new daemon to respond to `get key devices`. The long-lived daemon's cached Web API view can miss devices that re-registered while it was idle across S3 cycles — a stale view here was the cause of the 2026-05-18 alarm failure.
2. **Poll the Spotify Web API for Sleipnir device IDs** and try each with `connect --id`, verifying `is_active` via the API after each attempt. Handles ghost device registrations (old + new both named Sleipnir) where `connect --name` silently picks the wrong one.
3. **Budget:** 12 attempts × 5s = 60s. The API can lag spotifyd's `active device is` log line by several seconds, especially right after S3 resume.
4. **Diagnostics:** raw `sp get key devices` stdout+stderr is captured and emitted to the journal on every empty / failed attempt, so an auth failure or HTTP error is distinguishable from a genuinely-empty device list.

### Phase 3 — Start playback

`playback start context` (playlist, shuffle) + `playback play` + `playback volume 100`, then `pactl move-sink-input` for any pre-existing streams.

All three playback commands (`connect`, `playback start`, `playback volume`) return exit 0 regardless of success — Phase 2 verifies actual state changes via the API instead of trusting exit codes.

## Watchdog

`spotifyd-watchdog.timer` runs every 5 minutes and restarts `spotifyd` if either:

- The last recent log line is a websocket WARN (`"[WARN] Websocket"`, `"does not respond"`, `"Error while closing websocket"`).
- `spotifyd` has been running >2 minutes with no `active device is` line (stuck after S3 resume with no network).

Skips entirely when playback is active — don't disturb a working stream.

## Debugging a failed alarm

```bash
journalctl --user -u spotify-alarm.service -b       # this-boot alarm log
journalctl --user -u spotifyd.service --since "07:29" --until "07:32"
systemctl --user start spotify-alarm.service        # manual dry-run, any time of day
```

If Phase 2 logs `no Sleipnir devices in API yet (raw: …)` repeatedly, the `raw:` payload tells you whether the API is genuinely returning an empty list or `spotify_player` is hitting an error.

If Phase 1 fails (no `active device is` after 3 rounds), the problem is upstream of this script — check `spotifyd.service` logs for auth or network errors.
