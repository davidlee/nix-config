# agents/gateway-forwarder.nix — socket mode (DEC-076): a jail without network
# reaches the LLM gateway through the relay's client unix socket.
#
#   gatewayForwarder { socket; port; }  ->  three jail.nix permissions
#
#   1. a read-only bind of the socket's DIRECTORY: a file bind pins one inode
#      and goes stale when the relay replaces the socket; a read-only directory
#      also stops the jail replacing it.
#   2. a wrap-entry forwarder: socat listens on the jail's own 127.0.0.1:<port>
#      and relays each connection to the socket, so the gateway URL is the same
#      in every mode. The entry runs only once that socat is listening, and is
#      exec'd: it keeps the wrapper's PID, signals and exit status.
#   3. a deferred guard: in a jail that shares the host netns the forwarder
#      would collide with the relay's own listener, so that is an evaluation
#      error (`throw`, so tryEval can observe it).
#
# Readiness never connects: a probe connection would reach the gateway, or a
# foreign listener already on the port. Instead it reads /proc/net/tcp for a
# 127.0.0.1:<port> LISTEN row whose inode is one of OUR socat's descriptors.
# A row alone is not enough: another process holding the port has one too,
# while our socat is still starting up, just before it fails to bind.
{
  pkgs,
  combinators,
}: {
  socket,
  port,
}: let
  inherit (pkgs) lib;
  portHex = lib.fixedWidthString 4 "0" (lib.toHexString port); # uppercase, as /proc prints it
  loopbackHex = "0100007F"; # 127.0.0.1 as /proc/net/tcp prints it on little-endian hosts
  listenState = "0A"; # TCP_LISTEN
  attempts = 40; # times 0.05 s: about 2 s
  socat = "${pkgs.socat}/bin/socat";
  readlink = "${pkgs.coreutils}/bin/readlink";
  sleep = "${pkgs.coreutils}/bin/sleep";
  where = "127.0.0.1:${toString port}";
in
  with combinators; [
    (ro-bind (dirOf socket) (dirOf socket))
    # Runs under writeShellApplication (errexit, nounset, pipefail) with no
    # runtimeInputs: every tool by store path. stdin/stdout detached, so the
    # forwarder holds neither the agent's terminal nor a caller's pipe;
    # stderr kept, for socat's own diagnosis (e.g. address in use).
    (wrap-entry (entry: ''
      ${socat} TCP-LISTEN:${toString port},bind=127.0.0.1,fork,reuseaddr \
        ${lib.escapeShellArg "UNIX-CONNECT:${socket}"} </dev/null >/dev/null &
      forwarder=$!

      # Total: a vanished forwarder (no fds left) is "not listening".
      listening() {
        local addr st inode fd
        while read -r _ addr _ st _ _ _ _ _ inode _; do
          if [ "$addr" != ${loopbackHex}:${portHex} ] || [ "$st" != ${listenState} ]; then
            continue
          fi
          for fd in /proc/"$forwarder"/fd/*; do
            [ "$(${readlink} "$fd" 2>/dev/null || true)" = "socket:[$inode]" ] && return 0
          done
        done </proc/net/tcp
        return 1
      }

      ready=0
      for _ in {1..${toString attempts}}; do
        if listening; then
          ready=1
          break
        fi
        if ! kill -0 "$forwarder" 2>/dev/null; then
          echo "gateway forwarder exited before listening on ${where}" >&2
          exit 1
        fi
        ${sleep} 0.05
      done
      if [ "$ready" != 1 ]; then
        kill "$forwarder" 2>/dev/null || true
        echo "gateway forwarder not listening on ${where} after 2 s" >&2
        exit 1
      fi

      exec ${entry}
    ''))
    (defer (s:
      if s.namespaces.net or false
      then throw "gateway socket mode needs a jail without network (DEC-076)"
      else s))
  ]
