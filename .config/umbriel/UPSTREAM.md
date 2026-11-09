# Upstream work for Umbriel

Bugs and features this config works around, to be fixed in Umbriel itself
(`~/.local/src/umbriel`, origin `noctalia-dev/umbriel`). Method: reproduce
with a harness check (`just check <name>`) on a branch, red before green; the
user raises the PR or issue. Don't run a patched umbriel day to day.

| item                                                                      | status                                                 | workaround here                                    |
|---------------------------------------------------------------------------|--------------------------------------------------------|----------------------------------------------------|
| [Scratchpad #751](#scratchpad-relaunch-takes-two-presses)                 | `hide_when_empty` (#586) pushed to fork, PR not opened | press twice                                        |
| [Up/down focus skips tabs](#updown-focus-skips-tabs)                      | proposal, not started                                  | `scripts/focus-vertical`                           |
| [1Password tray crash](#1password-in-the-tray-crashes-on-launch-hand-off) | needs a reproduction                                   | none                                               |
| [Swap with the master](#swap-with-the-master)                             | proposal, not started                                  | `scripts/swap-master`                              |
| [IPC: a window's master-layout area](#ipc-a-windows-master-layout-area)   | proposal, not started                                  | none; geometry heuristics in `scripts/swap-master` |

When an item lands in the pinned version (`umbriel` input in
`~/flakes/flake.lock`), remove its workaround and its entry here.

## Up/down focus skips tabs

A tab group is one row of its column, so `window-focus-up/down` (and the
`-or-workspace-` / `-or-output-` variants) skip over a group: entering it lands
on the active tab, and tabs switch only with `column-focus-tab-*`, clicks or
the wheel (docs `layout.md` § Tab groups; source `actions.cpp:946`,
`cursor.cpp:2071`, `TabPresenter::step`). With the bar on the left, up/down is
the natural tab axis.

**Proposal:** a `[layout.tabs]` option making directional focus step tabs
first and leave the group only at its first or last tab. Not started; needs a
read of how directional focus picks its target.

**Workaround:** `Mod+Up/Down` spawn `scripts/focus-vertical up|down`, which
steps tabs inside a group and otherwise sends `window-focus-up/down` (stays on
the workspace; switching to `window-focus-or-workspace-*` is one line in the
script). Cost per press, excluding the bind's spawn: windows query and
decision 22 ms median, plus `umbriel msg` about 6 ms (native bind: about
1 ms); no perceptible lag. Tests: `scripts/test_focus_vertical.py`.
`Mod+Alt+Up/Down` step tabs directly. Once upstream has the option, delete the
script and its tests and bind the native actions.


## Swap with the master

No action swaps the focused window with the master (dwm's "zoom").
`scripts/swap-master` stands in: it sends `window-swap-left/right` toward the
other column. From the master, that picks the stack row nearest its vertical
centre, not the window last swapped out. Delete the script and its tests once
upstream has the action.

**Proposal, part 1:** `window-swap-master`. From the stack, swap with the first
master; from a master, swap with the stack window focused last. Needs the
master layout to remember that window (it has no focus memory today; scrolling
has `m_lastFocusedColumn`). Reuses `MasterStackLayout::swapViews`, which
already swaps across areas.

**Part 2:** show that remembered window while a master has focus, e.g. a
`colors.border.swap_target` colour or a `match.is_swap_target` window-rule
matcher. Touches border state and rendering, so open an issue before writing it.

No upstream issue or PR found (searched 2026-11-09).

## IPC: a window's master-layout area

`umbriel windows --json` can't say whether a window is a master or in the
stack. `column` and `row` are `-1` outside the scrolling layout
(`src/server/ipc_commands.cpp`, around line 662: "Only the scrolling strip has
an order of columns and rows that holds still for clients"), and no workspace
field gives the master count. Clients infer it from geometry, which depends on
`position` and the current master fraction:

- `scripts/swap-master` guesses the swap direction from which sides have
  tiles.
- The Emacs window list (`apps/dl-umbriel-model.el` in `~/.config/emacs`,
  `dl-umbriel-model--placement`) shows a bare `tile` for every master-layout
  window.

Internally the layout knows (`src/layout/master.h`): `MasterStackLayout` holds
`m_master`, `m_stack` and, in center mode only, `m_secondStack` (the right
stack). Its `columns()` view orders the non-empty areas by screen position
(`orderedAreas()`), so a column index doesn't identify the master either.
Area membership, unlike a column index, changes only on a swap, promote or
demote, so it does hold still.

**Proposal:** a window field `area`:

| value | meaning |
|---|---|
| `"master"` | in `m_master` |
| `"stack"` | in `m_stack` (in center mode, the left stack) |
| `"stack_right"` | in `m_secondStack` (center mode only) |
| `null` | floating, or another layout |

Plus `area_row`, the window's place within its area from 0 (`-1` with a null
`area`), and a workspace field `master_count` (`m_master.views.size()`, `0`
outside master). The `windows` and `workspaces` events carry them; a change of
area already moves the window, so the `windows` event fires anyway.

Implementation: next to `column`/`row` in `ipc_commands.cpp`, through
`Workspace::masterLayout()` (needs a const overload) and a
`MasterStackLayout::areaOf(const View*)` that returns the area and row. Docs:
the window field table in `docs/user/ipc.md`. Test: an IPC harness check that
promotes, demotes and swaps across areas with `position = "center"`.

Then: `scripts/swap-master` reads `area` instead of geometry, and the Emacs
list shows `master 0` / `stack 1` / `stack_right 0` in its placement cell.

No upstream issue or PR found (searched 2026-11-09). Related: #704 (cap the
master area at N windows, swap on drop), which also turns on master-area
membership.


## 1Password in the tray crashes on launch hand-off

With its pad empty (app in tray, no window), the toggle runs `1password`; the
new process hands off to the running instance and exits, then umbriel logs
`error in client communication` for the running instance and it dies ("Fatal
Wayland communication error"). Seen once, 2026-10-31 09:23:20. Cause unknown;
possibly umbriel mishandling the launch token on a window another process
opens. Likely affects any single-instance tray app (Signal, Spotify).

**Next:** reproduce (empty the pad with 1Password in the tray, toggle, watch
`journalctl --user -u umbriel.service`), then a harness check or an upstream
issue.
