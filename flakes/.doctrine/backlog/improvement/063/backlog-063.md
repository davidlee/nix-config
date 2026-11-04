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
