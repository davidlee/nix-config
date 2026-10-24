<!-- doctrine:section sec-1 -->
## Purpose and contract

Add a daily host-side backup of database `satan` in Oubliette room `assistant`. Connect as room login `satan` so peer authentication maps to database role `satan`. Each successful run emits two PostgreSQL 18 custom-format archives: a complete database dump (`full.dump`) and a schema-only dump (`schema.dump`).

The schedule is a Home Manager user timer at 03:00 local time with `Persistent = true`. A calendar event missed during suspend is handled after resume. `Persistent = true` separately catches up when the timer was inactive, such as while the user manager was stopped. Do not set `WakeSystem`: the machine must not be woken solely for the backup. Systemd 261 documents these semantics at https://www.freedesktop.org/software/systemd/man/261/systemd.timer.html (lines 66-67, 113-124).

The destination and retention are governed by Flakes DEC-080. Oubliette DEC-061/063/067 govern guest persistence, socket forwarding, and the out-of-band backup boundary. This is implemented in `~/flakes`; it adds no Oubliette verb or room-side schedule.
<!-- doctrine:section sec-2 -->
## Feature and unit ownership

Add a `satan.postgres-backup` Home Manager feature, register it in `features/satan.nix`, and enable it by default in `features/profiles/personal-linux.nix`. Keep it a user unit: it runs as the host account that owns the room SSH identity and the host state directory.

Use the locked room-client package `inputs.fleet.inputs.oubliette.packages.${system}.room-client-assistant` and the existing door data from `features/satan/room.nix`. The SSH identity is the room door's `malebolge-vm.key`; the bundle supplies its SSH config and strict host-key handling. The unit is a oneshot service plus a timer installed under `timers.target`, with `OnCalendar = "*-*-* 03:00:00"` and `Persistent = true`. The service must not start or wake the room automatically; an unavailable room is a failed run reported in the journal, and the next timer event retries.

Provide a manual invocation through `systemctl --user start satan-postgres-backup.service`.
<!-- doctrine:section sec-3 -->
## Connection and dump flow

Install a readable script under `features/satan/` and run it from the service. It creates a mode-0700 temporary directory under `$XDG_RUNTIME_DIR`, starts the room-client `ssh` in the background, and forwards a local Unix socket to `/run/postgresql/.s.PGSQL.5432` in the room. Connect to that local socket with `pg_isready` until ready, with a bounded timeout; also fail if the SSH process exits.

The SSH command uses the bundle config, the existing private identity by path, `BatchMode=yes`, `IdentitiesOnly=yes`, `ExitOnForwardFailure=yes`, and `satan@room-assistant`. The key contents never enter Nix output, argv or environment. Install a trap that terminates and waits for the SSH process and removes the temporary socket directory on success, failure, timeout or signal.

Run `pg_dump` from `pkgs.postgresql_18` twice with host set to the local socket directory, port 5432, username `satan`, database `satan`, and custom format. The second invocation adds `--schema-only`. No password or `.pgpass` is used: the forwarded connection is peer-authenticated as the SSH login.
<!-- doctrine:section sec-4 -->
## Output, atomicity and retention

Write to `${home}/.local/state/oubliette/backups/assistant/satan`, on the host and separate from the room-home image. Create the directory with mode 0700 and set `umask 077`. For each run, create a private temporary set directory inside the destination, write both archives there, and rename the directory to a UTC timestamped set name only after both `pg_dump` invocations succeed. This makes each published set contain both artifacts.

After publishing the new set, enumerate only completed timestamped set directories and remove the oldest until the newest 30 remain. Temporary directories do not match the completed-set name. Do not prune before both dumps complete and the new set is published. Any connection, dump, or publication failure exits nonzero, cleans temporary files and tunnel state, leaves prior sets untouched, and appears in the systemd journal.

The backups protect against loss of the room volume, not loss of the host. There is no off-host copy, cluster-global roles dump, or automated restore. A full database dump is the restore source; the schema-only archive is separate for schema inspection or restoration.
<!-- doctrine:section sec-5 -->
## Code impact

| Path | Change |
|---|---|
| `features/satan/postgres-backup.nix` | Home Manager feature, user oneshot service and persistent daily timer |
| `features/satan/postgres-backup` | Tunnel lifecycle, readiness, two dumps, atomic set publication and retention script |
| `features/satan.nix` | Register the feature |
| `features/profiles/personal-linux.nix` | Enable the feature for the host profile |
| `SATAN.md` | Explain destination, files, timer status/manual run, logs, and restore path |
<!-- doctrine:section sec-6 -->
## Verification and limits

Review the Nix unit declarations, package paths, script quoting and generated SSH command against the cited room-client and peer-auth contracts. Do not run builds, switches, tests, the unit, or live database operations as part of this change. The runbook will provide the operator checks: `systemctl --user list-timers satan-postgres-backup.timer`, `systemctl --user status satan-postgres-backup.service`, and `journalctl --user -u satan-postgres-backup.service`.

A live restore rehearsal, host-loss protection, disk-capacity planning beyond the 30-day retention, and behavior when the room is offline are not proven by source inspection. If the room is down at the timer event, the service reports failure and leaves prior sets untouched. The timer does not retry a failed service run; the operator may start the service manually, and the next calendar event is the next scheduled attempt. `Persistent = true` catches a missed timer event while the timer was inactive; it is not a retry policy for service failures.
