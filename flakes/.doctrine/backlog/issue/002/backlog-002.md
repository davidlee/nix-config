# ISS-002: sleipnir-doctor-panopticon checks the retired sway source

From TODO.md. `modules/home/linux/bin/sleipnir-doctor-panopticon` keys freshness off the retired `sway` source; `panopticon-desktop` writes `raw/desktop-*.jsonl` and `current/desktop.json`. The doctor false-WARNs and never observes the real producer.

Repoint `SOURCES` to `desktop`, rename the `sway_fresh` gate, keep the journal unit name `panopticon-sway.service` (a retained alias). Full notes in TODO.md.
