# IMP-070: Relay zmx state out of jails through a per-launch socket

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Handoff from zmux: `zmux:IMP-009`. A jailed agent can't advertise `state`: the jail clears
`ZMX_SESSION` and has no host zmx socket directory, so the state hooks write nothing. Binding a
session socket would hand the jail a whole zmx client, including `zmx send`. Agreed sketch, no
slice (operator, 2026-11-07).

## Why here

zmux cannot host it: `zmux:ADR-001` rules out a daemon, `zmux:ADR-003` keeps integrations out of
the wrapper. The relay is one more caller writing a label, as zsh's title hook and the harness
hooks are, so it adds no status protocol.

## Why the quotient relay, not the gateway

The scope is "the session this jail started in", known only at launch. A per-launch socket bound
into one jail carries that by construction. The gateway's shared socket would need a token per
session.

## Sketch

```
host                                      jail
launcher (ZMX_SESSION known here)
 ├─ listener DIR (pdeathsig) ◄── DIR/socket, ro ── /run/zmx-state/state.sock
 │    per connection, one line:                      ▲
 │    "working"|"blocked"                            │
 │    → zmx set $SESSION state=…              zmx-state VALUE (socat)
 │    ← zmx get $SESSION (the reply)                 ▲
 └─ exec bwrap                                 harness hook / pi extension
```

- `agents/`: extract the launcher-listener mechanics from `quotient-relay.nix`, and use them for
  both relays.
- The listener starts only when the launcher has `ZMX_SESSION`. Otherwise nothing runs and the
  jail's `zmx-state` exits 0. Forms get no relay.
- Allowed values are `working` and `blocked`: `done` and `failed` are the dispatcher's
  (`zmux:ADR-002`). The session name never comes from the jail.
- The reply is the session's labels, so the title needs no second verb.
- `zmx-state` has one name on both sides, like the `quotient` shim: zmux ships the host one,
  this item the jail one. Harnesses don't know they are jailed.
- Run `zmx` with stdin closed (`zmux:ISS-003`) and under a timeout, so a hung session can't stall
  a hook.
- Jail home: add the zmux hooks to `.local/share/jail.nix/home/agent/.claude/settings.json`, and
  bump pi's pin.
- SPEC-003 § What each surface gets gains a row, by revision.

## Accepted limits

- A harness in a jail-local zmx session writes to the host session.
- The title shows the jail's `$PWD`.

## Check first

`ZMX_SESSION` reaching the launcher through `jcl` and friends is inferred from `zmx-new`, not
observed.

Related: IMP-068, IMP-066, RSK-001, SPEC-003, DEC-122.
