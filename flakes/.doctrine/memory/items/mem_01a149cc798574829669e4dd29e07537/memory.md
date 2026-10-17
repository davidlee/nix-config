`llm-gateway` (the gateway admin CLI, features/agents/gateway/) runs its store
operations as the `llm-gateway` user through sudo itself. Invoke it bare:
`llm-gateway issue|list|revoke|budget|reset|credentials`.

Under `sudo llm-gateway issue … --out FILE`, the `--out` write runs as root, so
FILE is `root:root 0600` and a jail's wrapper reports "gateway key … is missing,
empty or unreadable". Fix: `sudo chown "$USER":users FILE`. ISS-015 tracks
making the CLI refuse or chown.

From the agent's side, `sudo` from a `!` shell has no TTY and fails; ask the
user to run admin commands in their own terminal.

Key rotation of a client key is a new alias (a revoked alias is never reissued,
DEC-051): move the old file aside, `issue <alias>-N --out <same path>`, revoke.
