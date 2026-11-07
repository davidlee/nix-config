# agents/launch-relay.nix — a host listener that lives as long as one launch.
#
#   host                                          jail
#   launcher
#    ├─ <name>-jail-listener DIR  (pdeathsig) ◄── DIR/socket, read-only ── <jailDir>/<socket>
#    │    per connection: <handler> DIR/private
#    └─ exec bwrap
#
# The socket reaches one jail only, so what a handler may do is decided at
# launch and no caller needs to identify itself.
{pkgs}: {
  name,
  jailDir,
  socket,
  handler,
}: let
  # `<name>-jail-listener DIR`: serves DIR/socket/<socket>, one handler per
  # connection, until TERM; then removes DIR. DIR is the launcher's mktemp
  # (0700); only DIR/socket is bound into the jail, so what a handler keeps in
  # DIR/private is not in the jail's view.
  listener = pkgs.writeShellScript "${name}-jail-listener" ''
    set -euo pipefail
    dir=$1
    ${pkgs.coreutils}/bin/mkdir -m 700 "$dir/socket" "$dir/private"
    # -d0: errors only, not the warning TERM brings at every jail exit.
    # Store paths and DIR only: socat splits EXEC's command on spaces, so
    # anything else a handler needs travels in the environment.
    ${pkgs.socat}/bin/socat -d0 UNIX-LISTEN:"$dir/socket/${socket}",fork,umask=077 \
      EXEC:"${handler} $dir/private" < /dev/null > /dev/null &
    relay=$!
    trap 'kill "$relay" 2>/dev/null || true; wait "$relay" 2>/dev/null || true; ${pkgs.coreutils}/bin/rm -rf -- "$dir"' EXIT
    trap 'exit 0' TERM INT HUP
    wait "$relay"
  '';
in {
  inherit listener;

  # The launcher's part, for an add-runtime: start the listener, wait for the
  # socket (about 2 s), bind its directory read-only. The listener dies with
  # the launcher, whose pid bwrap keeps (exec), by pdeathsig. `env` is shell
  # text: assignments for the listener's environment.
  launch = env: ''
    relay_dir=$(mktemp -d "''${XDG_RUNTIME_DIR:-/tmp}/jail-${name}.XXXXXX")
    ${env} ${pkgs.util-linux}/bin/setpriv --pdeathsig TERM ${listener} "$relay_dir" < /dev/null > /dev/null &
    for _ in {1..40}; do
      [ -S "$relay_dir/socket/${socket}" ] && break
      sleep 0.05
    done
    RUNTIME_ARGS+=(--ro-bind "$relay_dir/socket" ${jailDir})
  '';
}
