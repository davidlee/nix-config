#!/usr/bin/env nu

export def ws [n?: string] {
  match $n {
    null => {
      let o = gum choose ...(^niri msg workspaces | split row "\n")
      let w = $o | ^cut -c '1,2,3,4' | ^tr -d ' '
      ^niri msg action focus-workspace $w
    }
    _ => {
      ^niri msg action focus-workspace $n
    }
  }
}

export alias pw = ^niri msg pick-window
export alias sw = ^niri msg action set-workspace-name
export alias usw = ^niri msg action unset-workspace-name

# completions
export def __niri_msg_cmp [context: string] {
  let ctx = $context | split words | str join ' '
  match ($ctx | split words | str join ' ') {
    'niri msg action' => (^niri msg action -h | grep -E '^  \w' | split row "\n" | str trim)
    'niri msg' => (^niri msg -j e>| grep '\[subcommands:' | str replace --regex '\[subcommands:' '' | split words)
    'niri' => ["msg"]
    _ => [$ctx]
  }
}

export extern "niri" [...cmd: string@__niri_msg_cmp] {
  # print $cmd
}


export def __cmp [ctx: string] {
  let context = $ctx | split words | str join ' '
  match ($context) {
    'pie' => ["x", "a"]
    'pie x' => ["y", "b"]
    'pie x y' => ["z"]
    _ => [$context]
  }
}

export extern "pie" [...cmd: string@__cmp] {
  # print $cmd
}
