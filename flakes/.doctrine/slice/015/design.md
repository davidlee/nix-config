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
created by PID 1. The relay service is unchanged: one `systemd-socket-proxyd`
serves both fds (research P2). The client socket belongs to the socket unit, so
gateway restarts do not recreate it.
<!-- doctrine:section sec-3 -->
## Transport and forwarder (DEC-076)

**Profiles carry their network flag.** One table replaces `profileOptions`'
literal `network` entries:

```nix
profiles = {
  specDev  = { network = true;  options = [(persist-home "agent")]; };
  research = { network = true;  options = [(persist-home "agent-research")]; };
  offline  = { network = false; options = [(persist-home "agent-offline")]; };
};
profileOptions = p: profiles.${p}.options ++ lib.optional profiles.${p}.network jail.combinators.network;
```

`profileDefaults` (git and op toggles) stays separate: those are caller-overridable,
network is not.

**The forwarder** is a pure function of its endpoints, so the test can use a
temporary socket and port:

```
gatewayForwarder = { socket, port }: [
  (ro-bind (dirOf socket) (dirOf socket))
  (wrap-entry (entry: ''
     socat TCP-LISTEN:<port>,bind=127.0.0.1,fork,reuseaddr UNIX-CONNECT:<socket> &
     pid=$!
     # ready: socat alive AND /proc/net/tcp lists 0100007F:<PORTHEX> in state 0A (LISTEN)
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
| `features/agents/gateway.nix` | relay socket: second listener, ownership |
| `agents/jailed-agents.nix` | `profiles` table; `gatewayForwarder` / `gatewaySocketOptions`; launch-dir out of `baseJailOptions`, `mountLaunchDir`; socket-mode wiring and pre-flight; export |
| `agents/jailed-agents-test.nix` | tests (sec-7) |
| `agents/README.md` § Gateway mode | socket mode, `gatewaySocketOptions`, `mountLaunchDir` |
| `README.md` § LLM gateway | the client socket in the topology diagram |

No change to `agents/flake.nix` wiring: `checks.jailed-agents` already imports
the test file.
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
   wrapper's.

Eval check: `nixosConfigurations.Sleipnir.config.systemd.sockets.llm-gateway-relay`
lists both streams with `SocketUser`/`SocketMode`.

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
