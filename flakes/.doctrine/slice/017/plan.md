# Implementation Plan SL-017: Daily host-side PostgreSQL backups for the Oubliette room

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML. Use this for the plan's rationale and sequencing.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

One phase adds the backup feature, its script, profile selection, and the
operator runbook together. The timer and script are not useful independently:
the profile must install both the service and its dependencies, and the
runbook must describe the exact shipped paths and controls.

## Sequencing & Rationale

No phase split is useful for this small change. The feature module owns the
user service and timer; the script owns the temporary SSH tunnel, two dumps,
atomic publication, and retention; `SATAN.md` describes operating the result.
The profile selects the feature for the existing personal Linux host.

Verification is limited to source review in this phase. No build, test,
activation, service run, or live database operation will be performed by the
agent. The user has a separate copy-paste command for an immediate manual
dump.

## Notes

- The service does not start the room. If the room is unavailable, the run
  fails visibly and prior complete backup sets remain untouched.
- The timer catches a missed calendar event after resume without waking the
  machine. `Persistent=true` also covers periods when the user timer was
  inactive.
- Retention keeps the 30 newest complete sets, not arbitrary partial output.
