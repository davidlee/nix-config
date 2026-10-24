# Daily host-side PostgreSQL backups for the Oubliette room

## Context

The Oubliette room's PostgreSQL cluster is persisted on its `/home` volume
(Oubliette DEC-061). Oubliette DEC-063 defines the host connection as forwarding
the guest's Unix socket over the room door, and DEC-067 records the previous
choice to keep backup operator-run and out of band. The operator has now
chosen a daily host-side systemd backup. The intake and initial sketch are
captured in IMP-040. Flakes DEC-080 settles the host destination and
30-day-retention policy for this implementation.

## Scope & Objectives

- Add a daily host-side systemd backup for the `satan` database in room
  `assistant`, authenticated as room login `satan`, using the room-client
  package and the guest PostgreSQL socket forward.
- Write both a full database dump and a separate schema-only dump each day.
- Store dated dump sets under the host user's
  `$HOME/.local/state/oubliette/backups/assistant/satan`, with mode 0700; keep
  30 daily sets and prune expired sets only after both current dumps succeed
  (DEC-080).
- Document how to inspect the schedule and restore a dump.
- Keep credentials out of the Nix store, unit environment and command logs.

## Non-Goals

- Changing PostgreSQL provisioning or Oubliette room behavior.
- Backing up the whole cluster as a superuser, or backing up databases the
  guest login cannot access.
- Remote replication, off-host storage, or changing Oubliette's operator-run
  reset/restore model.

## Summary

The destination, database, retention, and dump types are settled. The design
must specify the daily trigger and safe tunnel lifetime. A Home Manager user
service and timer is the candidate because it already has access to the host
SSH identity and host state path, independently of the guest's persisted
`/home`.

## Follow-Ups

- `pg_dump` uses PostgreSQL 18 client tools to match the room's server major.
- The room's peer authentication maps the SSH login to the same PostgreSQL
  role; logging in as `satan` and dumping database `satan` matches this rule.
