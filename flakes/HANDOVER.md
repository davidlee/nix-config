# Handover — panopticon rough edges (post SL-004 watcher migration)

Context for a fresh agent. You are in `~/flakes` (home-manager config, part of the
`$HOME` sparse git repo at `~/.git`) with host access to Sleipnir. Compositor is
**niri**. Apply changes with `just home-switch` (= `home-manager switch --flake '.#david'`).

## What already happened (do not redo)

SL-004 migrated panopticon from a Sway-only watcher to a compositor-neutral
`panopticon-desktop` (auto-detects sway|niri, writes `source="desktop"`). The host
now runs it correctly:

- The `panopticon-sway.service` **unit name is a deliberately retained stable alias**
  (design D4). Its `ExecStart` runs `panopticon-desktop` via `lib.getExe`. **Do not
  rename the unit or change the ExecStart.**
- A prior diagnosis found the watcher had been running a stale in-memory unit def
  (old `panopticon-sway` binary) because a `systemctl --user daemon-reload` was
  missed after the Nix store symlink flipped (Nix store files carry a 1970 mtime, so
  systemd's `NeedDaemonReload` check never noticed). Fixed live via reload+restart.
  `raw/desktop-*.jsonl` + `current/desktop.json` are now live and fresh;
  `raw/sway-*.jsonl` is frozen by design.
- `modules/home/linux/behaviour.nix` header comments / smoke / Description were
  reframed for the desktop watcher — commit `971282ef`
  (`doc(SL-004): reframe panopticon HM unit …`). Comments/framing only.

### Gated — do NOT touch (held by David)
- The `current/sway.json` compat side-write, and any watcher retirement. Later step.
  Point smoke/docs at `desktop.json`, never re-introduce `sway.json`.

## Step 0 — confirm the build is green first

There is a pre-existing `television` collision unrelated to panopticon: two `tv`
binaries land in the `home.packages` buildEnv —
`programs.television` (`modules/home/shared/nushell.nix:63`, ships
`television-wrapped`) **and** bare `pkgs.television`
(`modules/shared/cli/_packages/find.nix:5`). David is resolving this himself; it may
already be fixed. Before doing anything below, confirm:

```bash
cd ~/flakes && home-manager build --flake .#david   # must succeed
```

If it still fails on the `tv` conflict, drop `television` from `find.nix`
(the HM module already provides it) — or check with David — then proceed.

## The work, prioritized

### T1 (P0) — segmentize timer is dead; focus/browser pipeline stale 6 days

**Symptom.** `panopticon-segmentize.service` last ran **Jul 14 21:58** (old user-mgr
session, PID 2221). Consequences on disk:
- `segments/focus-2026-07-{12,13,14}.jsonl` are **0 bytes**, none after Jul 14.
- `segments/browser-*` and `histograms/daily-*` all frozen at Jul 14 21:58.
- No `focus-2026-07-20.jsonl` today, despite `raw/desktop` being live.

**Root cause.** Both panopticon timers show `NEXT: -`, `Trigger: n/a`
(`systemctl --user list-timers 'panopticon*' --all`). They use `OnBootSec` +
`OnUnitActiveSec` with **no `OnCalendar`** (see `behaviour.nix` timer blocks, lines
~54–88). The `OnUnitActiveSec` anchor is the service's last-active time; it went
stale across the Jul 14→17 user-session change and never rescheduled. `Persistent=true`
did not save it — nothing re-armed the interval, so the timer sits `elapsed` forever
with no next elapse.

This matters: the SATAN focus sensor (the `panopticon-segmentize` comment in
`behaviour.nix` references P1–P4 predicates gating on `sensor_status :focus = ok`)
has had no fresh segments for days.

**The segmentizer code itself is fine** — `~/dev/panopticon`
`panopticon/segmentizer/__main__.py` `_SOURCES` (l41–42) globs **both**
`raw/desktop-*` and `raw/sway-*` → `segments/focus-*`. So once the timer fires,
today's focus segment derives correctly from the live `raw/desktop`. No code change
needed there.

**Fix.**
1. Immediate unblock (host op): `systemctl --user start panopticon-segmentize.service`
   once to re-anchor, then confirm `segments/focus-$(date +%F).jsonl` appears and is
   non-empty, and `histograms/daily-$(date +%F).json` is fresh.
2. Durable fix (the real deliverable): make the timers session-change-proof. Add an
   `OnCalendar=` (e.g. `*:0/10` for the 10-min segmentize, an appropriate cadence for
   git) to **both** `panopticon-segmentize.timer` and `panopticon-git.timer` in
   `behaviour.nix`, so a user-manager restart can't strand them. Keep `Persistent=true`.
   Consider `AccuracySec` to avoid tight wakeups. `home-switch`, then re-check
   `list-timers` shows a real `NEXT`.

Note: `panopticon-git.timer` is in the same stranded state (`NEXT -`), yet
`segments/git-2026-07-20.jsonl` is fresh today — the git poller has another write
path. Still give its timer the same `OnCalendar` treatment; don't assume it's healthy
just because git segments look current.

### T2 (P1) — sleipnir-doctor-panopticon: repoint + close blind spots

File: `modules/home/linux/bin/sleipnir-doctor-panopticon`. There is already a backlog
entry in `~/flakes/TODO.md` (`## Repoint sleipnir-doctor-panopticon: sway → desktop`)
— fold these into it.

1. **`SOURCES` repoint** (l23). Replace the `"sway"` key with `"desktop"`. Keep
   `warn_minutes: 30` and `prefix: "focus"`. IMPORTANT: the dict conflates two
   namespaces — the **key** is the raw filename stem (used by `freshest_today`, l67:
   reads `raw/<key>-*.jsonl`) and **`value.prefix`** is the segment stem (used by
   `check_segments`, l119: reads `segments/<prefix>-*.jsonl`). Segments are named
   `focus-*` (verified), so `prefix` stays `focus`; only the raw stem moves
   `sway`→`desktop`.
2. **`sway_fresh` gate** (l89, 92, 104–105) and its `"(sway also stale)"` label —
   rename to `desktop_fresh` / repoint. It's the "is the machine even in use" signal;
   keep the semantics, just point at the primary compositor source.
3. **Journal check blind spot** (`check_sway_journal`, l156). It greps only
   `"ERROR"`/`"error"`/`"reconnect"`. The real watcher-death we just fixed logged
   `WARNING … sway disconnected: Failed to retrieve the i3 or sway IPC socket path` —
   matched none of those, so the check reported `clean`/OK through a total outage
   while raw-freshness and service-active also read green. Add the actual failure
   vocabulary (`disconnect`, `Failed to`, and count `WARNING` lines) so a
   connected-but-broken watcher trips a WARN. Keep the journalctl target
   `--user-unit=panopticon-sway.service` (retained alias). Relabel the user-facing
   `"sway journal"` string only if it now misleads.
4. **Coverage gaps** (neither prior agent flagged):
   - `check_services` (l74) monitors only `panopticon-sway.service` +
     `panopticon-segmentize.timer`. Add `panopticon-git.timer` (and arguably the
     `.service`s) so a dead git sensor isn't silent.
   - `check_segments` (l118) iterates `SOURCES` only (focus+browser). `git-*` segments
     exist and are unchecked — add a git segment/freshness check if it's meant to be
     monitored.

After editing, dry-run the script to confirm valid JSON:
`python3 modules/home/linux/bin/sleipnir-doctor-panopticon | python3 -m json.tool`,
then `home-switch` and run `sleipnir-doctor` to see it render.

## Invariants (do not violate)

- Unit **name** `panopticon-sway` stays (D4). ExecStart stays `${lib.getExe panopticon}`.
- Do not touch `current/sway.json` side-write or retire any watcher — gated by David.
- Do not fold the `television` fix into panopticon commits — separate concern (Step 0).
- `git add ~/flakes/` scoped commits; conventional messages (`fix(SL-004): …` /
  `chore: …`). Never `git stash` (this is the `$HOME` repo).

## Verify (definition of done)

- `systemctl --user list-timers 'panopticon*'` shows a concrete `NEXT` for both timers.
- `ls -l ~/.local/state/behaviour/segments/focus-$(date +%F).jsonl` — present, non-empty;
  `histograms/daily-$(date +%F).json` — fresh.
- `sleipnir-doctor` (or the raw script piped through `json.tool`) shows a `desktop`
  freshness row (not `sway`), git coverage, and a journal check that would WARN on a
  disconnected watcher.
- `home-manager build --flake .#david` green; changes committed.

## Evidence / refs

- Watcher fix + framing commit: `971282ef` in `~/flakes`.
- Storage layout: `~/.local/state/behaviour/{raw,segments,histograms,current}`.
  Raw stems: `desktop-*` (live), `sway-*` (frozen), `firefox-*`; segment prefixes:
  `focus`, `browser`, `git`.
- panopticon source: `~/dev/panopticon` (path: flake input, HEAD 7cac9e2, v0.2.1).
- Existing backlog: `~/flakes/TODO.md`.
