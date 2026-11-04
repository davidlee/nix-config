The sccache server, not the client, runs rustc, so build scripts and proc macros
run wherever the server lives. Networked jails share the host's loopback: a
server on the default TCP 127.0.0.1:4226 serves both sides, and a jailed cargo
then compiles unconfined on the host. Symptom: ENOENT writing a jail-only path
such as /tmp/... DEC-121 gives each side a unix socket through
`SCCACHE_SERVER_UDS` (host: $XDG_RUNTIME_DIR; jail: /tmp). RSK-001 covers the
wider loopback exposure.

To test hits, clean and rebuild in one target dir: the cache key includes the
output path, so a different CARGO_TARGET_DIR gives 0 hits, not a broken cache.

Quotient forms start without ~/.cargo, so `cargo --offline` fails there with
"no matching package"; that is an empty registry, not a form fault.


The host socket stays reachable from any jail that exposes all of `/`, such as
Doctrine's dispatch prefix (`--ro-bind / /`, env inherited). There, an inherited
host address fails with `Server startup failed: Read-only file system`, or reaches
a host server if one runs. Such a jail must set its own `SCCACHE_SERVER_UDS`;
`doctrine:scripts/spawn-confined.sh` does (RV-047 F-1).
