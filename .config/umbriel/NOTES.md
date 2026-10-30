# umbriel config notes

Upstream bugs and proposals (scratchpad relaunch, tab focus, 1Password tray
crash) are in UPSTREAM.md.

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

### Loose threads

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

## 2026-10-31: native features adopted (review item 2)

| feature | where |
|---|---|
| shared-window frame: 3px, gruvbox red (`match.is_cast_target`) | width `appearance.toml`, colour `gruvbox.toml` |
| `[animation.windows_resize]` 220 ms easeinout, matching moves (A/B tested against default and spring) | `animation.toml` |
| pull-in `window-consume-from-left/right` on `Mod+BracketLeft/Right`; consume-or-expel moved to `Mod+Shift+Brackets` (`Mod+Comma/Period` duplicate it, kept) | `binds.toml` |
| `dpms-off` on `Mod+Ctrl+P` (input wakes the monitors) | `binds.toml` |
| tab bar `style = "indicator"` replaces `title_format = ""` | `appearance.toml` |

Declined: `default_workspace = "emacs"` (new frames should open where you are).
Every review item is now closed.
