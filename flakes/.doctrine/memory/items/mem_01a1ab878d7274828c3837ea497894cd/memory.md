Observed 2026-11-05 in real jails (SL-024 PHASE-04), claude 2.1.310, codex 0.163.0.

- `claude --mcp-config=<f> mcp list` and `mcp get` do not see `<f>`'s servers. To see a dynamic server, read the init message: `claude -p x --output-format=stream-json --verbose --max-turns 1`, `.mcp_servers[]` with `source: "dynamic"`. It appears with no login and no model call.
- `--mcp-config` beats a project `.mcp.json` entry of the same name.
- `codex exec` prints no MCP startup line, also with `--json`. To prove a server starts: `-c mcp_servers.<name>.required=true`; a server that fails stops with `required MCP servers failed to initialize`.
