# ISS-002: sleipnir-doctor-panopticon checks the retired sway source

From TODO.md. `modules/home/linux/bin/sleipnir-doctor-panopticon` keys freshness off the retired `sway` source; `panopticon-desktop` writes `raw/desktop-*.jsonl` and `current/desktop.json`. The doctor false-WARNs and never observes the real producer.

Repoint `SOURCES` to `desktop`, rename the `sway_fresh` gate, keep the journal unit name `panopticon-sway.service` (a retained alias). Full notes in TODO.md.

## Resolution (2026-10-19)

The freshness repoint had already landed (`SOURCES` keys `desktop`). Finished
here, with scope widened by the user:

- Unit renamed `panopticon-sway` → `panopticon-desktop`
  (`features/attention/behaviour.nix`), overriding SL-004 D4's retained alias.
  The doctor and `SATAN.md` follow. Not renamed: satan's remediation hints
  (`~/dev/satan/satan/satan-sensor-alerts.el:106,109`, fixtures) and the
  panopticon repo's README / `systemd/sway-watcher.service` — other repos.
- Watcher journal: a disconnect followed by systemd stopping the unit is the
  session ending (logout, or umbriel crashing on 2026-10-18 22:54), not a
  watcher fault (`journal_verdict`).
- New doctor check `Crashes (24h)` from `coredumpctl`; resource-limit kills
  (SIGXFSZ from jailed git) are counted but do not warn.
- `sleipnir-doctor --problems`, run once per login session from the nushell
  `motd` (stamp in `$XDG_RUNTIME_DIR`).
- Tests: `hosts/Sleipnir/doctor/doctor-test`, in `just test`; each behaviour
  mutation-checked. TODO.md section removed.
- Login noise pruned (7 warnings → 2 real ones): zombies warn from 10;
  `swayidle` dropped from the daemon list (nothing runs it under umbriel);
  git dirty/ahead is OK with detail; raw/firefox is OK while Firefox is not
  running; satan's `browser=missing` no longer warns (panopticon owns that
  feed). roam-db now warns only when notes are newer than the db (in
  `~/.config/emacs`, `lisp/dl-sleipnir-doctor.el`, with ERT tests).
