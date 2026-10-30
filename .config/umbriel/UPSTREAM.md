# Upstream work for Umbriel

Bugs and features this config works around, to be fixed in Umbriel itself
(`~/.local/src/umbriel`, origin `noctalia-dev/umbriel`). Method: reproduce
with a harness check (`just check <name>`) on a branch, red before green; the
user raises the PR or issue. Don't run a patched umbriel day to day.

| item | status | workaround here |
|---|---|---|
| [Scratchpad relaunch takes two presses](#scratchpad-relaunch-takes-two-presses) | fix ready on a branch, not pushed | press twice |
| [Up/down focus skips tabs](#updown-focus-skips-tabs) | proposal, not started | `scripts/focus-vertical` |
| [1Password in the tray crashes on launch hand-off](#1password-in-the-tray-crashes-on-launch-hand-off) | needs a reproduction | none |

When an item lands in the pinned version (`umbriel` input in
`~/flakes/flake.lock`), remove its workaround and its entry here.

## Scratchpad relaunch takes two presses

Closing a pad's last window keeps the pad shown (by design: `empty_launch.sh`).
`ScratchpadManager::toggle` hides a shown pad before it reaches the
`spawn_when_empty` branch, so:

```
close the app (or it hides to tray)  ->  pad empty, still shown
press 1  ->  hides the empty pad, launches nothing
press 2  ->  shows the pad and launches  ->  window arrives visible
```

**Proposed PR**

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
