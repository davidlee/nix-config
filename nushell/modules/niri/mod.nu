#!/usr/bin/env nu

export def ws [n?: string] {
  match $n {
    null => {
      let o = gum choose ...(^niri msg workspaces | split row "\n")
      let w = $o | ^cut -c '1,2,3,4' | ^tr -d ' '
      niri msg action focus-workspace $w
    }
    _ => {
      niri msg action focus-workspace $n
    }
  }
}

export alias pw = ^niri msg pick-window
export alias sw = ^niri msg action set-workspace-name
export alias usw = ^niri msg action unset-workspace-name
