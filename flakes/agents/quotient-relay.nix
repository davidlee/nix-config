# agents/quotient-relay.nix — the host's quotient, reachable from a jail.
#
#   host                                         jail
#   launcher ($PWD: the root)
#    ├─ quotient-jail-listener DIR  (pdeathsig) ◄── DIR/socket, read-only ── /run/quotient/mcp.sock
#    │    per connection: quotient-jail-server                                 ▲
#    │      narrowed policy, cd root, exec quotient                            │
#    │        └─ forms ─► pi delegates                     `quotient`: socat STDIO ─┘
#    └─ exec bwrap
#
# quotient runs on the host, never nested: its policy, approvals and run
# evidence stay out of the jail's reach (`quotient help form`, G6), and its
# forms are host jails as ever. Its delegates get no relay, so there is no
# recursion.
#
# The jail gets no more reach through quotient than it has itself: the policy
# each connection runs under is the host's, narrowed to the launch dir alone
# (narrowPolicy). Rebuilt per connection, so a host edit (`enabled: false`)
# applies from the next one.
#
# The host's own quotient, found on the launching PATH, as host doctrine is:
# no pin here. None, or a launch dir outside every host root: the jail
# launches without the relay, and `quotient` in the jail says so.
{
  pkgs,
  combinators,
}: let
  jailDir = "/run/quotient";
  socket = "mcp.sock";
  jq = "${pkgs.jq}/bin/jq";
  realpath = "${pkgs.coreutils}/bin/realpath";

  # `quotient-jail-policy ROOT rw|ro`: the host policy, found as quotient
  # finds it (QUOTIENT_POLICY, else <xdgConfig>/quotient/policy.json),
  # narrowed for a jail rooted at ROOT, on stdout. ROOT must be resolved
  # and inside a host root, by path component; refused otherwise.
  # - roots: [ROOT];
  # - exposure: only what is inside ROOT;
  # - ro (a read-only launch dir): no write profile, form or exposure.
  narrowPolicy = pkgs.writeShellScript "quotient-jail-policy" ''
    set -euo pipefail
    root=$1 access=$2
    case "$access" in rw | ro) ;; *) echo "quotient-jail-policy: access must be rw or ro: $access" >&2; exit 64 ;; esac
    if [ -n "''${QUOTIENT_POLICY+x}" ]; then
      policy=$QUOTIENT_POLICY
    elif [[ "''${XDG_CONFIG_HOME:-}" == /* ]]; then
      policy=$XDG_CONFIG_HOME/quotient/policy.json
    else
      policy=$HOME/.config/quotient/policy.json
    fi
    [ -r "$policy" ] || { echo "quotient-jail-policy: no policy at $policy" >&2; exit 1; }
    # Roots resolved as quotient resolves them; a missing one contains nothing.
    roots=$(${jq} -r '.roots[]' "$policy" | while IFS= read -r r; do
      ${realpath} -e -- "$r" 2>/dev/null || true
    done | ${jq} -R . | ${jq} -s .)
    ${jq} -e --arg root "$root" --arg access "$access" --argjson resolved "$roots" '
      def inside($dir): . == $dir or startswith(($dir | rtrimstr("/")) + "/");
      if any($resolved[]; . as $r | $root | inside($r)) | not then
        "quotient-jail-policy: \($root) is outside every root of the host policy\n" | halt_error(1)
      else . end
      | .roots = [$root]
      | .exposure |= map(select(inside($root)))
      | if $access == "ro" then
          .profiles |= with_entries(select(.value == "read"))
          | .forms |= del(.write)
          | .exposure = []
        else . end
    ' "$policy"
  '';

  # One connection's quotient: JAIL_QUOTIENT_{BIN,ROOT,ACCESS} name the host
  # quotient, the root and the access; POLICY_DIR (its one argument) is
  # where its narrowed policy goes. No JAIL_QUOTIENT_* reaches quotient.
  server = pkgs.writeShellScript "quotient-jail-server" ''
    set -euo pipefail
    bin=$JAIL_QUOTIENT_BIN root=$JAIL_QUOTIENT_ROOT access=$JAIL_QUOTIENT_ACCESS
    unset JAIL_QUOTIENT_BIN JAIL_QUOTIENT_ROOT JAIL_QUOTIENT_ACCESS
    policy=$(${pkgs.coreutils}/bin/mktemp "$1/policy.XXXXXX")
    ${narrowPolicy} "$root" "$access" > "$policy"
    cd "$root"
    QUOTIENT_POLICY=$policy exec "$bin"
  '';

  # `quotient-jail-listener DIR`: serves DIR/socket/mcp.sock, one server per
  # connection, until TERM; then removes DIR. DIR is the launcher's mktemp
  # (0700); only DIR/socket is bound into the jail, so the narrowed policies
  # beside it are not in the jail's view.
  listener = pkgs.writeShellScript "quotient-jail-listener" ''
    set -euo pipefail
    dir=$1
    ${pkgs.coreutils}/bin/mkdir -m 700 "$dir/socket" "$dir/policy"
    # -d0: errors only, not the warning TERM brings at every jail exit.
    # Store paths and DIR only: socat splits EXEC's command on spaces, so the
    # root and the binary travel in the environment.
    ${pkgs.socat}/bin/socat -d0 UNIX-LISTEN:"$dir/socket/${socket}",fork,umask=077 \
      EXEC:"${server} $dir/policy" < /dev/null > /dev/null &
    relay=$!
    trap 'kill "$relay" 2>/dev/null || true; wait "$relay" 2>/dev/null || true; rm -rf -- "$dir"' EXIT
    trap 'exit 0' TERM INT HUP
    wait "$relay"
  '';

  # The jail's `quotient`: the host's name, so one MCP registration
  # (`command: quotient`) serves host and jail.
  shim = pkgs.writeTextFile {
    name = "quotient-jail-shim";
    destination = "/bin/quotient";
    executable = true;
    text = ''
      #!${pkgs.runtimeShell}
      if [ ! -S ${jailDir}/${socket} ]; then
        echo "quotient: no host quotient in this jail (none on the launching PATH, or the launch dir is outside the host policy's roots)" >&2
        exit 69
      fi
      exec ${pkgs.socat}/bin/socat STDIO UNIX-CONNECT:${jailDir}/${socket}
    '';
  };

  # The launcher's part: start the listener if there is a host quotient and
  # the root is inside its policy, wait for the socket (about 2 s), bind its
  # directory read-only. The listener dies with the launcher, whose pid
  # bwrap keeps (exec), by pdeathsig. Runtime args, off the bwrap line
  # (IMP-052).
  options = {readOnly}: let
    access =
      if readOnly
      then "ro"
      else "rw";
  in
    with combinators; [
      (add-runtime ''
        if quotient_bin=$(command -v quotient) &&
          quotient_root=$(pwd -P) &&
          ${narrowPolicy} "$quotient_root" ${access} > /dev/null; then
          quotient_dir=$(mktemp -d "''${XDG_RUNTIME_DIR:-/tmp}/jail-quotient.XXXXXX")
          JAIL_QUOTIENT_BIN=$quotient_bin JAIL_QUOTIENT_ROOT=$quotient_root JAIL_QUOTIENT_ACCESS=${access} \
            ${pkgs.util-linux}/bin/setpriv --pdeathsig TERM ${listener} "$quotient_dir" < /dev/null > /dev/null &
          for _ in {1..40}; do
            [ -S "$quotient_dir/socket/${socket}" ] && break
            sleep 0.05
          done
          RUNTIME_ARGS+=(--ro-bind "$quotient_dir/socket" ${jailDir})
        fi
      '')
      (add-pkg-deps [shim])
    ];
in {
  inherit options narrowPolicy listener shim;
}
