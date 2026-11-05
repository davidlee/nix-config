# IMP-063: Test/dev Postgres for satan and satan-attrd, lifted from sediment

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Satan and satan-attrd have no database in their jails (IMP-062's decision: no
DB access until the host-level design lands). For test and dev they get a
throwaway Postgres instead: a real server on a unix socket in a tmpfs root,
started and reset by a script, dying with the session.

Lift the shape from `~/dev/sediment` (`scripts/db.sh`, `scripts/db.test.sh`,
and `postgresql` in its `projectPkgs`): unix-socket-first, trust auth, `up |
down | status | reset | psql | env | url`, port and root overridable by env.
Adapt names and ports per repo (sediment uses 5434; 5433 belongs to `~/psql`).

Candidate for sharing rather than copying: the script is generic apart from its
name and port. Decide before copying a third time (the second copy is satan's).

Related: IMP-062, IMP-060.

## Outcome (2026-11-05)

Agreed sketch, no slice. Goal, as clarified by the user: tests in satan and
satan-attrd depend on nothing outside the jail, neither Supabase nor the host's
Postgres. Production PG is untouched.

Shared, not copied: `dev-db` (`dev-envs/dev-db.sh`, tested by
`dev-envs/dev-db-test.sh` as `checks.dev-db`). It sits in the consumer's
`tools`, not `agents/dev-env.nix`: that list also reaches host shells, and
`dev-db` is not a host fact. It runs the Postgres in the project's `dev-tools`.

Differences from sediment's script:

- Socket only (`listen_addresses = ''`). Jails share host loopback, where a port
  would collide and trust auth would reach every jail (RSK-001). The port only
  names the socket file, so no per-repo port is needed.
- `url` has an empty authority. sqlx refuses `postgresql://user@/db` with
  `EmptyHost`; measured against satan-attrd.
- `DEV_DB_NAME` is required and set by each project's justfile. No `PG*` in
  `devEnv`: mem.fact.satan.green-is-not-green records that a devshell `PGPORT`
  could redirect the live broker.

Projects: satan and satan-attrd default to `dev-db` and start it from `just`.
Supabase recipes, `supabase-cli` and the untracked `supabase/` directories are
gone. Sediment's `scripts/db.sh` and `db.test.sh` are deleted; it uses `dev-db`.
Satan sets `SATAN_MEMORY_TEST_DB`, so 3 grammar tests that skipped now run.
Satan-attrd also took 9 clippy fixes from Rust 1.99, on code this work did not
otherwise touch.

Evidence, each inside a dev-envs `jailed-shell` built on the working tree:

| Repo | Result |
|---|---|
| satan `just test` | 1355 passed, 0 unexpected, 15 skipped |
| satan `just check` | red: `shell-suite` only, pre-existing (ISS-026) |
| satan-attrd `just check` | green: lint, format, 114 tests |
| sediment `just check` | green: 100 tests |
| `/tmp` | `stat -f` reports tmpfs |
| dev-envs checks | stub, dev-env, dev-db, project-pins, quotient-forms pass |

The jail runs had no `JAIL_WORKSPACE_DEPS`. The 15 skips are not DB tests; the
context suite's are corpus-gated, and the rest are inferred to be, since a host
run skipped only 4. Not run: satan with its corpus bound.

Not reached: satan's and satan-attrd's own quotient forms lack `dev-db` until
IMP-064, and satan's capsule (`satan:IMP-036`) takes `dev-tools` only. After this
lands, satan-attrd's forms changed, so `just quotient-forms` and `quotient allow`
need rerunning there. In a host shell `/tmp` is on disk, so the cluster outlives
the session.
