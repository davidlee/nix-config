# agents/gateway-forwarder.nix — socket mode (DEC-076): a jail without network
# reaches the LLM gateway through the relay's client unix socket.
#
#   gatewayForwarder { socket; port; source ? null; }  ->  { bind; entry; }
#
#   bind   a read-only bind of the socket's DIRECTORY: a file bind pins one
#          inode and goes stale when the relay replaces the socket; a
#          read-only directory also stops the jail replacing it. Its host
#          side is `source` when given (a shell word the launcher expands,
#          gateway.clientDirectory), else the directory itself.
#   entry  socket-forwarder.nix's forwarderEntry: the in-jail socat on <port>,
#          relaying to the socket, and the guard against a shared netns.
#
# Two parts, so a caller can place the entry apart from the bind: the gateway
# applies it last, the outermost wrap (gateway-jail.nix).
{
  pkgs,
  combinators,
}: let
  forwarderEntry = import ./socket-forwarder.nix {inherit pkgs combinators;};
in
  {
    socket,
    port,
    source ? null,
  }: let
    dir = dirOf socket;
  in {
    bind = [
      (
        if source == null
        then combinators.ro-bind dir dir
        else combinators.unsafe-add-raw-args "--ro-bind \"${source}\" ${pkgs.lib.escapeShellArg dir}"
      )
    ];
    entry = forwarderEntry {inherit socket port;};
  }
