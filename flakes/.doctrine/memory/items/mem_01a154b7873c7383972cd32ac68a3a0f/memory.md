Readiness check that makes no connection (a probe connection could reach the upstream or a foreign listener): read /proc/net/tcp (per network namespace), find the row with local address `0100007F:<PORTHEX>` (127.0.0.1, little-endian hosts; port uppercase hex, 4 wide) in state `0A` (LISTEN), then require its inode to match one of `/proc/<pid>/fd/*` → `socket:[<inode>]` of the process you started.

Why the inode tie: if the port is already held by another process, a row exists while your process is still starting and about to fail EADDRINUSE; row-only readiness would declare success and hand traffic to the foreign listener. Pair it with `kill -0 <pid>` in the loop so an early exit fails fast.

Implementation: `agents/gateway-forwarder.nix` (SL-015 PHASE-03); a mutation test that drops the inode tie makes the occupied-port case fail.

Also: a real jail launcher run inside a nix build sandbox test needs `LANG` and `TERM` set, or it fails "LANG: unbound variable".
