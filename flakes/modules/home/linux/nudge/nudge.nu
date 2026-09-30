# nudge — decide whether to nudge toward Emacs (or the journal).
#
# Pure: every input arrives as an argument, so the rules are testable
# against hand-written event fixtures (nudge-test.nu). I/O lives in main.nu.
#
# Model: panopticon window events → intervals of activity (a gap longer
# than idle_cap counts as idle). A rule's target is engaged by a dwell of
# at least min_dwell (tab-throughs don't count) or by its reset_at signal
# (e.g. the journal's mtime). A rule is due once active time since that
# engagement reaches stale.

# Global gates. Per-rule thresholds live in `rules`.
export const config = {
  idle_cap: 5min # a gap between events longer than this is idle
  present: 5min # stay quiet unless the last event is this recent
  hours: {from: 9, to: 22} # local hours [from, to) in which to nudge
}

const RAISE_EMACS = [~/.config/umbriel/scripts/raise-cycle-or-spawn emacs emacsclient -n -c]

# Rules in priority order: a run sends at most one nudge, the first due.
# `journal` is {date: YYYYMMDD, mtime: datetime|null} for today's journal.
export def rules [journal: record] {
  [
    {
      name: emacs
      matches: {|i| $i.app_id == "emacs" }
      reset_at: null
      min_dwell: 2min
      stale: 30min
      repeat: 30min
      summary: "Emacs?"
      body: "You haven't spent time in Emacs for a while."
      button: "Open Emacs"
      actions: [$RAISE_EMACS]
    }
    {
      name: journal
      matches: {|i| $i.app_id == "emacs" and ($i.title | str contains $"journal/($journal.date)T") }
      reset_at: $journal.mtime
      min_dwell: 1min
      stale: 45min
      repeat: 45min
      summary: "Journal?"
      body: "Log a line in today's journal."
      button: "Quick capture"
      actions: [$RAISE_EMACS [emacsclient -n -e "(my/journal-quick-capture)"]]
    }
  ]
}

# Events (sorted by ts) → [{start end app_id title}]; each runs to the next
# event or `now`, capped at idle_cap.
export def intervals [cfg: record, events: list, now: datetime] {
  let ends = ($events | skip 1 | get ts | append $now)
  $events | zip $ends | each {|p|
    let start = $p.0.ts
    {
      start: $start
      end: ([$p.1 ($start + $cfg.idle_cap)] | math min)
      app_id: $p.0.app_id
      title: $p.0.title
    }
  }
}

# Merge contiguous intervals satisfying `matches` → [{start end}].
export def dwells [intervals: list, matches: closure] {
  $intervals | reduce --fold [] {|i, acc|
    if not (do $matches $i) { return $acc }
    let prev = ($acc | last 1 | get -o 0)
    if $prev != null and $prev.end == $i.start {
      $acc | drop 1 | append {start: $prev.start, end: $i.end}
    } else {
      $acc | append {start: $i.start, end: $i.end}
    }
  }
}

# Latest engagement with the rule's target, or null if none today.
export def engaged-at [intervals: list, rule: record] {
  let dwelt = (
    dwells $intervals $rule.matches
    | where {|d| ($d.end - $d.start) >= $rule.min_dwell }
    | get end
  )
  let candidates = ($dwelt | append $rule.reset_at | compact)
  if ($candidates | is-empty) { null } else { $candidates | math max }
}

# Active time after `since` (all of it when since is null).
export def active-since [intervals: list, since: any] {
  $intervals | reduce --fold 0sec {|i, total|
    let start = if $since == null { $i.start } else { [$i.start $since] | math max }
    $total + ([($i.end - $start) 0sec] | math max)
  }
}

# One rule's view of the moment: {name current engaged_at active due}.
export def assess [rule: record, intervals: list, now: datetime, nudged_at: any] {
  let last = ($intervals | last 1 | get -o 0)
  let current = $last != null and (do $rule.matches $last)
  let engaged_at = (engaged-at $intervals $rule)
  let active = (active-since $intervals $engaged_at)
  let rested = $nudged_at == null or ($now - $nudged_at) >= $rule.repeat
  {
    name: $rule.name
    current: $current
    engaged_at: $engaged_at
    active: $active
    due: (not $current and $rested and $active >= $rule.stale)
  }
}

export def in-hours [cfg: record, now: datetime] {
  let hour = ($now | format date "%H" | into int)
  $hour >= $cfg.hours.from and $hour < $cfg.hours.to
}

export def present [cfg: record, events: list, now: datetime] {
  let last = ($events | last 1 | get -o 0)
  $last != null and ($now - $last.ts) < $cfg.present
}

# The rule to nudge for now, or null. `nudged` maps rule name → last nudge.
export def decide [cfg: record, rules: list, events: list, now: datetime, nudged: record] {
  if not ((in-hours $cfg $now) and (present $cfg $events $now)) { return null }
  let iv = (intervals $cfg $events $now)
  $rules
  | where {|r| (assess $r $iv $now ($nudged | get -o $r.name)).due }
  | get -o 0
}
