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

## Resolution (fixed, 2026-11-03)

**Root cause — a commit, not the test.** `17991b29` ("abortive start on tangled;
add smut", 2026-11-01) swept an unrelated in-progress experiment into its diff:
`flakes/features/session/snooze-nag` was replaced by an alternate implementation
— a static four-button ladder (`5/20/40/60` every prompt), `sleep`-based timers
instead of `timeout` for the absence window, and `systemctl suspend` gated on a
successful spoken warning. Neither the test nor `README § Snooze (bedtime
ratchet)` changed, so the script and its spec disagreed.

Two claims in the body above are wrong:

- **Log freshness is fine.** `run()` truncates as documented. The eight labels
  were two prompt cycles × four buttons; the growth was the bug, not stale logs.
- **No stub was missing for the *old* script.** The pulse noise came from the
  swept-in script calling `pactl`/`say`. The stub set *was* short for the new
  one, which is why `pactl` and `say` stubs were added with the fix.

**Fix.** Restored the ladder loop from `17991b29^` and folded the spoken warning
into it as a non-gating nicety: `warn()` returns quietly when `say`/`pactl` are
absent, when the configured sink is missing or muted, or when the voice errors;
it is spoken in the background across the prompt's window and reaped before the
decision, so it never delays or decides anything. The ladder, the absence window
and the night window are unchanged.

**Evidence.** `./features/session/snooze-nag-test` → 16 ok, 0 failed, ~2.4s;
`shellcheck` clean on both files. No `.nix` file changed, so the rest of
`just test`'s builds are untouched by this fix.

**Reconciled.** `README § Snooze` gained the fourth property ("The warning is
never a gate") and the diagram and sink wording that go with it. `features/
session.nix`'s comment already described the spoken warning, correctly; no
change needed.
