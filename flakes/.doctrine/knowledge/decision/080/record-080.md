# DEC-080: Host-side Oubliette backups use 30-day retention

<!-- Knowledge record body — context, detail, links. The structured, queried
     fields live in the sister `record-NNN.toml`; this prose is free-form and is
     never structurally parsed (the storage rule). -->

## Context

Oubliette's room `assistant` stores the `satan` PostgreSQL database on its
`/home` volume. The host needs daily full and schema-only dumps as `satan`,
outside that room volume. The user confirmed a host-local destination and
retention policy while shaping SL-017.

## Decision

Write dated dump sets under the host user's
`$HOME/.local/state/oubliette/backups/assistant/satan`, with directory mode
0700. Keep 30 daily sets. Remove expired sets only after both the current
full dump and schema-only dump have completed successfully.

## Consequences

The dumps survive loss of the room's `/home` volume, but remain on this host.
The backup feature must create the destination privately and must not prune
older sets after a failed or partial run.
