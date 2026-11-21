# agents/gateway-forwarder.nix — socket mode (DEC-076): a jail without network
# reaches the LLM gateway through the relay's client unix socket.
#
#   gatewayForwarder { socket; port; }  ->  jail.nix permissions
#
#   1. a read-only bind of the socket's DIRECTORY: a file bind pins one inode
#      and goes stale when the relay replaces the socket; a read-only directory
#      also stops the jail replacing it.
#   2. socket-forwarder.nix's forwarderEntry: the in-jail socat on <port>,
#      relaying to the socket, and the guard against a shared netns.
{
  pkgs,
  combinators,
}: let
  forwarderEntry = import ./socket-forwarder.nix {inherit pkgs combinators;};
in
  # `...`: forwarderEntry's own pattern takes the rest, and refuses extras.
  {socket, ...} @ args:
    [(combinators.ro-bind (dirOf socket) (dirOf socket))]
    ++ forwarderEntry args
