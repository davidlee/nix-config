Probed on Sleipnir, 2026-10-20 (SL-015 research/raw/probes.md, P1-P3).

- jail.nix unshares the net namespace unless a combinator shares it (`network` = `share-ns "net"`). In an `--unshare-net` jail loopback is up: a listener on 127.0.0.1:N inside is reachable inside. The host's 127.0.0.1 services are NOT ("Connection refused"); other addresses are "Network is unreachable".
- So a host TCP service reaches such a jail only through a bound unix socket. A read-only bind of the socket's DIRECTORY suffices to connect (connect() is not a filesystem write) and stops the jail replacing the socket. Bind the directory, not the file: a file bind pins the inode (satan:ISS-042).
- One `systemd-socket-proxyd` process serves every listening fd systemd passes it: TCP and unix `ListenStream=`s on one socket unit share one service. `SocketUser=`/`SocketMode=` apply to the unix ones only.
- jail.nix `defer` runs a combinator after all others, including a jail's `extraOptions`; `state.namespaces.net` is then final. Use it for evaluation-time guards on the composed jail (SL-015 DEC-076).
- Testing: the nix build sandbox has no user namespaces (no real bwrap), but has its own netns with loopback, so socat-based behaviour tests run there without bwrap.
