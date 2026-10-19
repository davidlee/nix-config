# Notes SL-015: Gateway and launch-dir options for network-isolated jails

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Design triage (2026-10-20, exploring)

Evidence: `research/research.md` (✓ rows only are load-bearing).

**Constraining governance.** ADR-004 D4 (client socket path is a shared
constant in `agents/gateway.nix`); DEC-047 (one socket, keys authenticate,
`0750` gate kept); DEC-049 (key custody unchanged); DEC-059 (`gatewayClient`);
SPEC-001 § Client contract + § Perimeter (change only by decision; REV at
reconcile); POL-001 (nothing secret added).

**Shaping decisions to make** (one inquiry each):
1. Relay topology: one socket unit, two listeners (P2 verified).
2. Transport vs key custody (OQ-1): `jailed-malebolge` uses no `gateway`.
3. The DEC-047 extension and its egress sentence ("network" egress only).
4. Launch-dir option shape; `--chdir` always passed.
5. `offline` + gateway (OQ-2): refuse TCP, default socket, or backlog.
6. openssh for room clients: jailLib or satan `extraPkgs`.
7. Verification: no VM test exists; launcher tests + a live probe.

**Risks.** Bound unix sockets are channels to host processes (satan's to
audit). Room ssh config names a store-path socat that must be in the jail
closure (satan-side; report to SL-027).

**Assumptions.** A-1, A-2 verified (`research/raw/probes.md`).

## Design review passes (2026-10-20, reviewing)

- Pass 1, informal, pre-draft: GPT (gpt-6-sol via Codex) on the decisions.
  Seven findings; adjudicated in the run: F-1, F-2, F-4, F-5, F-7 accepted
  (DEC-076, DEC-077 amended), F-6 partly (no userns in the build sandbox:
  behaviour test without bwrap + VA), F-3 rejected (forwarder death is
  visible). No RV ledger.
- A further pass would probe: the forwarder script itself (bash `read` over
  `/proc/net/tcp`, port hex, `exec` with jail.nix's wrap-entry `"$@"`
  quoting), the `defer` guard's interaction with `include-once "network"`,
  and the `profiles` refactor keeping specDev/research argv byte-identical.
  All three are code-level and covered by sec-7 VT 1-5; a design-level pass
  adds little. Recommendation: waive, and review the code at audit.

## PHASE-04 live evidence (2026-10-20)

### EN-2 recovery (F-1)

`just system-switch` left the old relay listeners: `systemctl restart
llm-gateway-relay.socket` is refused ("Socket service llm-gateway-relay.service
already active, refusing") while `systemd-socket-proxyd` holds the fd. The
user's manual recovery worked: stop the service, `reset-failed`, start the
socket. Starting the service alone fails "Didn't get any sockets passed in".

### T1 relay restart on socket change

Source read: nixpkgs (the flake's `nixpkgs` input,
`pkgs/by-name/sw/switch-to-configuration-ng/src/main.rs`).

- `handle_modified_unit`: the `.socket` branch is a `FIXME: do something?`
  no-op (NixOS#74899, reverted attempt PR 147609). A changed socket unit is
  never restarted by a switch.
- Same function, the `.service` branch with the default `X-StopIfChanged`:
  finds the unit's sockets (`Sockets=`, else `<name>.socket`); for each one in
  `active_cur` it inserts the socket into `units_to_stop` and, if it exists in
  the new config, into `units_to_start`, and sets `socket_activated`, so the
  service itself is not started. Net: stop service and socket, start socket.
- `compare_units`: only `[Unit]` keys `X-Reload-Triggers`, `Description` and a few
  others are ignored; `X-Restart-Triggers` is not, so a changed trigger file
  path makes the service "modified".
- `nixos/lib/systemd-lib.nix`: `restartTriggers` becomes `X-Restart-Triggers=
  <writeText file>` in `[Unit]`; the file lists the trigger store paths.
- Only units active/activating in the running system are compared.

Fix: `systemd.services.llm-gateway-relay.restartTriggers =
[config.systemd.units."llm-gateway-relay.socket".unit]` in
`features/agents/gateway.nix`. No infinite recursion (the socket unit does not
depend on the service unit).

TDD by evaluation; no new check machinery for one line (no check evaluates a
host's systemd units; a host-eval check is not worth it):

- Red: `config.systemd.units."llm-gateway-relay.service".text` has no
  `X-Restart-Triggers` line (filter over the text, `[]`).
- Green: `X-Restart-Triggers=/nix/store/z2qh32kk...-X-Restart-Triggers-llm-gateway-relay`;
  that file, built, contains `/nix/store/i8j0ga5y...-unit-llm-gateway-relay.socket`,
  which is `config.systemd.units."llm-gateway-relay.socket".unit`.
- `just drvs` before/after: only `nixosConfigurations.Sleipnir` changed. No
  home, darwin or `base@aarch64-linux` drv. `just coverage` evaluates all
  targets (`Sleipnir+speech` equals Sleipnir's drv, as the README says).

Live gap (needs sudo, not run): the first switch after this lands restarts the
relay once (the service unit changes): a few seconds' outage for in-flight
requests. Verify with `dry-activate` (expect the relay service and socket in
"would stop", the socket in "would start"), then switch, then
`systemctl show llm-gateway-relay.socket -p ActiveEnterTimestamp`.

Residual gap: a relay service that is inactive at switch time is not compared,
so the socket keeps its old listeners; `systemctl restart
llm-gateway-relay.socket` works then. Documented in README § LLM gateway.

### VA-1 live check

Ad hoc jails from a scratch expression (not in the repo): `offline` +
`gatewayClient "probe"` with the probe key (alias `sl-015-probe`), `mountLaunchDir
= false`, `persistedHome = "sl-015-probe-offline"`, `workspaceDepsFromEnv =
false`; and a `specDev` control with `persistedHome = "sl-015-probe-tcp"`.
No key value was printed or recorded.

Host: `/run/llm-gateway-client root:root 755 directory`,
`/run/llm-gateway-client/api.sock david:users 600 socket`,
`/run/llm-gateway llm-gateway:llm-gateway 750 directory`.

| check (offline jail) | result |
|---|---|
| `GET /v1/models` with the key | 200 |
| same without the key | 401 |
| `127.0.0.1:22` | curl exit 7; `ztcp`: "connection refused" |
| router `192.168.0.1:80` | curl exit 7; `ztcp`: "network is unreachable" (empty route table) |
| `/proc/net/tcp` | one LISTEN row, `0100007F:0FA0` (127.0.0.1:4000); the other rows are curl's TIME_WAIT |
| `/run/llm-gateway-client`, `/run/llm-gateway`, `pwd` | client dir present (`drwxr-xr-x 65534`: root as the jail sees it); `/run/llm-gateway` absent; `/home/david` |

TCP control (specDev, host netns, no socket mode): `GET /v1/models` with the
key 200, without 401; `/run/llm-gateway-client` and `/run/llm-gateway` both
absent; the host's 0FA0 relay listener is visible and the jail starts none of
its own; cwd `/workspace/scratchpad`. It stands in for an existing TCP gateway
jail: the same code path (PHASE-03 VT-1: specDev + gateway argv unchanged).
Not the shipped `jailed-eca`/`jailed-pi`: they would spend their own keys.

Teardown: the two probe homes and the `result` links removed. `/tmp/probe-key`
and the `sl-015-probe` key are left for the user (revoke, then delete).

### VA-2 docs against code

Every name, path, default and message the new text states was grepped in the
shipped code: `/run/llm-gateway-client`, `api.sock`, relay port 4000
(`agents/gateway.nix`); mode `0600`, dir `0755`, `SocketUser` (relay socket,
`features/agents/gateway.nix`); `gatewaySocketOptions`, `gatewayClient`
exports; defaults `mountLaunchDir`/`workspaceDepsFromEnv` `true`,
`persistedHome` `null` and its regex; profile homes `agent`, `agent-research`,
`agent-offline`; the netns guard message verbatim; the two forwarder messages
(built from `where` = `127.0.0.1:4000` and the literal "after 2 s"); the
pre-flight now checks `/run/llm-gateway-client` in socket mode
(`gatewayReachDirectory`). No mismatches.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-20 · ready · 002b58c1

### Produced
- scope, research, locked design, plan PHASE-01..04 (commit 002b58c1); no code yet
- minted: DEC-075 — relay client listener; DEC-076 — transport from profile, forwarder, netns guard; DEC-077 — extends DEC-047, gateway is the only direct network path; DEC-078 — mountLaunchDir
- handback to satan:SL-027 delivered by the user (openssh, ProxyCommand, profile-switch home change, unix-socket egress audit)

### Learned
- mem.fact.bwrap.unshare-net-host-reach — netns reach, ro dir bind, multi-listener proxyd, `defer` guards, sandbox testing

### Open
- none: inq-1..7 disposed; PHASE-03 VT-3 settles the `/proc/net/tcp`-per-netns inference behind readiness
