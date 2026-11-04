# IMP-062: Per-project DB jail: host-defined Postgres mounts passed into an extra pi jail

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Satan, satan-attrd and malebolge each want an *extra* pi jail with database
access, besides the default one, which has none. The dev-envs consumer
(flakes:SL-022) cannot express it: the old per-repo jails set
`exposePostgres = true` (a read-write bind of `/run/postgresql`) and forwarded
`DATABASE_URL`, per repo.

Intent: define the Postgres mounts and env once, at host level in flakes, and
have a project opt in to the extra jail by name. A project states no bind
itself.

Open: the opt-in surface (a `devEnv` key, or a consumer output); the jail's
name; whether forms get it too. Docker is out of scope: no jail gets the Docker
socket (the user's decision, 2026-11-04).

Context: IMP-060 (migration to dev-envs). Satan-attrd and satan stay off
dev-envs' DB access until this lands; they migrate with no DB access first.
Blocks nothing else. Related: IMP-063.
