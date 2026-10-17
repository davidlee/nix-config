# LiteLLM credential broker with own key store

## Context

IDE-003: agents should hold no raw provider API keys. Today
`agents/jailed-agents.nix` resolves `op://` refs with `op run` and puts the
keys in each jail's environment (all seven by default; IMP-020). One `env`
dump leaks them to the agent's provider and its transcript (POL-001 rules 4
and 5).

Direction, settled 2026-10-17:

- LiteLLM proxy as a host-side system service holds the real keys
  (IDE-003 survey).
- **DEC-046:** LiteLLM runs with no database of its own. Our own
  dependency-free Python module authenticates per-client keys against a
  SQLite table through `general_settings.custom_auth`, and records spend
  through a `CustomLogger` success callback. It supersedes DEC-045 (no
  database, master key only), which was reached after the nixpkgs Prisma
  path proved broken.
- Spike evidence (IDE-003 notes): `uvicorn … --uds` serves the proxy on a
  unix socket; the custom-auth spike gave 200, 401 and `budget exhausted`
  with stdlib `sqlite3` and no Prisma.

```
client ──key──> socket ──> LiteLLM (service user, real keys from 1Password)
                             ├─ custom_auth ──> keys.db: known? model allowed? under budget?
                             ├─ route to provider
                             └─ success callback ──> keys.db: spent += response_cost
```

## Scope & Objectives

One shippable change: the broker exists, is tested, and one jailed harness
uses it end to end with no provider key in its environment.

1. **Broker service.** A NixOS feature half (placement is design's job,
   likely the `agents` area) running LiteLLM under uvicorn on a unix socket,
   as its own system user, with state in `/var/lib/<name>`. Provider keys and
   the master key reach the service at start, never the Nix store
   (POL-001 rule 1). We write our own unit or override `ExecStart`, because
   the nixpkgs unit hardcodes `--host/--port`.
2. **Key store module** (Python, stdlib only): `custom_auth` (sha256 key
   lookup, model allow-list enforced by us, budget check) and the spend
   callback. Behaviour tests run against LiteLLM with `mock_response` models,
   and must pin the LiteLLM surfaces we depend on (the `custom_auth`
   signature, `UserAPIKeyAuth`, `metadata.user_api_key_hash`,
   `response_cost`).
3. **Key admin CLI:** issue, list, revoke, set budget, show spend. It shows
   each key once at issue, and the table stores only its hash.
4. **One consumer migrated:** one jailed harness talks to the broker with a
   per-jail key and gets no provider key. Design picks which (pi + DeepSeek is
   the likely first).

## Non-Goals

- Migrating every jail, and retiring the `op run` env-var path. That work
  follows, and IMP-020 is reconsidered then.
- SATAN consumers: the proposal-VM room's forwarder (oubliette Plan F),
  satan-tick, and satan's ISS-023, ISS-029 and ADR-017. The socket contract
  this slice fixes is their input.
- gptel and Emacs.
- Brokered git (IDE-004).
- Packaging Prisma or running LiteLLM's own virtual keys (DEC-046
  alternatives).
- Fixing the existing Postgres collation drift (unrelated; the broker uses
  SQLite).

## Affected surface

- `features/agents.nix`, plus `features/agents/broker/` for the module,
  CLI and tests (placement: design)
- `agents/jailed-agents.nix` (a broker mode for one jail)
- `hosts/Sleipnir/features.nix` (selection)
- README (section on the broker)

## Open questions (for design)

1. **How do jailed harnesses reach a unix socket?** Harnesses speak HTTP over
   TCP. Jails share the host network namespace (jail.nix's `network`
   combinator), so any loopback TCP forwarder is reachable host-wide. For
   jails, the per-client key is then the real authentication, and the socket
   mode only guards the forwarder. Options: a forwarder per jail on loopback,
   one host-wide loopback listener, or binding the socket into the jail with
   a client that speaks unix sockets. Decide what the socket's file mode
   actually protects.
2. **Trust classes:** which classes exist, and how many sockets? Uvicorn
   binds a single listener, so several sockets means several instances or a
   forwarder.
3. **Secrets at start:** how provider keys and the master key get from
   1Password to a system service without an interactive prompt (`op` service
   account, or a root-only `EnvironmentFile` written out of band). Must not
   reproduce satan ISS-023 (prompt-mode runs lost to the 1Password dialog
   timeout).
4. **Master key and admin path:** the master key also passes through
   `custom_auth`. How does the admin CLI authenticate: does it read the
   table directly as the service user, or call admin endpoints?
5. **Budget overshoot:** is a pre-call check (overshoot of at most
   concurrency × the cost of one request) acceptable, or do we reserve
   from `max_tokens`?
6. **Hardening:** systemd sandboxing (the nixpkgs unit is a good baseline),
   and `PrivateNetwork` is impossible because the service must reach the
   providers.

## Risks and assumptions

- LiteLLM upgrades may change the hook surfaces. Mitigation: the tests in
  item 2 fail on drift.
- Assumption: `response_cost` is populated for every provider we use
  (DeepSeek, OpenRouter). If cost is unknown, the callback gets `None` and
  the budget never moves. Design verifies and decides fail-closed or
  fail-open.
- LiteLLM is large; its closure and startup time (about 25 s in the spike)
  are acceptable for a system service.

## Verification / closure intent

- Behaviour tests in `just test`: auth accept and reject, model allow-list,
  budget refusal, spend accounting, revoke.
- The broker evaluates through `just coverage` or a host selection, and
  `system-switch` brings it up on Sleipnir.
- VH (verified by the human): the migrated jail completes a real request
  through the broker; `env` inside the jail shows no provider key; spend
  appears in the CLI.

## Summary

Host-side LiteLLM on a unix socket, with our own SQLite keys and budgets
(DEC-046). One jail is migrated to prove the path; every other consumer
follows in later slices.

## Follow-Ups

- Migrate the remaining jails; retire `op run` key injection; reconsider IMP-020.
- SATAN room forwarder (oubliette Plan F), satan-tick, satan ISS-023/ISS-029/ADR-017.
- gptel through the broker.
