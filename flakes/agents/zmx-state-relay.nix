# agents/zmx-state-relay.nix — a jailed harness advertises `state` on the host
# zmx session it was launched in (IMP-070).
#
#   host                                        jail
#   launcher ($ZMX_SESSION: the session)
#    ├─ zmx-state-jail-listener DIR  ◄── DIR/socket, read-only ── /run/zmx-state/state.sock
#    │    per connection, one line:                                  ▲
#    │      working | blocked -> zmx set                             │
#    │      reply: zmx get                          `zmx-state VALUE`: socat ─┘
#    └─ exec bwrap
#
# A session's own socket is a whole client: a jail holding it could `zmx send`.
# This one writes one label, with the two values a harness owns (`done` and
# `failed` are a dispatcher's), on a session the jail never names. The reply is
# that session's labels, which are claims, not secrets (zmux VOCABULARY.md).
#
# The host's zmx, found on the launching PATH: the session's daemon is the
# host's, and zmx's socket is an unstable ABI. So not the jail's pinned wrapper.
# No session or no host zmx: the jail launches without the relay, and
# `zmx-state` does nothing, as it does outside a session on the host.
{
  pkgs,
  combinators,
}: let
  jailDir = "/run/zmx-state";
  socket = "state.sock";
  coreutils = "${pkgs.coreutils}/bin";
  # Short enough that a hook's own limit is never what ends it.
  zmxTimeout = "${coreutils}/timeout 3";

  # One connection, on stdin and stdout. `zmx` gets no stdin of the jail's, and
  # its complaints stay off the terminal the launcher shares with the harness.
  handler = pkgs.writeShellScript "zmx-state-jail-handler" ''
    exec 2> /dev/null
    IFS= read -r -t 1 -n 16 value || exit 0
    case $value in working | blocked) ;; *) exit 0 ;; esac
    ${zmxTimeout} zmx set "$ZMX_SESSION" "state=$value" < /dev/null > /dev/null || exit 0
    exec ${zmxTimeout} zmx get "$ZMX_SESSION" < /dev/null
  '';

  relay = import ./launch-relay.nix {inherit pkgs;} {
    name = "zmx-state";
    inherit jailDir socket handler;
  };

  # The jail's `zmx-state`: the host's name and contract, so a harness doesn't
  # know it is jailed.
  client = pkgs.writeTextFile {
    name = "zmx-state-jail-client";
    destination = "/bin/zmx-state";
    executable = true;
    text = ''
      #!${pkgs.runtimeShell}
      [ -S ${jailDir}/${socket} ] || exit 0
      printf '%s\n' "$1" | ${coreutils}/timeout 5 ${pkgs.socat}/bin/socat -t 4 - UNIX-CONNECT:${jailDir}/${socket}
    '';
  };

  # Runtime args, off the bwrap line (IMP-052). The listener inherits
  # ZMX_SESSION and PATH from the launcher.
  options = with combinators; [
    (add-runtime ''
      if [ -n "''${ZMX_SESSION:-}" ] && command -v zmx > /dev/null; then
        ${relay.launch ""}
      fi
    '')
    (add-pkg-deps [client])
  ];
in {
  inherit options client jailDir;
  inherit (relay) listener;
}
