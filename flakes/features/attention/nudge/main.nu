#!/usr/bin/env nu
# nudge — timer entry point: gather inputs, decide, notify, act on click.
# The rules and every threshold live in nudge.nu.
#
#   nu main.nu            decide, and nudge if a rule is due
#   nu main.nu --explain  show each rule's assessment; never notifies

use nudge.nu *

const STATE = "~/.local/state/nudge/last.json"

# Today's panopticon window events, oldest first.
def events [now: datetime] {
  let raw = ($"~/.local/state/behaviour/raw/desktop-($now | format date '%Y-%m-%d').jsonl" | path expand)
  if not ($raw | path exists) { return [] }
  open --raw $raw
  | from json --objects
  | where event in [window_focus window_title]
  | each {|e| {ts: ($e.ts | into datetime), app_id: ($e.app_id? | default ""), title: ($e.title? | default "")} }
}

def journal [now: datetime] {
  let date = ($now | format date "%Y%m%d")
  let file = (glob ($"~/notes/journal/($date)T000000--*__journal.org" | path expand) | get -o 0)
  {date: $date, mtime: (if $file == null { null } else { ls $file | get 0.modified })}
}

# Rule name → when it last nudged.
def nudged [] {
  let path = ($STATE | path expand)
  if ($path | path exists) { open $path | update cells { into datetime } } else { {} }
}

def remember-nudge [nudged: record, name: string, now: datetime] {
  let path = ($STATE | path expand)
  mkdir ($path | path dirname)
  $nudged | upsert $name $now | to json | save --force $path
}

def main [--explain] {
  let now = (date now)
  let events = (events $now)
  let rules = (rules (journal $now))
  let nudged = (nudged)

  if $explain {
    let iv = (intervals $config $events $now)
    print {in_hours: (in-hours $config $now), present: (present $config $events $now)}
    print (
      $rules
      | each {|r| assess $r $iv $now ($nudged | get -o $r.name) }
      | update active {|a| $a.active - ($a.active mod 1sec) }
      | table --expand
    )
    return
  }

  let rule = (decide $config $rules $events $now $nudged)
  if $rule == null { return }

  # Recorded before notifying: a dismissed nudge still waits out `repeat`.
  remember-nudge $nudged $rule.name $now
  let choice = (
    notify-send --app-name nudge --expire-time 120000 --action $"open=($rule.button)" $rule.summary $rule.body
    | str trim
  )
  if $choice == "open" {
    for action in $rule.actions {
      run-external ($action.0 | path expand) ...($action | skip 1)
    }
  }
}
