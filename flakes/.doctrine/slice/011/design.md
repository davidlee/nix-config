<!-- doctrine:section sec-1 -->
## Shape

A host-side LiteLLM service, `llm-gateway`, holds the provider keys. Jailed
agents hold only a gateway key of their own, which is useful only from this
machine and only within its budget and model list. eca is migrated; every
other jail is unchanged (pi follows in IMP-028).

```
eca jail ──LLM_GATEWAY_KEY──> 127.0.0.1:4000 ─ llm-gateway-relay (systemd-socket-proxyd)
                                                   │ group llm-gateway
                                                   ▼
                              /run/llm-gateway/api.sock   (dir 0750 llm-gateway:llm-gateway)
                                                   │
                              llm-gateway.service: uvicorn, user llm-gateway
                                route gate (ASGI): only chat/completions and models; else 404
                                                   │
                                LiteLLM proxy app
                                ├─ custom_auth ─────> keystore: known? revoked? under budget?
                                │                      → UserAPIKeyAuth(hash, alias, models)
                                ├─ model_gate ──────> every model named (incl. fallbacks) on `models`?
                                ├─ provider call (DeepSeek key from $CREDENTIALS_DIRECTORY)
                                └─ ledger ──────────> keystore: spent += response_cost
                                                   │
                              /var/lib/llm-gateway/keys.db  (dir 0700)

llm-gateway credentials   (you)   op read ─stdin─> sudo systemd-creds encrypt (host+TPM2)
                                    ─> /etc/credstore.encrypted/llm-gateway.<provider>
llm-gateway issue|list|…  (you)   sudo -u llm-gateway ─> keys.db
```

Decisions: DEC-046 (own SQLite key store, no Prisma), DEC-047 (one socket,
loopback relay, keys authenticate), DEC-048 (TPM-encrypted credential written
by a user-run step), DEC-049 (per-jail key file through the launcher's FD
path), DEC-050 (no master key; admin on the DB file), DEC-051 (key-store
semantics). Evidence: `research/research.md`; spike notes in IDE-003.

Three parts with separate owners:

| part | where | evaluation |
|---|---|---|
| gateway service, relay, admin CLI, Python code | `features/agents/gateway.nix` + `features/agents/gateway/` | NixOS |
| gateway mode for jails (opt-in, off by default) | `agents/jailed-agents.nix` (published sub-flake) | home, via `inputs.agents` |
| eca's use of it | `features/agents.nix` (eca record) | home |

The socket path, relay port and per-client key directory are constants in
`features/agents/gateway/constants.nix`, imported by both the gateway record
and the eca record (ADR-004 D4: a constant, not a value read across
evaluations). The `agents` sub-flake never imports it: eca passes the values
in as arguments (research G10).

<!-- doctrine:section sec-2 -->
## Gateway service (NixOS half)

Our own units, not nixpkgs `services.litellm`: that module hardcodes
`--host/--port` and runs under `DynamicUser`, which gives the relay no stable
group (research C2).

**`llm-gateway.service`**

| setting | value | why |
|---|---|---|
| user, group | `llm-gateway` (static system user and group, declared in the record) | the relay joins the group; G8 |
| `RuntimeDirectory` | `llm-gateway`, mode 0750 | uvicorn chmods the socket 0666 after binding, so the directory gates it (C1) |
| `StateDirectory` | `llm-gateway`, mode 0700 | `keys.db` |
| `LoadCredentialEncrypted` | one entry per configured provider, by absolute path: `deepseek:/etc/credstore.encrypted/llm-gateway.deepseek` | DEC-048; systemd's own store (root 0700, created by systemd's tmpfiles, present on Sleipnir) (RV-024 F-4). With the absolute-path form a missing credential is fatal: systemd refuses the unit at credential setup (`status=243/CREDENTIALS`) before the launcher runs. So the first switch reports a failed unit until `just gateway-credentials` (VH-1). The launcher's own check (below) covers a credential that is present but empty, and any other route to a missing one (RV-024 F-5, RV-026 F-2) |
| `ExecStart` | `llm-gateway-serve` | launcher, below |
| environment | `CONFIG_FILE_PATH=<store dir>/config.yaml`, `LITELLM_LOCAL_MODEL_COST_MAP=True` | module import (below); no price fetch from GitHub at start (L1) |
| hardening | `ProtectSystem=strict`, `ProtectHome=true`, `PrivateTmp`, `PrivateDevices`, `NoNewPrivileges`, empty `CapabilityBoundingSet`, `RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6`, `SystemCallFilter=@system-service`, `UMask=0077` | nixpkgs unit and capsule-proxy as baselines; `PrivateNetwork` is impossible (providers) |
| restart | `Restart=on-failure` | start takes ~25 s (spike) |

**Config directory.** One store directory holds `config.yaml`,
`gateway_hooks.py` and `keystore.py` side by side. LiteLLM loads
`custom_auth` and callbacks from `<config dir>/<module>.py`
(`litellm/proxy/types_utils/utils.py:39-44`, read in 1.100.1). `config.yaml`
is generated from Nix and holds no secret: provider keys are
`os.environ/DEEPSEEK_API_KEY` references (POL-001 r1). It sets no
`master_key` (DEC-050). Its build fails unless every model in `models` is
in LiteLLM's packaged price map (`price-check.py`), so a host override is
covered too (RV-026 F-5).

```yaml
model_list:                       # from the record's `models` option
  - model_name: deepseek-flash
    litellm_params: { model: deepseek/deepseek-flash, api_key: os.environ/DEEPSEEK_API_KEY }
general_settings: { custom_auth: gateway_hooks.authenticate }
litellm_settings: { callbacks: [gateway_hooks.model_gate, gateway_hooks.ledger] }
```

**Launcher, `llm-gateway-serve`** (stdlib Python run by the LiteLLM Python
environment): checks that every configured provider's credential is present
and non-empty in `$CREDENTIALS_DIRECTORY` and otherwise exits non-zero naming
the missing one and the fix (`just gateway-credentials`); reads each into
`<NAME>_API_KEY`; puts the config directory on `sys.path` (so
`gateway_hooks` can import `keystore`), wraps LiteLLM's app in the route
gate (§ Key store and LiteLLM hooks), then runs uvicorn on the wrapped app
with `uds=/run/llm-gateway/api.sock`. This replaces the spike's trick of reusing
the wrapper's site-path lines.

**Options** the record owns (ADR-004 D5): `models` (gateway name → LiteLLM
model id → provider) and `providers` (provider → credential name, env var,
`op://` ref; refs are public, G1). The default is the one DeepSeek model
above, `deepseek-flash`, which eca uses and LiteLLM prices (by user
direction during PHASE-05, b544a5f5; more models and providers: IMP-029). The set of
credentials is derived from the providers the models use.

**Relay.** `llm-gateway-relay.socket` listens on `127.0.0.1:4000` (port free;
4001 is taken); `llm-gateway-relay.service` runs
`systemd-socket-proxyd /run/llm-gateway/api.sock` with `DynamicUser` and
`SupplementaryGroups=llm-gateway`, and the same hardening. Socket activation
means the relay costs nothing until used.

**Selection.** `agents.gateway` is `mkDefault` in
`features/profiles/personal-linux.nix`, beside eca. The record is
NixOS-only, so it needs no `platforms`.

<!-- doctrine:section sec-3 -->
## Key store and LiteLLM hooks

Two Python modules with one job each. Only the second imports LiteLLM, so
the key store, the CLI and their tests run on a plain store Python.

```
keystore.py        stdlib only: schema, hashing, decisions, spend    (no LiteLLM)
gateway_hooks.py   LiteLLM adapter: route gate + hook calls into keystore calls
```

**Schema** (DEC-051), in `keys.db`, WAL mode:

```sql
create table keys(
  hash        text primary key,   -- sha256 hex of the bearer key
  alias       text not null unique,
  models      text not null,      -- JSON array of gateway model names
  budget_usd  real not null check (budget_usd >= 0),
  spent_usd   real not null default 0 check (spent_usd >= 0),
  created     text not null,
  revoked_at  text                -- null = live
);
```

`keystore` opens the database per call, creates the table if absent, and
exposes pure decisions over a row, so tests need no LiteLLM and no server:

| function | behaviour |
|---|---|
| `issue(alias, models, budget)` | new random key, `sk-` + `secrets.token_urlsafe`, stores its hash, returns the key once. The prefix makes LiteLLM hash the key wherever it logs or reports one, its auth-failure path included (RV-026 F-3) |
| `authenticate(key)` | raises `Refused` for an unknown key, a revoked key, or `spent >= budget`; returns the row |
| `allows_model(row, model)` | the model is on the key's list |
| `record_spend(hash, cost)` | `spent += cost`; a `None`, non-finite or negative cost is logged as a warning and counted as 0 |
| `usd(value)` | the one parser for money: refuses non-finite and negative values (`NaN` would make `spent >= budget` never true); used by the CLI and by every keystore write (RV-024 F-3). It is the finite-value guard; the CHECK constraints only enforce non-negative (they accept +Infinity) (F-7) |
| `revoke`, `set_budget`, `reset_spend`, `rows` | admin |

**Route gate.** Some LiteLLM routes never call `custom_auth`:
`/health/liveness` and a dozen `/public/*` routes have no auth dependency
(1.100.1: `proxy/health_endpoints/_health_endpoints.py:1813`,
`proxy/public_endpoints/public_endpoints.py:208`; RV-024 F-1). So route
filtering happens in front of LiteLLM, not inside a hook: a small ASGI
wrapper passes only `POST /chat/completions` and `GET /models` (with or
without `/v1`) and answers everything else 404 without reaching LiteLLM.
`custom_auth` then only judges the key. The allowed set is one constant in
`gateway_hooks`.

**`gateway_hooks`** binds them to four LiteLLM surfaces:

| surface | our function | contract we depend on |
|---|---|---|
| ASGI app `litellm.proxy.proxy_server:app` | `route_gate(app)` | importable app object; uvicorn serves the wrapper |
| `general_settings.custom_auth` | `authenticate(request, api_key)` → `UserAPIKeyAuth(api_key=<hash>, key_alias=<alias>, models=<list>)`; `keystore.Refused` becomes a 401 naming the alias | runs before LiteLLM's "no connected db" check (L2) |
| callback `model_gate`: `CustomLogger.async_pre_call_hook` | 403 unless every model the request names is on `UserAPIKeyAuth.models`: `data["model"]` and each fallback target, enumerated by LiteLLM's own `iter_request_fallback_targets` (top-level and `router_settings_override` fallbacks) (RV-026 F-4) | receives the `UserAPIKeyAuth` we returned and the parsed request (signature read in 1.100.1, `custom_logger.py:406`) |
| callback `ledger`: `CustomLogger.async_log_success_event` | `record_spend(metadata["user_api_key_hash"], kwargs["response_cost"])` | spike-observed kwargs |

LiteLLM ignores `UserAPIKeyAuth(models=...)` for custom auth (DEC-046), hence
`model_gate`, which reads the list we put there. Error messages name the alias, never the key; nothing logs
a bearer key (POL-001 r5).

**Budgets** are lifetime totals, checked before each call; concurrent
requests can overshoot by about one request's cost each (DEC-051). A missing
price is prevented up front: the config directory's build fails if any
configured model lacks an entry in LiteLLM's packaged price map (sec-2), and
the integration check asserts it for the defaults.

<!-- doctrine:section sec-4 -->
## Admin CLI and credentials

One command, `llm-gateway`, installed by the NixOS half (stdlib Python, store
interpreter, imports `keystore`). Provider `op://` refs and credential names
are baked in from the record's `providers` option, so Nix stays their single
source.

| subcommand | runs as | does |
|---|---|---|
| `credentials [provider…]` | you, then root via sudo | for each provider: `op read <ref>` piped on stdin into `sudo systemd-creds encrypt --with-key=host+tpm2 --name=<provider> - <target>.new`, then `sudo mv` over `/etc/credstore.encrypted/llm-gateway.<provider>` only when both succeeded; on failure the staged file is removed and the stored credential is untouched (RV-026 F-1). Then `systemctl reset-failed` (clears a start limit hit while no credential existed), `restart`, and a bounded wait (90 s) for the socket, probed with `sudo test -S` since the run directory is closed to you (RV-026 F-6) |
| `issue <alias> --models … --budget …` | `llm-gateway`, via sudo | prints the new key once; refuses unknown model names and a budget `usd()` rejects |
| `list` | `llm-gateway`, via sudo | alias, models, budget, spent, revoked; never hashes or keys |
| `revoke <alias>`, `budget <alias> <usd>`, `reset <alias>` | `llm-gateway`, via sudo | |

Admin subcommands re-exec themselves under `sudo -u llm-gateway` when not
already that user (DEC-050). `credentials` runs `op` as you, which is one
1Password unlock per rotation instead of one per start (DEC-048). Keys travel
on stdin, never argv. The credential store path and the socket are baked
into the CLI from the record, like the refs. No PCR binding, so firmware updates don't lock the
broker out.

`just gateway-credentials` is a one-line recipe that calls
`llm-gateway credentials`, so the step is discoverable where the other
host operations live (DEC-048 "a just recipe").

**First run** (also the VH script):

```
just system-switch                      # unit fails at credential setup (243/CREDENTIALS): expected
just gateway-credentials                # op unlock once; returns when the gateway serves
llm-gateway issue eca --models deepseek-flash --budget 5 \
  --out ~/.config/llm-gateway/keys/eca  # written by you, mode 0600
```

`--out` is handled only by the unprivileged parent (RV-024 F-6):

1. Preflight: the destination does not exist and its directory is writable,
   creating each missing directory on the way (`~/.config/llm-gateway`,
   `keys`) 0700 whatever the umask (RV-026 F-8). Refuse to overwrite.
2. The privileged child issues the key and returns it on stdout.
3. The parent writes it to a temp file (mode 0600) in the same directory
   and renames it into place.
4. If step 3 fails, the parent revokes the just-issued key through the
   child and reports the failure, so no live key exists that nobody holds.

Without `--out`, the key is printed once. A shell redirect's umask is not
relied on.

**Rotation.** A key is never re-keyed in place, and a revoked alias stays
taken (DEC-051, reaffirmed by the user 2026-10-17). A client rotates by a
new alias written to the same `--out` path, then revoking the old alias;
the alias is only the ledger's name.

<!-- doctrine:section sec-5 -->
## Jail gateway mode and eca

**`agents/jailed-agents.nix`** gains one argument to `makeJailedAgent`,
default off (the sub-flake is published, G10):

```nix
gateway ? null,   # { keyFile = "$HOME/.config/llm-gateway/keys/eca"; url = "http://127.0.0.1:4000/v1"; runDirectory = "/run/llm-gateway"; }
apiKeys ? (if gateway == null then lib.attrNames apiKeyOpRefs else []),
```

`runDirectory` is passed in, not imported: `agents/` is a published flake
and cannot import `features/agents/gateway/constants.nix`; eca builds all
three values from that file.

When `gateway` is set:

- **No provider keys.** `apiKeys` defaults to `[]`, so no `op run` wrapper
  and no provider variables. An explicit non-empty `apiKeys` beside
  `gateway` is refused at evaluation (G2: no mixing).
- **Key by FD.** A second `--args` descriptor carries
  `--setenv LLM_GATEWAY_KEY "$(< keyFile)"` down a pipe, the same argv-safe
  path the provider keys use (DEC-049). `$(< …)` is a shell builtin read, so
  the key is in no process's argv.
- **URL as plain env.** `LLM_GATEWAY_URL` is set with `set-env`; it is not
  secret.
- **Clear failure.** A thin outer wrapper, in the same place as today's
  `op run` wrapper, checks first and exits with a message naming the fix:
  - key file unreadable → `llm-gateway issue <name> … --out <file>`;
  - `runDirectory` absent → the gateway is not running: not yet switched
    (`just system-switch`; covers `home-switch` landing before
    `system-switch`, G6), or the service is failing
    (`systemctl status llm-gateway`; first run: `just gateway-credentials`)
    (RV-026 F-7).
- **Not refused:** `gateway` with the `offline` profile. The jail has no
  network, so it fails loudly at first use; accepted.

```
launcher choice     op wrapper   gateway wrapper   bare inner
gateway = null      keys ≠ []    –                 keys = []   (unchanged)
gateway set         –            always            –
```

**Every jail: bwrap starts with an empty environment** (b17e348a; beyond
this design, by user ruling 2026-10-17). VH-6 found that `--clearenv`
empties only the child's environment. bwrap's own is the launching
session's, provider keys included, and bwrap is PID 1 in the jail's pid
namespace with the same uid, so the agent can read it at `/proc/1/environ`.
Gateway mode would be cosmetic with that open. Jails are now built with
`jail-nix.lib.extend { bubblewrapPackage = <env -i wrapper>; }`: bwrap is
exec'd under `env -i`, after the launcher has put every value it needs into
argv or an `--args` descriptor. bwrap reads only `HOME`, and only without
`--chdir`, which every jail passes. This changes the published `agents/`
flake for every consumer and every jail, gateway or not.
(mem.fact.bwrap.pid1-environ-leak)

**eca** (`features/agents.nix`): `requires = ["agents.gateway"]`;
`makeJailedEca` gets `gateway` from the constants file, and drops its
`apiKeys` list. eca's provider config lives in `~/.config/eca/config.json`,
a dotfile outside Nix, untracked and edited by hand: `home-switch` changes
only the jailed-eca wrapper. The VH step edits its `deepseek` provider to
`url: http://127.0.0.1:4000/v1` and `key: ${env:LLM_GATEWAY_KEY}`, and its
model list to the gateway's names. The unjailed `eca` is untouched.

`agents/README.md` documents gateway mode, and its stale `--setenv`
description of key forwarding is corrected in the same section (research
revision candidates).

<!-- doctrine:section sec-6 -->
## Phases and verification

| phase | change | proof |
|---|---|---|
| P1 key store | `keystore.py` + `keystore-test` (unittest, temp DB) | VT: issue shows the key once and stores only the hash; auth accepts a live key, refuses unknown, revoked and over-budget keys; model allow-list; spend accrues; `None`, `NaN`, infinite and negative costs count 0; `NaN`, infinite and negative budgets are refused by `usd()`; a negative value written directly is refused by the CHECK constraints; CLI `issue --out` refuses an existing destination, and a failed write revokes the issued key |
| P2 LiteLLM adapter | `gateway_hooks.py`, launcher, `config.yaml` generation, `checks.<system>.llm-gateway` | VT, against the LiteLLM the system nixpkgs ships (1.102.1), offline: through the real proxy app, a request with a valid key returns 200, a bad key 401, a disallowed model is refused, an exhausted budget is refused, a served request raises `spent` by a positive amount; unauthenticated requests to `/health/liveness`, `/public/model_hub` and an admin route get 404 from the gate; every configured model has a price |
| P3 service | NixOS half: users, units, relay, CLI, `providers`/`models` options; `personal-linux` selection; `just gateway-credentials` | Sleipnir system evaluates (`just drvs`: system drv changes, named); `just test` |
| P4 jail gateway mode | `gateway` argument, outer wrapper, assertions; `jailed-agents-test` cases | VT: gateway mode emits no `op run` and no provider `--setenv`, reads the key through `--args`, sets `LLM_GATEWAY_URL`, refuses `gateway` + non-empty `apiKeys`; existing cases unchanged |
| P5 eca + docs | eca record, README, agents/README | VH below; `just drvs`: home drv changes (eca), named |

**`just test`** gains three lines: `features/agents/gateway/keystore-test`
(stdlib script test, like `dictate-test`), `checks.<system>.llm-gateway`, and
`checks.jailed-agents`, which no recipe ran until now (research C6). The
user's uncommitted `justfile` edits stay out of every commit.

**Integration check (P2).** A flake check built with the same nixpkgs as the
NixOS system, so the pinned surfaces are the ones that will run. It drives
the proxy app in-process (HTTP client against the ASGI app, no socket, no
network) with `mock_response` models and a temp key store. If a LiteLLM bump
changes the hook signatures, the metadata key or `response_cost`, this check
fails before a switch does. The spend case uses the production model
mapping (`deepseek/deepseek-flash`) and the packaged price map, and
requires `response_cost > 0` (RV-024 F-2). To verify at point of use: that a
`mock_response` call on that model takes the production pricing path. If it
does not, the spend case becomes a separately named adapter test feeding the
callback a recorded success payload, and the claim that production pricing
works rests on VH step 7, not on this check.

**Coverage.** Sleipnir selects the gateway, so host evaluation covers it; no
`coverage` target is needed (ADR-005). No NixOS VM test: that would be a new
test kind.

**VH (verified by the human), after P5:**

1. `just system-switch`; the unit fails at credential setup
   (`status=243/CREDENTIALS`; `journalctl -u llm-gateway`: "Failed to set up
   credentials: No such file or directory"), before the launcher runs.
2. `just gateway-credentials`; the service is active.
3. `llm-gateway issue eca … --out ~/.config/llm-gateway/keys/eca`.
4. `just home-switch`; edit eca's untracked `~/.config/eca/config.json` by
   hand (§ Jail gateway mode).
5. A real eca request succeeds.
6. Inside the eca jail, `env | grep -i _api_key` is empty and only
   `LLM_GATEWAY_KEY` is present.
7. `llm-gateway list` shows eca's spend above zero (proves real DeepSeek responses are priced).

Each phase also: `nix fmt` on touched files without committing the
`emacs-overlay` re-lock (mem.fact.flakes.fmt-relock); new files
`git add -N` before evaluating.

<!-- doctrine:section sec-7 -->
## Code impact and docs

```
features/agents.nix                     area list + (import ./agents/gateway.nix); eca: requires, gateway, no apiKeys
features/agents/gateway.nix             new record: nixos half (users, units, relay, CLI, options)
features/agents/gateway/constants.nix   socket path, relay port and URL, key directory
features/agents/gateway/keystore.py     key store (stdlib)
features/agents/gateway/keystore-test   unittest script test
features/agents/gateway/gateway_hooks.py  LiteLLM adapter
features/agents/gateway/llm-gateway-serve launcher
features/agents/gateway/llm-gateway     admin CLI
features/agents/gateway/gateway-test    integration test run by the flake check
features/agents/gateway/proxy.nix       LiteLLM env, default models, config dir (+ price-check.py)
features/profiles/personal-linux.nix    agents.gateway mkDefault
features-test.nix                       personal-linux expectations; eca requires gateway
perSystem.nix (or the flake's checks)   checks.<system>.llm-gateway
agents/jailed-agents.nix                gateway argument, wrapper, assertion; bwrap under env -i (all jails)
agents/jailed-agents-test.nix           gateway-mode cases; empty bwrap environ
justfile                                test: three lines; gateway-credentials recipe
README.md                               feature tree (agents line), § LLM gateway, § Jailed Agents note
agents/README.md                        gateway mode; stale --setenv text fixed
```

The ~100-line guideline puts the record in its own file from the start
(ADR-002, DEC-015); its Python and tests sit in `features/agents/gateway/`,
named explicitly by the record (no discovery). Python cache files from local
test runs are ignored, not committed.

**Docs.** README § Feature tree: the agents line gains `gateway`. A new
README § LLM gateway: the diagram from § Shape, first run, rotation, adding a
client, and what it does not cover (OAuth logins, other jails until IMP-028).
At reconcile: IDE-003 (what shipped), IMP-020 (eca no longer uses provider
env vars), POL-001's verification line (gateway as the runtime control for
migrated jails).

