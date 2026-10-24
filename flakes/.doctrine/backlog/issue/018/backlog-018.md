# ISS-018: sleipnir-doctor missed six days of dead Firefox capture

Firefox capture stopped 2026-10-18 23:26 and stayed dead until 2026-10-25. The
panopticon native-messaging manifest
(`~/.mozilla/native-messaging-hosts/panopticon_firefox.json`) named a
`/nix/store` path that GC had deleted, so Firefox could not start the host.
Cause and installer fix: panopticon `d7cd5e4` (the installer followed the
`~/.nix-profile` symlink into the store).

The doctor did not make it noticeable:

- no check of the manifest — only downstream symptoms (raw freshness,
  yesterday's segments);
- the panopticon provider emitted only OK/WARN, so six dead days read like a
  two-hour lag;
- WARN (terminal yellow) and CRIT (orange) look alike where the theme renders
  yellow as orange;
- `--problems` existed but nothing listed it (no `--help`; unknown flags were
  ignored);
- the login hook ran once per login session — once in a multi-day session —
  and only from nushell.

## Resolution (2026-10-25)

- Provider check `firefox host manifest`: CRIT when the manifest or its host
  binary is missing; WARN when the host path is in `/nix/store` (GC will break
  it). Replayed against last week's manifest: CRIT.
- Raw freshness reads the newest raw file of any date (replaces the
  local/UTC `freshest_today` dance) and escalates to CRIT when a feed with
  `crit_minutes` (Firefox: 24 h) is silent while its app runs and the desktop
  is fresh. An idle machine still stays WARN.
- CRIT renders as a bold red `✖` with a bold red name; the summary's crit
  count is red.
- CLI via argparse: `sleipnir-doctor [all|warn|crit] [--daily]`, `-h`;
  unknown arguments exit 2. `--problems` removed (its one caller, the nushell
  hook, now passes `warn`).
- `--daily`: at most once a day, stamp in
  `$XDG_STATE_HOME/sleipnir-doctor/last-daily`. Login hooks in
  `~/nushell/config.nu` (`motd`) and `~/.config/zsh/login.zsh` both run
  `sleipnir-doctor warn --daily`.
- Tests: `hosts/Sleipnir/doctor/doctor-test` (Levels, Daily, Manifest,
  Freshness escalation).
