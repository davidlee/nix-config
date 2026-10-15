Anything that mints an id (knowledge records via design dispositions, backlog
new, review passes on entering `reviewing`, memories) first fetches
`refs/doctrine/reservation/*` from `origin` over SSH. In a session with no SSH
agent this fails ("Permission denied (publickey)") and the command refuses.
Single-author repo: prefix the command with `DOCTRINE_RESERVATION_FALLBACK=1`
to allocate locally. A per-command env var, not `[reservation]
allow-local-fallback` in doctrine.toml (a config change is the user's call).

**Hang variant (2026-10-15).** When github.com:22 times out instead of
refusing, the fetch blocks (no ConnectTimeout), and the fallback never
triggers. A "banner exchange" timeout is a hard error, not a degradation.
What worked: also pass
`GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=8 -o HostName=ssh.github.com -o Port=443"`
and `< /dev/null`. Port 443 is reachable, and the fetch fails fast
(host key not trusted for ssh.github.com), which doctrine does treat as
"unreachable", so it degrades to local.
