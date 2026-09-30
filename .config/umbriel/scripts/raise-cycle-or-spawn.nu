#!/usr/bin/env nu
# Focus the next window with this app ID, or launch the command if none exists.
# Usage: raise-cycle-or-spawn.nu <app-id> <command> [args...]
#
# Nushell parses script arguments. For example, it changes a trailing
# `--alternate-editor=` into `--alternate-editor=""` before this script sees it.

def --wrapped main [app_id: string, ...command: string] {
    if ($app_id | is-empty) or ($command | is-empty) {
        print --stderr 'usage: raise-cycle-or-spawn.nu <app-id> <command> [args...]'
        exit 2
    }

    let windows = (umbriel windows --json | from json)
    let matches = ($windows | where app_id == $app_id)

    if ($matches | is-empty) {
        run-external ...$command
        return
    }

    # `focused` can be true on several workspaces; `active` is keyboard focus.
    let active_index = (
        $matches
        | enumerate
        | where item.active
        | get -o 0.index
        | default (-1)
    )
    let next_index = (($active_index + 1) mod ($matches | length))
    let next_window = ($matches | get $next_index)

    umbriel msg $"window-focus:($next_window.id)"
}
