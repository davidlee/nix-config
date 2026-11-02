# ISS-022: snooze-nag draws the whole ladder, failing its behaviour test

`just test` is red at `features/session/snooze-nag-test` (`justfile:90`), so the
repo gate cannot go green end to end. Found 2026-11-02 while wiring SL-022's
`just test` lines; nothing in that slice touches this feature.

Observed, standalone (no `just`, no nix, no slice file involved):

```
FAIL absence: asks once
       expected: Snooze 20m
       actual:   Snooze 5m,Snooze 20m,Snooze 40m,Snooze 60m
FAIL after a suspend the ladder stays at its floor
       expected: Snooze 20m,Snooze 5m
       actual:   Snooze 5m,Snooze 20m,Snooze 40m,Snooze 60m,Snooze 5m,Snooze 20m,Snooze 40m,Snooze 60m
```

The script asks `notify-send` for the whole ladder in one prompt cycle where the
case expects one label; the reported `actual` grows by a full ladder per run, so
the per-case log is not as fresh as the harness intends (`run()` makes a fresh
`mktemp -d` and truncates the three logs, `SNOOZE_TEST_DIR` points at it).
`pa_context_connect() failed: Connection refused` also appears — the stub set may
be short of a pulse stub (unverified).

Not started; no root cause asserted beyond the reproduction above. The same
session's `git status` shows no local modification under
`flakes/features/session/`, so this is HEAD behaviour, not work in progress.

Related: SL-022 (notes § PHASE-03) — the phase's `just test` evidence stops here.
