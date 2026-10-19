# Gateway and launch-dir options for network-isolated jails

## Context

satan:SL-027 (malebolge daemon "vm mode", `doctrine show SL-027` in
`~/dev/satan`) moves the interactive daemon's coding tools into oubliette room
`assistant`. Its jail becomes a **room profile**: no network
(`--unshare-net`), no launch dir. satan:CON-005 binds it: egress and room are
mutually exclusive by construction; a profile is a host jail, never a daemon
flag; two later profiles ("egress", "host") must stay possible.

Three things in this repo stand in the way. This slice lands before SL-027.

```
today                                        room profile (after)
jail (host netns)                            jail (--unshare-net)
  client ──127.0.0.1:4000──┐                   client ──127.0.0.1:4000──> socat (in jail)
                           │                                                 │ dir bind
host                       ▼                 host                            ▼
  llm-gateway-relay (TCP :4000)                llm-gateway-relay, unix instance
        │ SupplementaryGroups                    /run/llm-gateway-client/api.sock (user, 0600)
        ▼                                              │
  /run/llm-gateway/api.sock (0750 dir) <───────────────┘   group gate unchanged
```

1. **Gateway reach.** The relay listens only on host loopback TCP
   (`features/agents/gateway.nix:126-143`). A jail with its own netns has its
   own loopback and cannot reach it. The gateway's own socket sits in a `0750`
   directory owned by `llm-gateway`; the user is not in that group (DEC-047's
   access gate), so binding it into a user jail does not connect.
2. **No connection choice in jailLib.** `gateway` (`agents/gateway.nix`
   `client`) is `{ keyFile; url; runDirectory; }`: TCP only.
3. **The launch-dir bind is unconditional.** `baseJailOptions`
   (`agents/jailed-agents.nix:169-178`) binds `$PWD` rw at
   `/workspace/<basename>` and chdirs there for every jail, under a comment
   calling it "not policy-bearing". It is policy-bearing: it is the host write
   behind satan:CHR-020 (the daemon launched from `~/notes` can write the
   user's notes). (This repo's own CHR-020 is unrelated: the jail-library tech
   spec.)

Room ssh is not a gap: oubliette's door is already a unix socket
(`ProxyCommand=socat - UNIX-CONNECT:/run/capsule-room/assistant/ssh.sock`,
oubliette `host/guest-ssh.nix:184`).

## Scope & Objectives

1. **Relay: one socket unit, two listeners (DEC-075).** The existing
   `llm-gateway-relay` socket unit gains a unix listener,
   `/run/llm-gateway-client/api.sock`, owned by the user, mode `0600`; one
   `systemd-socket-proxyd` serves both (research P2), so "one definition, two
   instances" needs no second unit. The original `/run/llm-gateway/api.sock`
   keeps its group gate. Path is a constant in `agents/gateway.nix`, shared
   by the system and home evaluations (ADR-004 D4).
2. **Decision extending DEC-047 (DEC-077).** DEC-047 rejected "bind the socket into the
   jail and forward inside it" only because jails shared the host netns, so an
   in-jail listener was host-wide. In an `--unshare-net` jail that reason does
   not hold: the listener exists only in the jail. Record a decision that
   extends DEC-047 (one gateway socket, keys authenticate) with a second client
   transport. It states plainly: **in the room profile the gateway is the
   only direct network path, bounded by the key's model list and budget**;
   bound host unix sockets are the jail definition's to audit.
3. **Gateway transport in jailLib, derived from the profile (DEC-076).**
   TCP when the profile has network, socket when it has none; not a caller's
   choice (the brief asked for a choice; changed by the user, 2026-10-20). In
   socket mode the launcher binds the socket's **directory**, read-only, not
   the file (satan:ISS-042: a file bind pins the inode, so a recreated socket
   is unreachable), and starts
   `socat TCP-LISTEN:4000,bind=127.0.0.1,fork UNIX-CONNECT:<sock>` in the jail
   before exec. Clients keep `http://127.0.0.1:4000/v1` unchanged. The option
   list is exported (`gatewaySocketOptions`) for jails without `gateway`. The
   wrapper's pre-flight check names the socket mode's prerequisite, as it
   does for TCP today.
4. **Optional launch-dir bind (DEC-078).** An option on `makeJailedAgent` (default:
   bound, as today); off, the jail starts in `"$HOME"`. The bind leaves
   `baseJailOptions`, whose "not policy-bearing" comment then holds.
5. **openssh for room clients: checked, out of scope.** The ssh client runs
   in the room-client jail; the satan jail adds it and renders its own
   ProxyCommand; oubliette IMP-022 is the long-term home (inq-6, handed back
   to satan:SL-027).

## Non-Goals

- The jail definition itself: `jailed-malebolge` stays in
  `~/dev/satan/flake.nix`.
- malebolge code (including whether its client could use a `socketPath`
  directly; unverified, so the forwarder is the default).
- oubliette.
- The "egress" and "host" profiles.
- Moving existing jails to socket mode.

## Affected surface

- `features/agents/gateway.nix`: relay socket/service units.
- `agents/gateway.nix`: client socket constants; `client`'s shape.
- `agents/jailed-agents.nix`: `baseJailOptions`, gateway options and wrapper
  check, `makeJailedAgent` arguments, exports.
- `agents/jailed-agents-test.nix` (and the fake-bwrap probes); possibly a
  NixOS VM test for the relay.
- `agents/README.md` § Gateway mode; `README.md` § LLM gateway.
- `.doctrine/` decision extending DEC-047.

## Risks, assumptions, open questions

Design resolutions (DEC-075 relay listener, DEC-076 transport from profile,
DEC-077 extends DEC-047, DEC-078 launch-dir option) close OQ-1..OQ-4; A-1 and
A-2 are verified (`research/raw/probes.md`).

- **OQ-1: key custody vs reach.** `jailed-malebolge` passes no `gateway`: it
  reads its key from a file and ignores `LLM_GATEWAY_KEY` (SL-023 PHASE-18),
  so a connection choice that lives only inside `gateway` never reaches it.
  Reach (transport) and key delivery (env over fd 22, or a key file) may need
  to be separate arguments. Design settles the shape.
- **OQ-2: gateway on `offline` today.** `offline` has no `network`
  combinator, so a TCP gateway on it is unreachable, silently. Should
  jailLib refuse TCP mode without network, or pick socket mode for it?
- **OQ-3: socket ownership.** `SocketUser=` names a fixed user. Where the
  owner comes from (the host's user, not a literal) under ADR-004.
- **OQ-4: socat lifetime.** It must die with the jail and be up before the
  client's first request (bind before exec; `fork` per connection).
- **A-1:** jail.nix without the `network` combinator unshares the netns and
  brings up loopback, so `127.0.0.1:4000` is bindable inside. Verify in
  research.
- **A-2:** `systemd-socket-proxyd` runs under a unix `ListenStream=` socket
  unit unchanged (it accepts whatever fd systemd hands it).
- **Risk:** the unix socket lets every process of the user reach the gateway,
  as the TCP port already lets every local process. Keys stay the
  authentication; this widens nothing.

## Verification / closure intent

- A jail on `offline` in socket mode reaches the gateway (an authenticated
  request succeeds) and cannot reach any other host port.
- An existing TCP-mode jail is unchanged (launcher diff empty, or the
  existing tests pass unmodified).
- A jail with the launch dir off has no `/workspace/<launch-dir>` mount and
  starts in the chosen directory.
- The original socket's directory is still `0750 llm-gateway`.
- `just test` green; `just coverage` evaluates.

## Summary

Lets a network-isolated jail use the LLM gateway, through a unix-socket relay
instance and an in-jail forwarder, and makes the launch-dir bind optional.
Prerequisite for satan:SL-027's room profile.

## Follow-Ups

- satan:SL-027 consumes this: `jailed-malebolge` on `offline`, socket mode,
  launch dir off.
- Moving existing jails that need no network to socket mode.
