# The jail scan (IMP-051; from satan, screwtape DEC-013): a check that no jail
# can reach a path, over built launchers as text (satan DEC-046).
#
# From each launcher it follows every script it execs (a quotient form is
# three deep), the `--args` files it opens (NUL-separated), and the nested
# jail launchers on its PATH. It fails on a `literals` string anywhere, or on
# a bare argument matching one of `tokens` (extended regexes, whole word).
# `controlBind` is a positive control: the same walk over a synthetic
# launcher that execs a script binding it through an args file must fail. It
# also fails if it scanned no launcher. The check's output is its summary.
#
# A guard for known paths, not proof: indirection (`B=/run; --bind "$B"`),
# arguments computed at run time (`RUNTIME_ARGS`, `elf-closure-binds`,
# `printf` process substitutions: seen as code, not as the paths they
# produce), and helpers not named `-jailed-`.
{
  lib,
  pkgs,
}: let
  mkJailScanCheck = {
    name,
    # Derivations; each one's bin/* is scanned.
    launchers,
    literals,
    tokens,
    controlBind,
  }: let
    # The bind sits in an args file the inner script opens, so catching it
    # proves both the exec and the args-file legs of the walk.
    controlArgs = pkgs.runCommand "${name}-control-args" {} ''
      printf '%s\0' ${controlBind} > $out
    '';
    controlInner = pkgs.writeShellScriptBin "jailed-${name}-control" ''
      exec {CONTROL_ARGS_FD}<${controlArgs}
      exec bwrap --args "$CONTROL_ARGS_FD" true
    '';
    control = pkgs.writeShellScriptBin "${name}-control" ''
      exec ${controlInner}/bin/jailed-${name}-control "$@"
    '';
    tokenRegex = "(${lib.concatStringsSep "|" tokens})";
  in
    pkgs.runCommand name {} ''
      fail() {
        echo "${name}: $*" >&2
        exit 1
      }
      is_script() { [ "$(head -c2 "$1")" = '#!' ]; }

      # reach <launcher>...: every script and args file the launchers reach,
      # each once. ELF binaries (bwrap) are neither scanned nor followed.
      reach() {
        local queue=() seen=" " f next
        for f in "$@"; do
          if is_script "$f"; then queue+=("$f"); fi
        done
        while [ ''${#queue[@]} -gt 0 ]; do
          f=''${queue[0]}
          queue=("''${queue[@]:1}")
          case $seen in *" $f "*) continue ;; esac
          seen="$seen$f "
          echo "$f"
          is_script "$f" || continue
          for next in \
            $(sed -n 's|^exec \(/nix/store/[^ ]*/bin/[^ ]*\)\( .*\)\?$|\1|p' "$f") \
            $(grep -o '/nix/store/[a-z0-9]\{32\}-jailed-[^/ :"]*/bin' "$f" | sort -u | sed 's|$|/*|'); do
            for next in $next; do
              if [ -f "$next" ] && is_script "$next"; then queue+=("$next"); fi
            done
          done
          for next in $(grep -o '{[A-Z_]*}</nix/store/[^ ]*' "$f" | sed 's|^[^<]*<||'); do
            queue+=("$next")
          done
        done
      }

      # forbidden <file>: names the first hit, or returns 1.
      forbidden() {
        local s hit
        for s in ${lib.escapeShellArgs literals}; do
          if grep -Faq -- "$s" "$1"; then echo "$1 contains '$s'"; return 0; fi
        done
        hit=$(tr '\000' '\n' < "$1" | tr -s '[:space:]' '\n' | tr -d "\"'" \
          | grep -Ex -- ${lib.escapeShellArg tokenRegex} | head -1 || true)
        if [ -n "$hit" ]; then echo "$1 has the argument '$hit'"; return 0; fi
        return 1
      }

      # scan <launcher>...: echoes the first hit and returns 1, else sets
      # `scanned` to the number of scripts read.
      scan() {
        local f
        scanned=0
        while read -r f; do
          test -f "$f" || { echo "no file at $f"; return 1; }
          if forbidden "$f"; then return 1; fi
          if is_script "$f"; then scanned=$((scanned + 1)); fi
        # A hit stops reading early; reach's broken pipe is not news.
        done < <(reach "$@" 2> /dev/null)
      }

      if scan ${control}/bin/${name}-control > /dev/null; then
        fail "positive control passed: the scan misses '${controlBind}'"
      fi
      test "$scanned" -eq 2 || fail "positive control reached $scanned scripts, not 2"

      if ! scan ${lib.concatMapStringsSep " " (p: "${p}/bin/*") launchers} > "$TMPDIR/hit"; then
        fail "$(cat "$TMPDIR/hit")"
      fi
      test "$scanned" -gt 0 || fail "scanned no launchers"
      echo "${name}: $scanned scripts clean" | tee $out
    '';

  # No jail can run `op` or reach 1Password's sockets, nor bind an ancestor
  # that would expose them (screwtape DEC-013; satan SPEC-002 NF-004). Not
  # covered: whole-home binds (satan ISS-028), the abstract socket (satan
  # RSK-021).
  opUnjailed = launchers:
    mkJailScanCheck {
      name = "op-unjailed";
      inherit launchers;
      literals = [
        "/run/wrappers/bin/op"
        "onepassword-cli"
        ".1password"
        "1Password-BrowserSupport.sock"
        "1PASSWORD_SDK_INTERGATIONS"
      ];
      # Every ancestor of the wrapper and the app's runtime-dir socket, the
      # last by variable too.
      tokens = [
        "/"
        "/run/?"
        "/run/wrappers/?"
        "/run/wrappers/bin/?"
        "/run/user/?"
        "/run/user/[0-9]+/?"
        "\\$\\{?XDG_RUNTIME_DIR\\}?/?"
      ];
      controlBind = "--ro-bind /run /run";
    };
in {
  inherit mkJailScanCheck opUnjailed;
}
