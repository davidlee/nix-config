`llm-gateway` (the gateway admin CLI, features/agents/gateway/) runs its store
operations as the `llm-gateway` user through sudo itself. Invoke it bare:
`llm-gateway issue|list|revoke|budget|reset|models|credentials`.
`models ALIAS M,…` replaces a key's model list in place (DEC-071).

Under `sudo llm-gateway issue … --out FILE`, the `--out` write runs as root, so
FILE is `root:root 0600` and a jail's wrapper reports "gateway key … is missing,
empty or unreadable". Fix: `sudo chown "$USER":users FILE`. ISS-015 tracks
making the CLI refuse or chown.

From the agent's side, sudo needs a password; ask the user to run admin
commands in their own terminal. `issue --out <scratch file>` lets the agent
use a probe key without the user pasting it.

Key rotation of a client key is a new alias (a revoked alias is never reissued,
DEC-051): move the old file aside, `issue <alias>-N --out <same path>`, revoke.

`list` prints spend to 4 dp: a short probe request (~1e-6 USD) shows 0.0000.
Check the `x-litellm-response-cost` response header, or probe with ~1k tokens.

The CLI on PATH is the current system generation's build, with PROVIDERS and
MODELS baked in. A new provider's credentials must be written with the NEW
build before switching (`just system-build`, then
`./result/sw/bin/llm-gateway credentials <provider>…`, then `system-switch`);
the PATH CLI refuses unknown providers (DEC-067, README § Adding a provider).
