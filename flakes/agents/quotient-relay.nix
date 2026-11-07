# agents/quotient-relay.nix — the host's quotient, reachable from a jail.
#
#   host                                         jail
#   launcher ($PWD: the root)
#    ├─ quotient-jail-listener DIR  (launch-relay.nix) ◄── DIR/socket, read-only ── /run/quotient/mcp.sock
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
  # quotient, the root and the access; POLICY_DIR (its one argument, the
  # listener's private directory) is where its narrowed policy goes. No JAIL_QUOTIENT_* reaches quotient.
  server = pkgs.writeShellScript "quotient-jail-server" ''
    set -euo pipefail
    bin=$JAIL_QUOTIENT_BIN root=$JAIL_QUOTIENT_ROOT access=$JAIL_QUOTIENT_ACCESS
    unset JAIL_QUOTIENT_BIN JAIL_QUOTIENT_ROOT JAIL_QUOTIENT_ACCESS
    policy=$(${pkgs.coreutils}/bin/mktemp "$1/policy.XXXXXX")
    ${narrowPolicy} "$root" "$access" > "$policy"
    cd "$root"
    QUOTIENT_POLICY=$policy exec "$bin"
  '';

  relay = import ./launch-relay.nix {inherit pkgs;} {
    name = "quotient";
    inherit jailDir socket;
    handler = server;
  };

  # The jail's `quotient`: the host's name, so one MCP registration
  # (`command: quotient`) serves host and jail. Only that bare form is
  # relayed; an MCP stream would be no answer to anything else (ISS-026).
  shim = pkgs.writeTextFile {
    name = "quotient-jail-shim";
    destination = "/bin/quotient";
    executable = true;
    text = ''
      #!${pkgs.runtimeShell}
      if [ "$#" -gt 0 ]; then
        echo "quotient $*: only the MCP server is relayed into a jail; run it on the host" >&2
        exit 69
      fi
      if [ ! -S ${jailDir}/${socket} ]; then
        echo "quotient: no host quotient in this jail (none on the launching PATH, or the launch dir is outside the host policy's roots)" >&2
        exit 69
      fi
      exec ${pkgs.socat}/bin/socat STDIO UNIX-CONNECT:${jailDir}/${socket}
    '';
  };

  # Start the listener if there is a host quotient and the root is inside its
  # policy. Runtime args, off the bwrap line (IMP-052).
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
          ${relay.launch "JAIL_QUOTIENT_BIN=$quotient_bin JAIL_QUOTIENT_ROOT=$quotient_root JAIL_QUOTIENT_ACCESS=${access}"}
        fi
      '')
      (add-pkg-deps [shim])
    ];
in {
  inherit options narrowPolicy shim;
  inherit (relay) listener;
}
