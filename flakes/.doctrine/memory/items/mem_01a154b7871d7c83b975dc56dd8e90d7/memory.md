switch-to-configuration-ng (`handle_modified_unit`, pinned nixpkgs `pkgs/by-name/sw/switch-to-configuration-ng/src/src/main.rs`):

- A changed `.socket` unit hits a FIXME branch and nothing happens (NixOS#74899). New ListenStream / SocketUser / SocketMode never take effect on switch.
- A changed, **active** `.service` with an associated socket (`Sockets=` or `<name>.socket`) is stopped together with the socket — but only if the socket is **active** (`active_cur.contains_key(socket)`) — and the socket is started instead of the service.
- An inactive service is not compared at all.

Fix used for `llm-gateway-relay` (SL-015): `restartTriggers = [config.systemd.units."<name>.socket".unit];` on the service. Proven live 2026-10-20.

Footguns:
- Socket-activated services are often idle at switch time → wake one first (e.g. a keyless `curl` to the port), or the trigger is skipped.
- `systemctl restart <x>.socket` while its service runs is refused ("Socket service ... already active, refusing") and leaves the socket **inactive** with the service holding the fds. A switch in that state stops the service and starts nothing → the listener is gone. Recover: stop the service, `reset-failed` both, start the socket (never the service: systemd-socket-proxyd fails "Didn't get any sockets passed in").
- Use `dry-activate` to preview: it prints "would stop/start" lists.

See README § LLM gateway "Relay restart" for the state table.
