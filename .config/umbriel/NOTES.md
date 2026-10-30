# umbriel config notes

## 2026-10-31: scratchpads and `umbriel msg` after the upgrade

### Done

The upgrade changed `umbriel msg`: the action and each argument are separate
argv words. A joined string (`"window-focus <id>"`, `scratchpad-toggle:<name>`)
is rejected as `unknown action`.

| file | change |
|---|---|
| `scripts/raise-cycle-or-spawn` | `["msg", "window-focus", target]` |
| `scripts/named-workspace` | `umbriel msg workspace-switch "$name"` |
| `scripts/scratchpad-spawn` | deleted: replaced by native `spawn_when_empty` |
| `rules.toml` | `spawn_when_empty` on signal, spotify, onepassword, edit (and commented slack) |
| `apps.toml` | scratchpad binds are plain `scratchpad-toggle <name>` |
| `MAPPING.md` | rows updated to the new syntax and mechanism |

These changes are uncommitted in `~`.

### Known bug: relaunch takes two presses (fix proposed upstream)

Closing a pad's last window keeps the pad shown (by design: `empty_launch.sh`).
`ScratchpadManager::toggle` hides a shown pad before it reaches the
`spawn_when_empty` branch, so:

```
close the app (or it hides to tray)  ->  pad empty, still shown
press 1  ->  hides the empty pad, launches nothing
press 2  ->  shows the pad and launches  ->  window arrives visible
```

Workaround until merged: press twice. Not running a patched umbriel day to day.

### Proposed PR

- Branch `fix/scratchpad-toggle-empty-spawn` in `~/.local/src/umbriel`,
  commit `b803b12c`, on top of `a37ae93f`. Not pushed.
- Title: `fix(scratchpad): relaunch spawn_when_empty when toggling a pad left shown and empty`
- Change: new `ScratchpadManager::spawnDue(name, pad)` returns the
  `spawn_when_empty` command when the pad is empty and no launch is pending.
  `toggle` hides a shown pad only when nothing is due; otherwise it summons and
  launches. Unchanged: a second toggle during a pending launch still hides; an
  empty pad without `spawn_when_empty` still toggles its backdrop; `showStep`
  inherits the fix (it delegates empty pads to `toggle`).
- Test: `tests/harness/checks/scratchpad/default_rule.sh` closes the last
  window, toggles, expects a shown replacement. Red before, green after.
- Results: `just check scratchpad/` 19/19; `just test` 149/149; `just lint`,
  clang-format, shellcheck clean. Full `just check`: 425/426, the failure is
  `layout/tab_group_min_height`, which also fails on unmodified `main`
  (`a37ae93f`); worth mentioning in the PR.

### Loose threads

- **1Password in the tray crashes on launch hand-off.** With its pad empty
  (app in tray, no window), the toggle runs `1password`; the new process hands
  off to the running instance and exits, then umbriel logs `error in client
  communication` for the running instance and it dies ("Fatal Wayland
  communication error"). Seen once, 09:23:20. Cause unknown; possibly umbriel
  mishandling the launch token on a window another process opens. Likely affects
  any single-instance tray app (Signal, Spotify). Needs a reproduction, then an
  upstream issue.
- **Spotify desktop GPU crash.** 09:08:08: `FATAL ... GPU process isn't usable.
  Goodbye.` (SIGTRAP in libcef). Once so far. If it recurs, try
  `spotify --disable-gpu`.
- **spotify_player / spotifyd alarm.** Two playback devices compete:
  `spotifyd` and spotify_player's own (`enable_streaming = "Always"` in
  `~/.config/spotify-player/app.toml`, plus a daemon and TUI both streaming). The
  08:30 alarm loaded a track on spotifyd, then lost the session two seconds
  later and still reported success. Pick one player; make the alarm verify
  playback. See `features/audio/alarm.nix` (not yet read).
- **Muted streams.** WirePlumber had remembered spotify_player as muted; fixed by
  unmuting (state in `~/.local/state/wireplumber/stream-properties`).

## 2026-10-31: review follow-up (items 1, 4, 6)

A config review listed proposals; these were applied. All uncommitted.

| file | change |
|---|---|
| `rules.toml` | `block_capture = true` on every 1Password window (scratchpad and popups) and on Signal. The `^1Password` popup rule is scoped to 1Password's app_id; unverified that popups carry it, so if a credential popup stops floating, that is why. App-id dots escaped |
| `rules.toml` | dropped the ghostty rule and an `opacity = 1.0` (both no-ops); moved the unfocused-blur rule up from below the layer rules |
| `config.toml`, `layout.toml` | dropped keys equal to the schema default: hot corners, struts, `center_underfull_strip`, `xwayland`, `show_cheatsheet` |
| `binds.toml` | `Mod+Ctrl+P` (duplicate pin) removed. `Mod+Comma/Period` and their Shift variants swapped: plain is consume-or-expel, Shift is consume |
| `scripts/test_raise_cycle_or_spawn.py` | `Main` tests: argv sent to `umbriel msg`, and launch when nothing matches. Red against `e7bfec60` (`window-focus:<id>`), green now. Closes the test gap |
| `scripts/screenshot` | window mode reads `umbriel focused-window --json`; `scripts/umbriel-windows` deleted (its only caller) |
| `ruff.toml`, `.gitignore` | line length 120; `__pycache__/` ignored and the two tracked `.pyc` files removed from the index (`git rm --cached`, staged) |

`Alt+Shift+Tab` stays: noctalia's switcher reverses itself.

## 2026-10-31: reorganised along Umbriel's doc seams (review items 3, 5)

The file → owns table is in AGENTS.md. Uncommitted.

- `MAPPING.md`, `noctalia.toml` (unused Tokyo Night palette) and `io.toml`
  deleted; `io.toml` split into `input.toml` and `outputs.toml`.
- Every colour is in `gruvbox.toml`, including `[colors]` from `layout.toml`
  and the state-border window rules from `rules.toml`. The focused rule was
  split: its `outer_border_width = 2` is in `appearance.toml`.
- `[workspaces]`, `[[workspace]] emacs` and `[overview]` moved from
  `config.toml` to `layout.toml`.
- Scratchpads (`[[scratchpad]]`, their window rules, their binds) moved into
  `apps.toml`, from `rules.toml` and `binds.toml`.
- niri correspondence comments removed everywhere, including the axes diagram
  in `binds.toml` and the script headers.
- Verified: `umbriel config validate` ok; the merged config (tables deep-merged
  in include order, rule arrays compared as sets) is identical before and
  after apart from the split focused rule. No two reordered rules set the
  same field, so "later wins" resolves as before. Live reload ok; workspace
  order unchanged.

If Noctalia's theme export is ever pointed at the palette file, the
colour-only window rules must move out of it first (to `appearance.toml`), or
the export overwrites them.

Still open from the review: item 2 (native features: cast-target border,
`windows_resize`, consume-from, dpms, `default_workspace` for emacs, tab bar
`style = "indicator"`).
