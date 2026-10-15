Anything that mints an id (knowledge records via design dispositions, backlog
new, review passes on entering `reviewing`, memories) first fetches
`refs/doctrine/reservation/*` from `origin` over SSH. In a session with no SSH
agent this fails ("Permission denied (publickey)") and the command refuses.
Single-author repo: prefix the command with `DOCTRINE_RESERVATION_FALLBACK=1`
to allocate locally. A per-command env var, not `[reservation]
allow-local-fallback` in doctrine.toml (a config change is the user's call).
