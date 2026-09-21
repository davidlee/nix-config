# niri -> umbriel

How `~/.config/niri/umbriel` tracks `~/.config/niri`, and where it cannot.

Validate after editing: `umbriel validate -c ~/.config/niri/umbriel/config.toml`
Reload:                 automatic — Umbriel watches the config and its includes.

Umbriel's default config path is `~/.config/umbriel/config.toml`. Either run
`umbriel -c ~/.config/niri/umbriel/config.toml`, or symlink the directory:

```
ln -s ~/.config/niri/umbriel ~/.config/umbriel
```

The script paths inside `binds.toml` and `apps.toml` are spelled
`~/.config/niri/umbriel/scripts/...`, so they keep working either way.

## Files

| niri | umbriel |
|---|---|
| `config.kdl` | `config.toml` |
| `io.kdl` | `io.toml` |
| `layout.kdl` | `layout.toml` |
| `noctalia.kdl` | `noctalia.toml` |
| `animation.kdl` | `animation.toml` |
| `rules.kdl` | `rules.toml` |
| `binds.kdl` | `binds.toml` |
| `apps.kdl` | `apps.toml` |

Include order matters and is inverted from niri's. niri applies includes where
they appear, so `noctalia.kdl` wins by being last. Umbriel merges **required
includes in list order, then optional includes, then the main file**. So
`config.toml` beats every include, and `noctalia.toml` is listed under
`[include.optional]` to keep the palette winning over `layout.toml`. Rule
arrays (`[[window_rule]]`, `[[layer_rule]]`, `[[workspace]]`,
`[[scratchpad]]`) accumulate across all files instead of replacing.

## The model carries over

Both are scrollable tiling compositors: a strip of **columns**, each column a
vertical stack, on workspaces. All three axes survive unchanged.

```
  ┌────┬────┬────┐
  │ A  │ B  │ D  │  along the strip   Mod+Left  / Mod+Right
  │    ├────┤    │
  │    │ C  │    │  within a column   Mod+Up    / Mod+Down
  └────┴────┴────┘  between workspaces Mod+Page_Up / Mod+Page_Down
```

The one vocabulary shift: niri's *column width* and *window height* are
Umbriel's **primary** and **secondary extent**, and one `extent_presets` list
feeds both, where niri had `preset-column-widths` and
`preset-window-heights` separately.

## Renamed, same behaviour

| niri | umbriel |
|---|---|
| `close-window` | `window-close` |
| `focus-column-left/right` | `window-focus-left/right` |
| `focus-window-up/down` | `window-focus-up/down` |
| `move-column-left/right` | `column-move-left/right` |
| `move-window-up/down` | `window-move-up/down` |
| `focus-window-or-workspace-up/down` | `window-focus-or-workspace-up/down` |
| `focus-column-first/last` | `column-focus-first/last` |
| `move-column-to-first/last` | `column-move-to-first/last` |
| `focus-monitor-*` | `output-focus-*` |
| `move-column-to-monitor-*` | `column-move-to-output-*` |
| `focus-workspace-down/up` | `workspace-next/previous` |
| `move-column-to-workspace-down/up` | `column-move-to-workspace-next/previous` |
| `move-window-to-workspace-down/up` | `window-move-to-workspace-next/previous` |
| `move-workspace-down/up` | `workspace-move-down/up` |
| `focus-workspace N` | `workspace-switch:N` |
| `move-column-to-workspace N` | `column-move-to-workspace:N` |
| `move-window-to-workspace N` | `window-move-to-workspace:N` |
| `focus-workspace-previous` | `workspace-focus-last` |
| `consume-or-expel-window-left/right` | `window-consume-or-expel-left/right` |
| `switch-preset-column-width[-back]` | `window-cycle-primary-extent[-back]` |
| `switch-preset-window-height` | `window-cycle-secondary-extent` |
| `set-column-width "±10%"` | `window-modify-primary-extent:±0.1` |
| `set-window-height "±10%"` | `window-modify-secondary-extent:±0.1` |
| `maximize-column` | `window-toggle-maximize` |
| `fullscreen-window` | `window-toggle-fullscreen` |
| `maximize-window-to-edges` | `window-toggle-maximize-to-edges` |
| `center-column` | `column-center` |
| `center-window` | `window-center` |
| `toggle-window-floating` | `window-toggle-floating` |
| `switch-focus-between-floating-and-tiling` | `window-focus-switch-floating` |
| `toggle-overview` | `overview-toggle` |
| `show-hotkey-overlay` | `cheatsheet-toggle` |
| `power-off-monitors` | `dpms-off` |
| `toggle-keyboard-shortcuts-inhibit` | `shortcuts-inhibit-toggle` |
| `quit` | `session-quit` |
| `spawn-sh "…"` | `spawn:…` (already goes through the shell) |
| `WheelScrollDown/Up/Left/Right` | `WheelDown/Up/Left/Right` |
| `focus-follows-mouse max-scroll-amount="30%"` | `input.focus.follows_mouse` + `follows_mouse_max_scroll = 0.3` |
| `workspace-auto-back-and-forth` | `workspaces.back_and_forth` |
| `hide-after-inactive-ms` | `input.cursor.hide_timeout_ms` |
| `mouse { accel-speed }` | `input.mouse.sensitivity` |
| `blur { offset }` | `appearance.blur.radius` |
| `background-effect { xray true }` | `blur_optimized = true` |
| `geometry-corner-radius` (per rule) | `appearance.corner_radius` (global) |
| `focus-ring { width }` | `appearance.border_width` |
| `hotkey-overlay { skip-at-startup }` | `general.show_cheatsheet = false` |

## Replaced by something Umbriel does natively

| niri needed | umbriel |
|---|---|
| `nirius` + `niri-scratch-spawn` for per-app scratchpads | `[[scratchpad]]` names + `default_scratchpad` window rules + `scratchpad-toggle:<name>` |
| `nirius scratchpad-show-all` / `-toggle` | `scratchpad-toggle:main` / `window-toggle-scratchpad:main` |

Naming any scratchpad disables Umbriel's implicit `default` one and makes the
name suffix mandatory on every scratchpad action, so `main` exists purely to
keep niri's generic `Mod+N` family working. The five app scratchpads
(`signal`, `slack`, `spotify`, `onepassword`, `edit`) are wired up by
`default_scratchpad` rules in `rules.toml`, which is where niri had
`open-floating true` for the same apps.

## Replaced by a script

Umbriel has no screenshot UI and no focus-by-app-id action, so `scripts/`
stands in. They talk to the compositor over `umbriel msg` and
`umbriel windows --json`.

| niri | umbriel |
|---|---|
| `~/.local/bin/raise-cycle-spawn` (niri IPC) | `scripts/raise-cycle-spawn` |
| `~/.local/bin/niri-scratch-spawn` (nirius) | `scripts/scratchpad-spawn` — only the launch-if-absent half |
| built-in `screenshot`, `screenshot-screen`, `screenshot-window` | `scripts/screenshot area\|screen\|window` (grim/slurp/satty) |

`scripts/umbriel-windows` normalises the window list for the other three.
Umbriel 0.1.0 ships no IPC schema documentation and the compositor was not
running when this was written, so its jq filter accepts several plausible
field spellings. **Check it against real `umbriel windows --json` output on
first run** — it is the only place a schema change bites.

`~/.local/bin/toggle-audio-sink` is compositor-agnostic and is used as-is.

## Not available

Bound to nothing, and noted inline in the TOML so the two configs stay
line-comparable.

| niri | why |
|---|---|
| `hotkey-overlay-title="…"` per bind | the cheatsheet exists, but binds carry no label; the titles survive as comments |
| `expand-column-to-available-width` (`Mod+Ctrl+F`) | no fill-the-remaining-space action; `Mod+F` takes the whole viewport |
| `center-visible-columns` (`Mod+Shift+C`, `Mod+I`) | centring the strip is a setting (`layout.scrolling.center_underfull_strip`), not an action |
| `reset-window-height` (`Mod+Ctrl+R`) | no reset; the key reverse-cycles the secondary extent instead |
| `set-workspace-name` / `unset-workspace-name` (`Mod+Ctrl+X`, `Mod+Alt+R`) | workspace names come from `[[workspace]]` config only |
| `toggle-column-tabbed-display` (`Mod+W`) | no tabbed columns; the key changes the workspace layout mode instead |
| `switch-layout "prev"` (`Mod+MouseBack`) | `keyboard-layout-next` only cycles forward |
| `nirius toggle-follow-mode` (`Mod+X`) | nirius is niri-only, and `input.cursor.follows_focus` has no runtime toggle |
| `focus-ring` / `border` gradients | one flat colour per state |
| urgent colours, `match is-urgent=true` | no urgent state in colours or window rules |
| `match is-window-cast-target=true` | no cast-target selector, and window rules cannot set border colours |
| `tab-indicator { … }` | no tabs |
| `shadow { spread, draw-behind-window }` | softness and offset only |
| `layer-rule { block-out-from "screencast" }` | layer rules control blur and nothing else |
| `layer-rule { place-within-backdrop true }` | same — so quickshell and the wallpaper layer are ordinary layers |
| `layout { background-color }`, `overview { workspace-shadow }` | overview colours are `colors.overview.*`; no per-workspace shadow |
| `animations { slowdown }` | durations are absolute |
| `config-notification-open-close`, `screenshot-ui-open` | neither UI exists |
| `debug { force-pipewire-invalid-modifier }` | **no equivalent.** This is the dual-GPU screencast fix from `zoom-sucks.md`; per-window screencast may go black under Umbriel |
| `debug { honor-xdg-activation-with-invalid-serial }` | no equivalent; `general.focus_on_activate` is the nearest lever |

Approximations, where Umbriel is close but not identical:

- **`consume-window-into-column` / `expel-window-from-column`** (`Mod+Comma`,
  `Mod+Period`). niri pulls a neighbour in and pushes one out. Umbriel only has
  `window-consume-left/right`, which stacks the *focused* window into the
  column beside it — so these two keys now differ from `Mod+[` / `Mod+]` only
  in that they never expel.
- **recent-windows** (`Mod+Tab`, `Mod+grave`). niri had an MRU overlay with
  previews and an app-id filter. Umbriel cycles in layout order
  (`window-focus-next/previous`) and remembers one previous window
  (`window-focus-last`), so `Mod+Shift+grave` has no counterpart.
- **animation curves.** niri's `ease-out-quad`/`-cubic`/`-expo` all collapse to
  `easeout`; springs carry over as `"spring:damping,stiffness"`. niri's
  separate `window-movement` and `window-resize` are one `windows_move` event,
  and `horizontal-view-movement` has no event of its own.
- **trackball.** niri configured the device *class*; Umbriel overrides by exact
  device name. `io.toml` carries the block commented out — fill in the name
  from `libinput list-devices` when the trackball is plugged in.
- **named workspaces.** niri's four `workspace "…"` declarations land on the
  first monitor. Umbriel's `[[workspace]] name = …` materialises one on *every*
  dynamic output unless scoped with `output = "…"`.

## Deliberate additions

Keys niri leaves free, bound to things Umbriel has and niri does not:

- `Mod+P` — `window-toggle-pinned` (stays put across workspace switches).
- `Mod+W` / `Mod+Shift+W` — `workspace-set-layout:toggle` / `:scrolling`,
  standing in for niri's tabbed-column toggle. Umbriel's `dwindle` and
  `master` modes have no niri counterpart at all.
- `Mod+Ctrl+N` — `window-restore-from-scratchpad:main`.

## Dropped

`niriusd` is gone from autostart: it existed to serve `nirius`, and scratchpads
are native now. `XDG_CURRENT_DESKTOP` is gone from `[environment]` because the
session file already sets `DesktopNames=Umbriel`.
