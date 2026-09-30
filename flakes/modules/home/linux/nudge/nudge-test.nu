#!/usr/bin/env nu
# Tests for the pure decision core. Run: nu nudge-test.nu
#
# Fixtures pin every threshold explicitly, so retuning `config` / `rules`
# in nudge.nu never breaks a test — only a change in behaviour does.

use std/assert
use nudge.nu *

const T0 = 2026-09-30T10:00:00+10:00
const JOURNAL = "/home/u/notes/journal/20260930T000000--2026-09-30-wednesday__journal.org - GNU Emacs at host"
const CFG = {idle_cap: 5min, present: 5min, hours: {from: 9, to: 22}}
const TUNING = {min_dwell: 2min, stale: 30min, repeat: 30min}

def at [offset: duration] { $T0 + $offset }

def ev [offset: duration, app: string, title: string = "-"] {
  {ts: (at $offset), app_id: $app, title: $title}
}

# One event a minute on `app` over [from, to): steady, non-idle activity.
def busy [from: duration, to: duration, app: string = "ghostty", title: string = "-"] {
  let n = (($to - $from) / 1min | math floor)
  0..<$n | each {|i| ev ($from + ($i * 1min)) $app $title }
}

def rule [name: string, --mtime: any = null] {
  rules {date: "20260930", mtime: $mtime}
  | where name == $name
  | first
  | merge $TUNING
}

# Assess `name` at offset `now`, seeing only the events that have happened.
def assess-at [name: string, events: list, now: duration, --mtime: any = null, --nudged: any = null] {
  let seen = ($events | where ts <= (at $now))
  assess (rule $name --mtime $mtime) (intervals $CFG $seen (at $now)) (at $now) $nudged
}

def "test idle gaps count only up to idle_cap" [] {
  let events = [(ev 0min ghostty) (ev 20min ghostty)]
  assert equal (active-since (intervals $CFG $events (at 21min)) null) 6min
}

def "test a tab-through is not engagement" [] {
  let events = (busy 0min 40min | append (ev 40min emacs) | append (busy 40min 45min | update ts { $in + 5sec }))
  let a = (assess-at emacs $events 45min)
  assert equal $a.engaged_at null
  assert $a.due
}

def "test a dwell is engagement" [] {
  let events = (busy 0min 20min | append (busy 20min 23min emacs) | append (busy 23min 55min))
  assert not (assess-at emacs $events 50min).due
  assert (assess-at emacs $events 55min).due
}

def "test writing the journal is engagement" [] {
  let events = (busy 0min 60min)
  assert not (assess-at journal $events 60min --mtime (at 40min)).due
  assert (assess-at journal $events 60min).due
}

def "test a journal dwell counts but another emacs buffer does not" [] {
  let journal = (busy 0min 30min | append (busy 30min 33min emacs $JOURNAL) | append (busy 33min 60min))
  let other = (busy 0min 30min | append (busy 30min 33min emacs "*scratch* - GNU Emacs") | append (busy 33min 60min))
  assert not (assess-at journal $journal 60min).due
  assert (assess-at journal $other 60min).due
}

def "test never due while already on the target" [] {
  let events = (busy 0min 60min | append (ev 60min emacs))
  assert not (assess-at emacs $events 60min).due
}

def "test repeat suppresses a recent nudge" [] {
  let events = (busy 0min 60min)
  assert not (assess-at emacs $events 60min --nudged (at 40min)).due
  assert (assess-at emacs $events 60min --nudged (at 20min)).due
}

def "test decide picks the first due rule, and only when present" [] {
  let rs = [(rule emacs) (rule journal)]
  let events = (busy 0min 60min)
  assert equal (decide $CFG $rs $events (at 60min) {}).name emacs
  assert equal (decide $CFG $rs $events (at 60min) {emacs: (at 55min)}).name journal
  assert equal (decide $CFG $rs $events (at 70min) {}) null
}

def "test decide stays quiet outside hours" [] {
  let cfg = ($CFG | merge {hours: {from: 12, to: 22}})
  assert equal (decide $cfg [(rule emacs)] (busy 0min 60min) (at 60min) {}) null
}

def main [] {
  test idle gaps count only up to idle_cap
  test a tab-through is not engagement
  test a dwell is engagement
  test writing the journal is engagement
  test a journal dwell counts but another emacs buffer does not
  test never due while already on the target
  test repeat suppresses a recent nudge
  test decide picks the first due rule, and only when present
  test decide stays quiet outside hours
  print "ok"
}
