Observed 2026-11-05 in a real jailed-shell (SL-024 probes), quotient 0.6.1, claude 2.1.310, codex 0.163.0.

- A jail has no `/nix/var/nix/db`. jail.nix's `runtime-deep-ro-bind` binds a link's store target through `nix-store --query --requisites`, so in a nested form it binds nothing. The form's stderr logs `path … is not valid`, and those paths really are missing: `nss-cacert`, its `-p11kit`, `hosts`, `etc-nsswitch.conf`. Direct TLS fails with `curl: (60)`, while the same curl in the jail works. Gateway calls are plain HTTP on loopback, so they hide this.
- codex passes an MCP stdio child only a filtered environment (`HOME`, `PATH`, …). `LLM_GATEWAY_KEY` arrives only when `mcp_servers.<name>.env_vars` names it. claude passes the environment through.
- claude's `--mcp-config <configs...>` is variadic: it swallows the words after it, a prompt or `mcp list`. Use `--mcp-config=<path>`.
- `JAIL_WORKSPACE_DEPS` is read at evaluation (impure), not at launch: setting it on a built jail mounts nothing.
- Binding only `policy.json` under `~/.config/quotient` leaves that directory writable in the persisted home, so an agent could plant `approvals.json`. Bind a read-only directory.
