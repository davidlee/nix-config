# IMP-040: Daily host-side PostgreSQL dumps for the Oubliette room

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

## Why

The Oubliette room's PostgreSQL data persists on its room `/home` volume. A
dump kept only in the room would be lost with that volume. The room-client
bundle already provides the SSH door and forwards the guest PostgreSQL socket;
the existing connection procedure is documented in the Oubliette README.
There is no backup script or schedule today. SL-009/DEC-067 chose operator-run
backups and rejected scheduled dumps; the operator has now chosen to reopen
that design for a daily host-side dump.

## Sketch

- Add a host-side systemd unit and daily timer in `~/flakes`.
- Use the room-client SSH bundle to forward `/run/postgresql/.s.PGSQL.5432`
  from room `assistant` as room login `satan`, then run `pg_dump` for database
  `satan`.
- Produce both a full database dump and a separate schema-only dump each day.
- Write dumps to a host-local location, separate from the room volume, so
  deleting that volume does not delete the backups.
- Keep the dump procedure operator-visible and make failures visible in the
  unit journal.

The design pass must settle the exact host path, dump naming/retention, and
tunnel lifecycle. The implementation must avoid putting dumps in a directory
that is inside the room or its mounted volume.

## Scope

In scope: the daily host-side dump mechanism and the documentation needed to
operate and restore from it. Out of scope: changing Oubliette's database
provisioning, scheduling backups inside the room, and remote/off-host archival.
