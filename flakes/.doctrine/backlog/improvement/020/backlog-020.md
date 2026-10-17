# IMP-020: Least-privilege API keys for jailed agents

POL-001 rule 4. `agents/jailed-agents.nix` defaults `apiKeys` to every key in
`apiKeyOpRefs` (7 providers), so each jail's environment holds all of them,
and so does every child process (npm postinstall, builds, MCP servers,
subagents). One `env` dump in any agent sends every provider's key to that
agent's provider and into its transcript (IDE-005).

- Default `apiKeys = []`; each jail (and each consumer flake) names only the
  keys its agent's provider uses.
- `op run --no-masking` stays (masking corrupts streamed TUI output); this
  item is the compensating control.
- Fix README drift: `agents/README.md` §"Secrets via 1Password" step 5 and
  §`passApiKeysFromEnv` still describe `--setenv NAME "$NAME"` argv
  forwarding — the `/proc/<pid>/cmdline` leak the code fixed on 2026-08-11
  (keys now travel over `--args FD`).

Interim step; IDE-003 removes raw keys from agents altogether.

2026-10-17 (SL-011): the jailed eca no longer receives provider keys; it runs
in gateway mode with a single gateway key. Other jails still get their keys
through `op run`; pi is next (IMP-028).
