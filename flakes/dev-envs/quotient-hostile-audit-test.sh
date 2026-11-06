#!/usr/bin/env bash
# Behaviour of quotient-hostile-audit, with a stub in place of quotient's probe and
# a stub gateway. Needs quotient-hostile-audit on PATH.
set -euo pipefail

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
failures=0

mkdir "$work/run-dir"
echo key >"$work/key"
printf '#!%s\n' "$BASH" >"$work/probe" # a build sandbox has no /usr/bin/env
cat >>"$work/probe" <<'STUB'
# Records its argv; exits with $STUB_<capability>, default 0. Fails without compgen,
# which the real probe's ambient check needs and a non-interactive bash lacks.
echo "$*" >>"$STUB_LOG"
env bash -c 'compgen -e' >/dev/null || exit 3
while [[ $1 != --capability ]]; do shift; done
var="STUB_$2"
exit "${!var:-0}"
STUB
chmod +x "$work/probe"

export STUB_LOG=$work/log
export HOSTILE_AUDIT_BIN=$work/probe
export HOSTILE_AUDIT_GATEWAY_RUN_DIR=$work/run-dir
export HOSTILE_AUDIT_GATEWAY_KEY=$work/key

# audit [VAR=value…]: run in a fresh log; sets $rc and $log.
audit() {
  rm -f "$STUB_LOG"
  rc=0
  env "$@" quotient-hostile-audit "$work/state" >/dev/null 2>&1 || rc=$?
  log=$(cat "$STUB_LOG" 2>/dev/null || true)
}

# expect <description> <actual> <expected>
expect() {
  if [[ $2 == "$3" ]]; then printf 'ok   %s\n' "$1"; else
    printf 'FAIL %s: got %s, want %s\n' "$1" "$2" "$3"
    failures=$((failures + 1))
  fi
}

audit HOSTILE_AUDIT_GATEWAY_RUN_DIR="$work/absent"
expect "no gateway skips" "$rc" 77
expect "no gateway runs no probe" "$log" ""

audit HOSTILE_AUDIT_GATEWAY_KEY="$work/absent"
expect "no key skips" "$rc" 77

audit HOSTILE_AUDIT_GATEWAY_KEY=/dev/null
expect "an empty key skips" "$rc" 77

audit
expect "both forms pass" "$rc" 0
expect "probes both capabilities" "$(wc -l <<<"$log")" 2
expect "names the read form" "$(grep -cF -- "--form $PWD/.quotient/forms/read --capability read --model llm-gateway/deepseek-flash " <<<"$log")" 1
expect "names the write form" "$(grep -cF -- "--form $PWD/.quotient/forms/write --capability write " <<<"$log")" 1
expect "keeps evidence under the state dir" "$(find "$work/state/hostile-audit" -mindepth 2 -maxdepth 2 -type d -name root | wc -l)" 2

audit STUB_read=1
expect "a breach fails" "$rc" 1
expect "a breach still probes the other form" "$(wc -l <<<"$log")" 2

audit STUB_write=77
expect "a skip stays a skip" "$rc" 77

audit STUB_read=1 STUB_write=77
expect "a breach outranks a skip" "$rc" 1

audit STUB_read=77 STUB_write=1
expect "a breach outranks an earlier skip" "$rc" 1

exit "$((failures > 0))"
