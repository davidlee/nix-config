# The quotient relay (quotient-relay.nix): which jails carry it, how the
# host policy is narrowed for a jail, and the host-side listener's life.
{
  pkgs,
  jail-nix,
}: let
  system = pkgs.stdenv.hostPlatform.system;

  fakeAgent = name: pkgs.writeShellScriptBin name "exit 0";
  fakeAgents.packages.${system} = {
    pi = fakeAgent "pi";
    claude-code = fakeAgent "claude";
  };

  # As jailed-agents-test.nix: a bwrap that records its argv, so a launch is
  # observable without namespaces.
  fakeBwrap = pkgs.writeShellScriptBin "bwrap" ''
    printf '%s\n' "$@" > bwrap-argv
  '';
  mkAgents = extra:
    import ./jailed-agents.nix ({
        inherit pkgs jail-nix;
        llm-agents = fakeAgents;
      }
      // extra);
  agents = mkAgents {};
  fakeBwrapAgents = mkAgents {
    pkgs = pkgs.extend (_: _: {bubblewrap = fakeBwrap;});
  };

  zsh = profile: args: agents.makeJailedZsh ({inherit profile;} // args);
  failsToEvaluate = value: !(builtins.tryEval value.drvPath).success;

  # Off unless a jail declares it (DEC-122); each twin differs in one argument.
  specDev = zsh "specDev" {};
  offline = zsh "offline" {};
  relayOn = zsh "specDev" {quotient = true;};
  offlineOn = zsh "offline" {quotient = true;};
  launchDirOff = zsh "specDev" {mountLaunchDir = false;};
  launchDirRo = zsh "specDev" {
    readOnlyLaunchDir = true;
    quotient = true;
  };
  noLaunchDirFails = failsToEvaluate (zsh "specDev" {
    mountLaunchDir = false;
    quotient = true;
  });
  probe = fakeBwrapAgents.makeJailedZsh {quotient = true;};

  relay = import ./quotient-relay.nix {
    inherit pkgs;
    inherit (agents) combinators;
  };

  # A host quotient: reports where and under which policy it runs, and
  # whether any relay variable leaked into it.
  stubQuotient = pkgs.writeShellScriptBin "quotient" ''
    echo "cwd=$(pwd -P)"
    echo "roots=$(${pkgs.jq}/bin/jq -c .roots "$QUOTIENT_POLICY")"
    echo "leaked=$(env | grep -c '^JAIL_QUOTIENT_' || true)"
    read -r line
    echo "echo=$line"
  '';
in
  assert noLaunchDirFails;
    pkgs.runCommand "quotient-relay-tests" {
      nativeBuildInputs = with pkgs; [gnugrep coreutils jq socat];
    } ''
      refute() {
        if "$@"; then
          echo "refute: holds, expected not to: $*" >&2
          exit 1
        fi
      }
      holds() { jq -e "$@" > /dev/null; }
      wait_for() {
        for _ in $(seq 100); do
          if eval "$1"; then return 0; fi
          sleep 0.05
        done
        echo "timed out waiting for: $1" >&2
        exit 1
      }

      # Which jails carry the relay: the listener and the in-jail command.
      for launcher in ${relayOn}/bin/jailed-zsh ${offlineOn}/bin/jailed-zsh \
        ${launchDirRo}/bin/jailed-zsh; do
        grep -Fq -- '-quotient-jail-listener' "$launcher"
        grep -q -- '/nix/store/[^ :]*-quotient-jail-shim/bin' "$launcher"
      done
      for launcher in ${specDev}/bin/jailed-zsh ${offline}/bin/jailed-zsh \
        ${launchDirOff}/bin/jailed-zsh; do
        refute grep -Fq -- 'quotient' "$launcher"
      done
      grep -Fq -- 'JAIL_QUOTIENT_ACCESS=rw' ${relayOn}/bin/jailed-zsh
      grep -Fq -- 'JAIL_QUOTIENT_ACCESS=ro' ${launchDirRo}/bin/jailed-zsh
      # The in-jail command keeps the host's name, so one MCP registration
      # (`command: quotient`) serves host and jail.
      test -x ${relay.shim}/bin/quotient

      # Only bare `quotient` is relayed. Anything else is refused by name,
      # before the socket is looked at, and never waits on stdin (ISS-026).
      for args in 'reduce -v --out d f' help --version; do
        status=0
        # shellcheck disable=SC2086 # the words are the arguments
        timeout 5 ${relay.shim}/bin/quotient $args \
          < <(sleep 30) > shim.out 2> shim.err || status=$?
        test "$status" = 69
        test ! -s shim.out
        grep -Fq -- "quotient $args: only the MCP server is relayed" shim.err
      done

      # Policy narrowing. Roots a, a symlink to b, and a sibling `ab` that
      # shares a's prefix but not its path.
      t=$TMPDIR/policy
      mkdir -p "$t"/a/proj/cache "$t"/b/proj "$t"/ab "$t"/c "$t"/home/.config/quotient
      ln -s "$t/b" "$t/b-link"
      jq -n --arg t "$t" '{
        schema: "quotient-policy/2", mode: "per-call", enabled: true,
        roots: ["\($t)/a", "\($t)/b-link"],
        maxima: {requests: 1, context_tokens: 1, cost_usd: 1, wall_clock_s: 1},
        profiles: {read: "read", implement: "write"},
        forms: {read: "/r", write: "/w"},
        exposure: ["\($t)/a/proj/cache", "\($t)/c"]
      }' > "$t/policy.json"
      narrow() { QUOTIENT_POLICY="$t/policy.json" ${relay.narrowPolicy} "$@"; }

      # rw: one root, the launch dir; exposure only inside it; the rest kept.
      narrow "$t/a/proj" rw > "$t/rw.json"
      holds --arg t "$t" '.roots == ["\($t)/a/proj"]' "$t/rw.json"
      holds --arg t "$t" '.exposure == ["\($t)/a/proj/cache"]' "$t/rw.json"
      holds '.profiles == {read: "read", implement: "write"}' "$t/rw.json"
      holds '.forms == {read: "/r", write: "/w"} and .enabled and .maxima.requests == 1' "$t/rw.json"
      # ro: no write profile, no write form, no exposure.
      narrow "$t/a/proj" ro > "$t/ro.json"
      holds '.profiles == {read: "read"} and .forms == {read: "/r"} and .exposure == []' "$t/ro.json"
      # A policy root through a symlink still contains the resolved root.
      narrow "$t/b/proj" rw > /dev/null
      # Outside every root, by path component: refused, with a reason.
      refute narrow "$t/ab" rw > /dev/null 2> "$t/ab.err"
      grep -Fq -- 'outside every root' "$t/ab.err"
      refute narrow "$t/a/proj" rx > /dev/null 2>&1
      # The policy is found as quotient finds it: QUOTIENT_POLICY, else XDG.
      cp "$t/policy.json" "$t/home/.config/quotient/policy.json"
      env -u QUOTIENT_POLICY HOME="$t/home" ${relay.narrowPolicy} "$t/a/proj" rw > /dev/null
      env -u QUOTIENT_POLICY HOME=/nonexistent XDG_CONFIG_HOME="$t/home/.config" \
        ${relay.narrowPolicy} "$t/a/proj" rw > /dev/null
      refute env -u QUOTIENT_POLICY HOME=/nonexistent ${relay.narrowPolicy} "$t/a/proj" rw 2> /dev/null

      # The listener: each connection reaches a host quotient in the root,
      # under the narrowed policy, with no relay variable; TERM removes its
      # directory.
      d=$(mktemp -d)
      JAIL_QUOTIENT_BIN=${stubQuotient}/bin/quotient JAIL_QUOTIENT_ROOT="$t/a/proj" \
        JAIL_QUOTIENT_ACCESS=rw QUOTIENT_POLICY="$t/policy.json" \
        ${relay.listener} "$d" < /dev/null &
      listener=$!
      wait_for "[ -S $d/socket/mcp.sock ]"
      [ "$(stat -c %a "$d")" = 700 ]
      for n in 1 2; do
        echo "ping $n" | socat -t 5 - "UNIX-CONNECT:$d/socket/mcp.sock" > "$t/reply-$n"
        grep -Fxq -- "cwd=$t/a/proj" "$t/reply-$n"
        grep -Fxq -- "roots=[\"$t/a/proj\"]" "$t/reply-$n"
        grep -Fxq -- 'leaked=0' "$t/reply-$n"
        grep -Fxq -- "echo=ping $n" "$t/reply-$n"
      done
      kill -TERM "$listener"
      wait "$listener" || true
      refute test -e "$d"

      # A launch: the socket directory bound read-only at /run/quotient,
      # and the listener gone with the launcher (pdeathsig), directory and all.
      mkdir -p "$t/launch" "$t/run"
      (cd "$t/a/proj" && env -i LANG=C.UTF-8 HOME="$t/home" PATH=${stubQuotient}/bin XDG_RUNTIME_DIR="$t/run" \
        QUOTIENT_POLICY="$t/policy.json" ${probe}/bin/jailed-zsh)
      argv=$t/a/proj/bwrap-argv
      grep -B2 -Fx -- /run/quotient "$argv" | head -1 | grep -Fxq -- --ro-bind
      src=$(grep -B1 -Fx -- /run/quotient "$argv" | head -1)
      case "$src" in "$t"/run/jail-quotient.*/socket) ;; *) echo "bind source: $src" >&2; exit 1 ;; esac
      wait_for "[ ! -e $(dirname "$src") ]"

      # No host quotient, or a root outside the policy: the jail launches
      # without the relay.
      rm "$t/a/proj/bwrap-argv"
      (cd "$t/a/proj" && env -i LANG=C.UTF-8 HOME="$t/home" PATH=/nonexistent XDG_RUNTIME_DIR="$t/run" \
        ${probe}/bin/jailed-zsh)
      refute grep -Fq -- /run/quotient "$t/a/proj/bwrap-argv"
      (cd "$t/ab" && env -i LANG=C.UTF-8 HOME="$t/home" PATH=${stubQuotient}/bin XDG_RUNTIME_DIR="$t/run" \
        QUOTIENT_POLICY="$t/policy.json" ${probe}/bin/jailed-zsh 2> "$t/ab-launch.err")
      refute grep -Fq -- /run/quotient "$t/ab/bwrap-argv"
      grep -Fq -- 'outside every root' "$t/ab-launch.err"

      touch "$out"
    ''
