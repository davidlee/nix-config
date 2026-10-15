# ISS-009: Historical credential leaks in public git history

Found 2026-10-16 by a redacted gitleaks scan of the `~` repo history. Both
files are untracked now, but the commits are on the remote.

| what | path | commits | remediation |
|---|---|---|---|
| Claude OAuth access + refresh token | `.claude/.credentials.json` | `59fb21de`, `9dd6af2b`, `0425ec1e`, `6c161492` (2025-07-29..31) | user had already signed out of all sessions and rotated keys |
| Taskwarrior `sync.encryption_secret` | `.config/task/taskrc` | `18a8187d`, `5bb3d1b6`, `0177574c`, `26882bd0` (2025-03-18..31) | inert: taskwarrior sync is long dead |

Both are revoked or inert (POL-001 rule 6). History rewrite not pursued.
