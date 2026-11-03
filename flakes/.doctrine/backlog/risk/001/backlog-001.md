# RSK-001: Networked jails share host loopback: any host 127.0.0.1 service is reachable

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

## Risk

Jails with network (profiles `specDev`, `research`, …) share the host's network
namespace, so every service the host binds on 127.0.0.1 is reachable from a
jailed agent. The LLM gateway (127.0.0.1:4000) is meant to be; nothing else is.

Found in SL-023 PHASE-07 (F-1): a host sccache server on 127.0.0.1:4226 accepted
a jailed `cargo`'s compiles and ran rustc (build scripts, proc macros —
arbitrary code) **unconfined on the host**. That instance is closed in SL-023
(both sides on unix sockets, host's under `$XDG_RUNTIME_DIR`, which no jail
binds), but the class is open: any other loopback listener (dev servers,
debuggers, editor/LSP daemons, databases on TCP, sccache started without
`SCCACHE_SERVER_UDS`) is equally reachable.

## Direction (operator, 2026-11-04)

A loopback port filter is not enough: "it needs stronger medicine". The model
must still reach the gateway. Candidates:

- every jail gets its own network namespace; the gateway arrives only through
  the client socket (the offline profile's socket mode, already built), and
  outbound web access through an explicit egress proxy;
- or slirp/pasta-style user networking that does not expose host loopback.

Until then: treat any host TCP loopback listener as reachable by jailed agents.
