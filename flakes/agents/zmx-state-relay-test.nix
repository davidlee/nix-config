# The zmx state relay (zmx-state-relay.nix): what a connection may do to the
# host session, the jail's client, and which launches start a listener.
{
  pkgs,
  jail-nix,
}: let
  inherit (import ./test-fixtures.nix {inherit pkgs jail-nix;}) agents fakeBwrapAgents zmxHarness;

  relay = import ./zmx-state-relay.nix {
    inherit pkgs;
    harness = zmxHarness;
    inherit (agents) combinators;
  };
  jail = agents.makeJailedZsh {};
  probe = fakeBwrapAgents.makeJailedZsh {};

  # A host zmx: logs each call with its stdin, and answers `get` with labels.
  # ZMX_HANG stands in for a session that never answers (ISS-003 in zmux).
  stubZmx = pkgs.writeShellScriptBin "zmx" ''
    echo "$* stdin=$(${pkgs.coreutils}/bin/readlink /proc/self/fd/0)" >> "$ZMX_LOG"
    echo "complaint" >&2
    if [ -n "''${ZMX_HANG:-}" ]; then ${pkgs.coreutils}/bin/sleep 30; fi
    if [ "$1" = get ]; then printf 'id=1 project=p state=working'; fi
  '';
in
  pkgs.runCommand "zmx-state-relay-tests" {
    nativeBuildInputs = with pkgs; [gnugrep gnused coreutils socat];
  } ''
    refute() {
      if "$@"; then
        echo "refute: holds, expected not to: $*" >&2
        exit 1
      fi
    }
    wait_for() {
      for _ in $(seq 100); do
        if eval "$1"; then return 0; fi
        sleep 0.05
      done
      echo "timed out waiting for: $1" >&2
      exit 1
    }
    t=$TMPDIR/relay
    mkdir -p "$t/run" "$t/project"
    export ZMX_LOG=$t/zmx.log
    : > "$ZMX_LOG"

    start_listener() {
      d=$(mktemp -d)
      env "$@" ZMX_SESSION=host.1 PATH=${stubZmx}/bin ${relay.listener} "$d" \
        < /dev/null 2> "$t/listener.err" &
      listener=$!
      wait_for "[ -S $d/socket/state.sock ]"
    }
    stop_listener() {
      kill -TERM "$listener"
      wait "$listener" || true
    }
    send() { printf '%s\n' "$1" | socat -t 5 - "UNIX-CONNECT:$d/socket/state.sock"; }

    # Every jail carries the listener and the client.
    grep -Fq -- '-zmx-state-jail-listener' ${jail}/bin/jailed-zsh
    grep -q -- '/nix/store/[^ :]*-zmx-state-jail-client/bin' ${jail}/bin/jailed-zsh

    # Each harness's hook is on the jail's PATH, and resolves to where it finds
    # advertise.sh, since a jail has no checkout to link to.
    grep -q -- '/nix/store/[^ :]*-zmx-state-jail-hooks/bin' ${jail}/bin/jailed-zsh
    for hook in zmx-state-claude zmx-state-codex; do
      [ -x ${relay.hooks}/bin/$hook ]
      [ -f "$(dirname "$(readlink -f ${relay.hooks}/bin/$hook)")/../advertise.sh" ]
    done

    # A harness's two values reach the launch's session, and the reply is its
    # labels. zmx's stderr stays off the harness's terminal.
    start_listener ZMX_LOG="$ZMX_LOG"
    for value in working blocked; do
      : > "$ZMX_LOG"
      [ "$(send "$value")" = 'id=1 project=p state=working' ]
      grep -Fxq -- "set host.1 state=$value stdin=/dev/null" "$ZMX_LOG"
      grep -Fxq -- 'get host.1 stdin=/dev/null' "$ZMX_LOG"
    done
    refute grep -Fq complaint "$t/listener.err"

    # Anything else writes nothing and answers nothing: the dispatcher's
    # values, a second label, another session, and more than one value.
    : > "$ZMX_LOG"
    for value in done failed "" 'working role=x' 'state=working' \
      'set other.1 state=blocked' "$(printf 'working%.0s' {1..40})"; do
      [ -z "$(send "$value")" ]
    done
    [ ! -s "$ZMX_LOG" ]

    # The client: the jail's path pointed at this listener, so one connection
    # runs end to end. Its argument is the value, its output the reply.
    sed "s|${relay.jailDir}|$d/socket|g" ${relay.client}/bin/zmx-state > "$t/client"
    chmod +x "$t/client"
    : > "$ZMX_LOG"
    "$t/client" blocked > "$t/client.out"
    grep -Fxq -- 'id=1 project=p state=working' "$t/client.out"
    grep -Fq -- 'set host.1 state=blocked' "$ZMX_LOG"
    stop_listener
    refute test -e "$d"

    # A session that never answers can't hold a hook for long.
    start_listener ZMX_LOG="$ZMX_LOG" ZMX_HANG=1
    began=$SECONDS
    send working > /dev/null || true
    [ $((SECONDS - began)) -lt 15 ]
    stop_listener

    # Outside a jail with a relay, the client is silent and succeeds.
    [ -z "$(${relay.client}/bin/zmx-state working)" ]

    launch() {
      rm -f "$t/project/bwrap-argv"
      (cd "$t/project" && env -i LANG=C.UTF-8 HOME="$t" XDG_RUNTIME_DIR="$t/run" "$@" ${probe}/bin/jailed-zsh)
    }
    argv=$t/project/bwrap-argv

    # In a session: the socket directory bound read-only, and the listener
    # gone with the launcher. The session's name stays on the host.
    launch PATH=${stubZmx}/bin ZMX_SESSION=host.1
    grep -B2 -Fx -- ${relay.jailDir} "$argv" | head -1 | grep -Fxq -- --ro-bind
    src=$(grep -B1 -Fx -- ${relay.jailDir} "$argv" | head -1)
    case "$src" in "$t"/run/jail-zmx-state.*/socket) ;; *) echo "bind source: $src" >&2; exit 1 ;; esac
    refute grep -Fq -- host.1 "$argv"
    wait_for "[ ! -e $(dirname "$src") ]"

    # No session, or no host zmx: the jail launches without the relay.
    launch PATH=${stubZmx}/bin
    refute grep -Fq -- ${relay.jailDir} "$argv"
    launch PATH=/nonexistent ZMX_SESSION=host.1
    refute grep -Fq -- ${relay.jailDir} "$argv"

    touch "$out"
  ''
