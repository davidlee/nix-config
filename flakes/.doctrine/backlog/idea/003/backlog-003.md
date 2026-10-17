# IDE-003: Harness-agnostic credential broker for agents

Agents should not hold raw API keys at all. A broker or proxy on the host
holds credentials; the jailed agent talks to it (e.g. a local
OpenAI-compatible endpoint that injects the key upstream), and sees no
secret to leak.

- Survey existing brokers and agent proxies first, including pi-specific
  ones, before building.
- Must be harness-agnostic: pi, codex, claude, crush, opencode, … under
  `agents/jailed-agents.nix`.
- Supersedes the env-var path that IMP-020 tightens.
- Related: IDE-004 (same boundary, for git).

## Survey and direction (2026-10-16)

- **pi-model-proxy** (BlackBeltTechnology): wrong direction. It exposes pi's
  own logged-in models outward as an OpenAI/Anthropic-compatible API, so the
  pi running it holds the credentials. It's pi-only and small (4 stars).
- **pi-auth-broker** (pi.dev): shares OAuth token refresh for Anthropic and
  Codex logins. Clients still receive short-lived access tokens, and it
  doesn't cover API-key providers like DeepSeek. Not relevant.
- **LiteLLM proxy** (in nixpkgs): the chosen direction. A host-side,
  OpenAI-compatible gateway that holds the real keys and gives each client a
  revocable virtual key, limited to certain models and with its own budget
  and spend log. It supports DeepSeek and OpenRouter, and works with any
  harness.

**One system service, many clients:** jailed agents, the SATAN proposal VM
(satan IDE-007), satan-tick, gptel. Side effects: it also fixes satan ISS-023
(prompt-mode runs lost when the 1Password dialog times out; the service
unlocks once at start) and satan ISS-029 (jail keys leak through argv; budget
ceiling dropped).

Open:
- Virtual keys and spend tracking need Postgres. Prove that the nixpkgs
  package's database setup works before relying on it.
- The master key stays out of every client's reach, Emacs included.
- The satan ADR-017 authority ledger changes owner for credential resolution.
- **Serve on a unix socket, with access controlled by its file mode.**
  Required by oubliette's Plan F (`docs/plan-f-assistant.md`, oubliette
  `fb241c4`): the SATAN room reaches LiteLLM through a forwarder in its network
  namespace that connects to the socket, so nothing routes from guest to host.
  The socket's owner, group and mode are this repo's to set, and they decide
  which local clients may reach the proxy. Check that LiteLLM (or the nixpkgs
  service) can listen on a unix socket; if not, it needs a TCP-to-socket shim
  bound to loopback only.

## Spike (2026-10-17)

Against the locked nixpkgs (`f45c6f0`): litellm 1.100.1, Postgres 18.6.

- **Unix socket works.** The `litellm` CLI has no socket option, but
  `uvicorn litellm.proxy.proxy_server:app --uds <path>` with
  `CONFIG_FILE_PATH=<config>` serves the full proxy on the socket (liveness,
  `/v1/models` with the master key). No shim needed. The nixpkgs service
  hardcodes `--host/--port` in `ExecStart`, so we'd override `ExecStart`
  or write our own unit.
- **Virtual keys are blocked in nixpkgs.** They need the database, and the
  database path is broken:
  - The default `prisma migrate` path imports `litellm-proxy-extras`, which
    nixpkgs doesn't package (marked FIXME).
  - `--use_prisma_db_push` runs prisma-client-py 0.15.0, which downloads its
    Node CLI and engines at runtime. Prisma publishes none for NixOS (404),
    and the store is read-only anyway.
  - The client is not generated (`prisma/client.py` is missing), and
    `prisma generate` writes into site-packages.
  - prisma-client-py pins Prisma 5.17 engines (`393aa359`). nixpkgs has only
    `prisma-engines` 6 and 7.
  - Without a database, any key except the master key gets
    `400 No connected db`.
- **Options:**
  1. Package it properly: Prisma 5.17 engines, a client generated at build
     time, and `litellm-proxy-extras` for migrations. Substantial work.
  2. Run the upstream OCI image (it ships Prisma ready to use) under rootless
     podman or docker, bind-mounting the socket directory.
  3. No database: master key only. Isolate clients with one socket per trust
     class (file mode decides who connects), and enforce budgets upstream at
     the provider. This loses per-key spend logs and per-key revocation.
- **Postgres collation drift:** most databases were created under glibc
  collation 2.42; the OS now has 2.44. A new database copied from
  `template1` inherits the warning. Create the LiteLLM database from
  `template0` with `--locale-provider=builtin --builtin-locale=C.UTF-8`,
  which has no glibc dependency.

### Option 4: our own key store on LiteLLM's extension points (spike 2026-10-17)

No ORM. A small Python module plugs into two documented LiteLLM hooks:
`general_settings.custom_auth` (validates the bearer key) and a
`CustomLogger` callback (`async_log_success_event`, which receives
`response_cost`). The spike used stdlib `sqlite3` (keys hashed with sha256,
plus alias, models, budget and spent columns), served over `--uds` with no
database configured:

- Known key → 200; unknown key → 401; spend is recorded per key; the next
  request after the budget is spent → 401 `budget exhausted`. Prisma is
  never touched: `custom_auth` runs before the `No connected db` check.
- **The model allow-list is not enforced** by returning
  `UserAPIKeyAuth(models=…)`, even with
  `custom_auth_run_common_checks: true`. Enforce it ourselves, in the auth
  hook (read the body's `model`) or in `async_pre_call_hook`.
- The master key also goes through `custom_auth`, and was refused. Good for
  socket clients; the admin path needs its own rule.
- Budgets are checked before the call, so in-flight requests can overshoot
  (one request ran 0.0002 past a 0.00002 budget). The overshoot is bounded
  by concurrency × the cost of one request. A reservation from `max_tokens`
  would tighten it.
- LiteLLM logs each refusal with a traceback. Noisy, harmless.
- Coupling: depends on `UserAPIKeyAuth`, the `custom_auth` signature and the
  callback's kwargs (`litellm_params.metadata.user_api_key_hash`,
  `response_cost`). That is a far smaller surface to track than Prisma.

Shipped (2026-10-17): SL-011, a host-side LiteLLM gateway on Sleipnir
(`agents.gateway`) holding the provider keys, with its own SQLite key store
(per-client keys, model lists, lifetime budgets). The jailed eca holds only
its gateway key. pi follows (IMP-028); more providers: IMP-029.
