<!-- doctrine:section sec-1 -->
## Overview

A jail whose profile has no network (bwrap `--unshare-net`) can reach the LLM
gateway, and any jail can run without the launch-dir bind. Prerequisite for
satan:SL-027's room profile. Decisions: DEC-075..078.

```
jail, profile without network (--unshare-net)
  client ──http://127.0.0.1:4000/v1──> socat (wrap-entry, in jail)
                                          │ UNIX-CONNECT, via ro dir bind
host                                      ▼
  llm-gateway-relay.socket  ── 127.0.0.1:4000            (networked jails, unchanged)
                            └─ /run/llm-gateway-client/api.sock  user, 0600   (new, DEC-075)
           │ one systemd-socket-proxyd (DynamicUser, group llm-gateway)
           ▼
  /run/llm-gateway/api.sock  (dir 0750 llm-gateway: gate unchanged) ── LiteLLM
```

Key custody (DEC-049) and the `gateway` value's shape (DEC-059) do not change.
The client contract's URL does not change.
<!-- doctrine:section sec-2 -->
## Relay listener (DEC-075)

`agents/gateway.nix` gains two constants beside `runtimeDirectory` / `socket`
(ADR-004 D4: shared by the system eval and every jail, in and out of tree):

```nix
clientRuntimeDirectory = "llm-gateway-client";
clientSocket = "/run/${clientRuntimeDirectory}/api.sock";
```

`features/agents/gateway.nix`, socket unit `llm-gateway-relay`:

```nix
listenStreams = ["127.0.0.1:${toString constants.relayPort}" constants.clientSocket];
socketConfig = { SocketUser = username; SocketMode = "0600"; DirectoryMode = "0755"; };
```

`username` is the module argument other features use (`features/audio.nix:7`).
`SocketUser`/`SocketMode` apply to the unix listener only. The directory is
created by PID 1. One `systemd-socket-proxyd` serves both fds (research P2).
The client socket belongs to the socket unit, so gateway restarts do not
recreate it.

The relay service gains
`restartTriggers = [config.systemd.units."llm-gateway-relay.socket".unit]`
(RV-033 F-3). switch-to-configuration does nothing for a changed `.socket`
unit (NixOS#74899); for a changed, active service it stops the service and its
active socket, then starts the socket. A listener change therefore lands only
if both are active at the switch: wake the relay first. The states and their
recovery are in README § LLM gateway, "Relay restart"
(`mem.fact.nixos.switch-socket-activated-units`).
<!-- doctrine:section sec-3 -->
## Transport and forwarder (DEC-076)

**Profiles carry their network flag.** One table replaces `profileOptions`'
literal `network` entries:

```nix
profiles = {
  specDev  = { network = true;  home = "agent";          options = []; };
  research = { network = true;  home = "agent-research"; options = []; };
  offline  = { network = false; home = "agent-offline";  options = []; };
};
profileOptions = p: home:
  [(persist-home home)] ++ profiles.${p}.options
  ++ lib.optional profiles.${p}.network jail.combinators.network;
```

`home` is data so a jail can override it (`persistedHome`, "Workspace deps and persisted home");
persist-home stays first, so argv order is unchanged.

`profileDefaults` (git and op toggles) stays separate: those are caller-overridable,
network is not.

**The forwarder** is a pure function of its endpoints, in its own file
`agents/gateway-forwarder.nix` (imported by `jailed-agents.nix`), so the test
can use a temporary socket and port:

```
gatewayForwarder = { socket, port }: [
  (ro-bind (dirOf socket) (dirOf socket))
  (wrap-entry (entry: ''
     socat TCP-LISTEN:<port>,bind=127.0.0.1,fork,reuseaddr UNIX-CONNECT:<socket> &
     pid=$!
     # ready: socat alive AND /proc/net/tcp has a 0100007F:<PORTHEX> row in state 0A (LISTEN)
     #        whose inode is one of that socat's fds (a row alone also matches a
     #        foreign listener on an occupied port; RV-033 F-3)
     bounded loop (~2 s): kill -0 $pid || fail "forwarder exited"; listening && break
     listening || fail "forwarder not listening"
     exec <entry>''))
  (defer (s: if s.namespaces.net or false
             then throw "gateway socket mode needs a jail without network"
             else s))
]
gatewaySocketOptions = gatewayForwarder { socket = clientSocket; port = relayPort; };
```

- socat, grep-free parsing (bash `read` over `/proc/net/tcp`) and sleep are
  referenced by store path; jail.nix puts the wrapped entry's closure in the
  jail (`bind-nix-store-runtime-closure.nix:47`).
- Readiness makes no upstream connection (GPT review F-4). An early socat exit
  (e.g. `EADDRINUSE`) fails the launch (F-1).
- `exec` keeps the agent's PID, signals and exit status. socat dies with the
  PID namespace. A forwarder that dies mid-run surfaces as connection refused;
  not supervised (F-3 rejected).
- The `defer` guard runs after every other combinator (`defer.nix`), so it sees
  `extraOptions` too: socket mode in a jail sharing the host netns is an
  evaluation error, however the list was added (F-2, F-5).

**makeJailedAgent** adds `gatewaySocketOptions` when `gateway != null` and
`!profiles.${profile}.network`. Its `gatewayOuter` pre-flight checks
`clientRuntimeDirectory` instead of `gateway.runDirectory` in that case, with
the same messages. A jail without `gateway` (key-file clients:
`jailed-malebolge`) adds `jailLib.gatewaySocketOptions` through `extraOptions`;
it gets no pre-flight. Exported: `gatewaySocketOptions` only (not
`gatewayForwarder`).
<!-- doctrine:section sec-4 -->
## Launch-dir option (DEC-078)

The two launch-dir args leave `baseJailOptions` (its comment stays true:
"not policy-bearing") and become:

```nix
mountLaunchDir ? true,
...
launchDirOptions =
  if mountLaunchDir
  then [ --bind "$PWD" "/workspace/$(basename "$PWD")"  --chdir "/workspace/$(basename "$PWD")" ]
  else [ --chdir "$HOME" ];
```

`--chdir` is passed either way (bwrap reads `HOME` from its env only without
it: `mem.fact.bwrap.pid1-environ-leak`). `$HOME` is the persisted jail home
(`persist-home` binds it at `~`). Order in `inner` is unchanged: where
`baseJailOptions` sat. Default on: no existing jail changes.

### Workspace deps and persisted home (PHASE-05)

Added 2026-10-20 at the user's direction from satan:SL-027 RV-035 F-1 and
F-6; written here at reconcile (RV-033 F-2).

```nix
workspaceDepsFromEnv ? true,  # false: never call getEnv "JAIL_WORKSPACE_DEPS"
persistedHome ? null,         # null: profiles.${profile}.home
```

- **`workspaceDepsFromEnv = false`** drops the impure-eval merge of
  `JAIL_WORKSPACE_DEPS`, so a devshell's environment cannot add rw
  `/workspace/<dep>` binds to that jail. Static `workspaceDeps` still bind.
- **`persistedHome`** gives a jail its own persisted home in place of the
  profile's shared one (e.g. `"malebolge"`), so its writes reach no other
  jail. The name must match `[A-Za-z0-9][A-Za-z0-9._-]*` or evaluation throws:
  jail.nix splices it unescaped into a path and into the launcher's shell.
- Both forward through every `makeJailed*` constructor (they pass `args` to
  `makeJailedAgent`). Defaults leave every existing launcher byte-identical.
<!-- doctrine:section sec-5 -->
## Egress and security (DEC-077)

- In a jail without network, the gateway is the only **direct** network path,
  bounded by the key's model list and budget. Host unix sockets bound into the
  jail are channels to host processes with their reach; auditing them is the
  jail definition's job (satan:SL-027 for `/run/user/1000/satan`).
- The client socket is reachable by every process of the user, as `:4000` is
  by every local process (DEC-047): keys stay the authentication. The `0750`
  gate on `/run/llm-gateway` is unchanged.
- The jail binds the client directory read-only: it can connect (P3) but not
  unlink, replace or shadow the socket.
- Nothing secret is added (POL-001).
<!-- doctrine:section sec-6 -->
## Code impact

| path | change |
|---|---|
| `agents/gateway.nix` | `clientRuntimeDirectory`, `clientSocket` |
| `features/agents/gateway.nix` | relay socket: second listener, ownership; relay `restartTriggers` |
| `agents/gateway-forwarder.nix` | the forwarder (`{ socket, port }` → options) |
| `agents/jailed-agents.nix` | `profiles` table (with `home`); `gatewaySocketOptions`; launch-dir out of `baseJailOptions`, `mountLaunchDir`; socket-mode wiring and pre-flight; `workspaceDepsFromEnv`, `persistedHome`; export |
| `agents/jailed-agents-test.nix` | tests (sec-7) |
| `agents/jailed-agents-env-test.nix` | the impure test (sec-7 item 6) |
| `agents/flake.nix` | `impureChecks.<system>.jailed-agents-env` (not under `checks`: `nix flake check` is pure) |
| `justfile` | `just test` builds the impure check with `--impure` |
| `agents/README.md` § Gateway mode | socket mode, `gatewaySocketOptions`, `mountLaunchDir`, PHASE-05 args |
| `README.md` § LLM gateway | the client socket in the topology diagram; relay restart |
<!-- doctrine:section sec-7 -->
## Verification

VT (`just test`, `checks.<system>.jailed-agents`), fake bwrap recording argv:

1. `offline` + `gateway`: argv has `--ro-bind /run/llm-gateway-client /run/llm-gateway-client`,
   no `--share-net`, and the entry is the forwarder wrapper; pre-flight names
   the client directory.
2. `specDev` + `gateway`: argv and launcher identical to today (existing
   tests pass unmodified; no client bind).
3. `offline` + `gateway` + `extraOptions = [network]`: evaluation fails with
   the guard's message. `specDev` + `extraOptions = gatewaySocketOptions`: same.
4. `mountLaunchDir = false`: no `/workspace` bind, `--chdir "$HOME"`.
   Default: today's bind and chdir.
5. Forwarder behaviour, real socat, no bwrap (the build sandbox has its own
   netns with loopback): `gatewayForwarder` on a temp socket and port, entry
   = a client script. (a) upstream unix echo server: the client's request
   arrives and its reply returns; (b) port already bound: launch fails
   "forwarder exited", entry never runs; (c) the entry's exit status is the
   wrapper's; (d) readiness makes no upstream connection.
6. `workspaceDepsFromEnv` (impure: `impureChecks.<system>.jailed-agents-env`,
   built by `just test` with `--impure` and `JAIL_WORKSPACE_DEPS` set; refuses
   pure eval): default binds the env and static deps; `false` binds only the
   static ones.
7. `persistedHome` per profile replaces the profile's home; default argv
   unchanged; a name such as `../escape` fails evaluation.

Eval check: `nixosConfigurations.Sleipnir.config.systemd.sockets.llm-gateway-relay`
lists both streams with `SocketUser`/`SocketMode`; the relay service unit
carries `X-Restart-Triggers`.

VA (live, after `just system-switch`; by agent): the socket exists, owned by
the user, `0600`; an `offline` jail with `gateway` makes an authenticated
`/v1/models` request that succeeds; from that jail a connect to another
host port (e.g. `127.0.0.1:22`, a LAN address) fails; an existing TCP jail
still works.
<!-- doctrine:section sec-8 -->
## Governance follow-through

- SPEC-001 § Client contract (Reach) and § Perimeter: REV at reconcile, citing
  DEC-075 and DEC-077.
- satan:SL-027 consumes `gatewaySocketOptions`, `profile = "offline"`,
  `mountLaunchDir = false` (handback sent separately).
- CHR-020 (jail-library tech spec) inherits the profile table and the
  launch-dir option as content.
