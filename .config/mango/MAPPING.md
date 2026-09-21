# niri -> mango

How `~/.config/mango` tracks `~/.config/niri`, and where it cannot.

Validate after editing: `mango -c ~/.config/mango/config.conf -p`
Reload in place:       `Super+Shift+R`

## Files

| niri | mango |
|---|---|
| `config.kdl` | `config.conf` |
| `io.kdl` | `io.conf` |
| `layout.kdl` + `noctalia.kdl` | `layout.conf` |
| `animation.kdl` | `animation.conf` |
| `rules.kdl` | `rules.conf` |
| `binds.kdl` | `binds.conf` |
| `apps.kdl` | `apps.conf` |

## The one structural difference

niri is a scrollable-tiling compositor: a horizontal strip of **columns**,
each column a vertical stack of windows, on **dynamic vertical
workspaces**. mango is a dwl descendant: a fixed set of nine **tags**, each
with a pluggable layout. Its `scroller` layout is the same strip-of-columns
model as niri, so every tag defaults to `scroller` (`rules.conf`).

```
     niri                             mango scroller
  ┌────┬────┬────┐                 ┌────┬────┬────┐
  │ A  │ B  │ D  │  columns        │ A  │ B  │ D  │  strip
  │    ├────┤    │                 │    ├────┤    │
  │    │ C  │    │  C stacked      │    │ C  │    │  C in B's stack
  └────┴────┴────┘   under B       └────┴────┴────┘
```

Three axes, unchanged from niri:

| axis | keys | mango action |
|---|---|---|
| along the strip | `Super+Left/Right` | `focusdir left/right` |
| within a column | `Super+Up/Down` | `focusdir up/down` |
| between workspaces | `Super+Page_Up/Down` | `viewtoleft` / `viewtoright` |

The consequence: **mango has no column as a first-class thing you can move.**
niri's `move-column-to-workspace` and `move-window-to-workspace` both become
"move the focused window", so the `Super+Shift+N` and `Super+Alt+N` families
collapse together. `Super+Alt+N` is given `tagsilent` (move it there, stay
here), which is the more useful of the two once the distinction is gone.

## Renamed, same behaviour

| niri | mango |
|---|---|
| `close-window` | `killclient` |
| `focus-column-left/right`, `focus-window-up/down` | `focusdir` |
| `move-column-left/right`, `move-window-up/down` | `exchange_client` |
| `focus-window-or-workspace-up/down` | `focus_window_or_workspace` |
| `focus-monitor-*` | `focusmon` |
| `move-column-to-monitor-*` | `tagmon` |
| `focus-workspace N` | `view N` |
| `move-column-to-workspace N` | `tag N` |
| `consume-or-expel-window-left/right` | `scroller_stack left/right` |
| `switch-preset-column-width` | `switch_proportion_preset` |
| `expand-column-to-available-width` | `set_proportion 1.0` |
| `maximize-column` | `togglemaximizescreen` |
| `fullscreen-window` | `togglefullscreen` |
| `maximize-window-to-edges` | `togglefakefullscreen` |
| `center-column` | `centerwin` |
| `toggle-window-floating` | `togglefloating` |
| `toggle-overview` | `toggleoverview` |
| `recent-windows` `next-window` | `switcher all_tag_next` |
| `workspace-auto-back-and-forth` | `view_current_to_back=1` |
| `focus-follows-mouse` | `sloppyfocus=1` |
| `warp-mouse-to-focus` | `warpcursor=1` |

## Replaced by something mango does natively

| niri needed | mango |
|---|---|
| `nirius` + `niri-scratch-spawn` for per-app scratchpads | `toggle_named_scratchpad appid,none,cmd` |
| `nirius scratchpad-show-all` / `-toggle` | `toggle_scratchpad` / `minimized` |
| `toggle-keyboard-shortcuts-inhibit` | a `passthrough` keymode with only the way out bound |

The keymode is the more general mechanism: `Super+Escape` enters a mode where
nothing else is bound, so every key reaches the client, and `Super+Escape`
leaves it. Same escape hatch, no compositor flag involved.

## Replaced by a script

mango has no IPC-driven raise-or-run and no screenshot UI, so three small
scripts in `scripts/` stand in. They talk to the compositor over `mmsg`.

| niri | mango |
|---|---|
| `~/.local/bin/raise-cycle-spawn` (niri IPC) | `scripts/raise-cycle-spawn` (mmsg) |
| built-in `screenshot`, `screenshot-screen`, `screenshot-window` | `scripts/screenshot area\|screen\|window` (grim/slurp/satty) |
| `power-off-monitors` | `scripts/sleep-monitors` (`sleep_monitor` takes one output at a time) |

`~/.local/bin/toggle-audio-sink` is compositor-agnostic and is used as-is.

## Not available

Bound to nothing, and noted inline in `binds.conf` so the two configs stay
line-comparable.

| niri | why |
|---|---|
| `show-hotkey-overlay` | mango has no overlay |
| `focus-column-first/last`, `move-column-to-first/last` | no jump-to-strip-edge action |
| `move-workspace-up/down` | tags are a fixed ordered set |
| `set-workspace-name` / `unset-workspace-name` | tags are numbered only |
| `set-window-height`, `reset-window-height`, `switch-preset-window-height` | stack members share their slot evenly |
| `switch-preset-column-width-back` | `switch_proportion_preset` cycles one way |
| `center-visible-columns` (`Super+Shift+C`, `Super+I`) | centring is a layout setting (`scroller_prefer_center`), not an action |
| `center-window` (`Super+Shift+I`) | folds into `Super+C`: mango's `centerwin` is the only centring action |
| `switch-focus-between-floating-and-tiling` | no floating/tiling focus hop; `Super+Shift+V` floats everything visible instead |
| `toggle-column-tabbed-display` | nearest is the `deck` layout, so `Super+W` switches to it and `Super+Shift+W` back to `scroller` |
| `nirius toggle-follow-mode` | nirius is niri-only |
| `focus-workspace-previous` | no previous-tagset action in 0.17.2; `Alt+Tab` is `focuslast` (previous *window*) and the tag keys ping-pong via `view_current_to_back` |

Approximations, where mango is close but not identical:

- **`set-column-width -10%/+10%`** (`Super+Minus/Equal`). mango's
  `set_proportion` is absolute and scroller-only, so these drive `setmfact`,
  which the tile-family layouts use. On `scroller`, cycle widths with
  `Super+R`.
- **`Mod+grave next-window filter="app-id"`**. mango's switcher scopes by tag,
  not app id, so `Super+grave` lists the current tag instead.
- **`struts`**. niri sets them per edge (top 1, sides 10, bottom 10); mango's
  outer gaps are horizontal/vertical only, so the sides win.
- **`focus-ring` gradients**. mango draws one flat border per window. The
  colours come from `noctalia.kdl`, which niri includes last and so wins
  there anyway.
- **trackball settings**. mango applies one pointer profile to all devices, so
  niri's separate `trackball` block is gone.

## Deliberate additions

Things mango has that niri does not, bound to keys niri leaves free:

- `Super+Shift+O` — overview with jump labels. `jump_labels` in `layout.conf`
  starts on the Gallium home row (`n r t s g y h a e i`) rather than the
  default `HJKL...`.
- `Super+Comma` / `Super+Period` — `groupjoin right` / `groupleave`. niri
  splits consume and expel across these keys; mango merges both into
  `scroller_stack`, so they drive groups instead — the same "bind these
  windows together" idea, and it works in every layout, not just `scroller`.
- `Super+Ctrl+W` — cycle layouts (`circle_layout` in `layout.conf`).
- `Super+Ctrl+N` — `restore_minimized`.
- `Super+Shift+Minus/Equal`, `Super+Ctrl+G` — adjust and toggle gaps.

## Dropped from the previous mango config

The starter `config.conf` had `exec /ghostty` (a terminal on every reload),
`Super+L rofi -show run`, and `Super+M quit`. None have a niri counterpart;
the launcher is noctalia/vicinae, `Super+Alt+L` locks, and `Super+Shift+E`
quits, as in niri.

## Docs lag the build

mango 0.17.2 is pinned in `~/flakes/flake.nix` (`inputs.mangowm`). Two things
the published docs describe are not in it, both found by `mango -p` or by
reading `src/`:

- `windowrule=single_scratchpad:...` — not a window-rule option yet. The
  global `single_scratchpad=1` default covers it.
- `view,-1` for the previous tagset — parses to "view all tags" here.

Check `mango -c ... -p` after any edit, and prefer the shipped
`/etc/mango/config.conf` over the website when the two disagree.
