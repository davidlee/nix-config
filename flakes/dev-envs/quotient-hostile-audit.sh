# Quotient's write-denial probe against this checkout's linked forms. Calls a model
# through the LLM gateway, so no gate runs it. Exit 0 pass, 1 breach, 77 skipped: a
# prerequisite is missing and nothing was proven. `quotient-hostile-audit [state-dir]`
#
# HOSTILE_AUDIT_*, never QUOTIENT_*: the probe refuses an ambient QUOTIENT_ variable.

state=${1:-${XDG_STATE_HOME:-$HOME/.local/state}/quotient}
gateway_run_dir=${HOSTILE_AUDIT_GATEWAY_RUN_DIR:-/run/llm-gateway}
gateway_key=${HOSTILE_AUDIT_GATEWAY_KEY:-$HOME/.config/llm-gateway/keys/pi}

# The forms run under the gateway, and their wrapper refuses to launch without both.
if [[ ! -d $gateway_run_dir ]]; then
  echo "quotient-hostile-audit: the LLM gateway is not running (no $gateway_run_dir); just system-switch, or systemctl status llm-gateway" >&2
  exit 77
fi
if [[ ! -r $gateway_key || ! -s $gateway_key ]]; then
  echo "quotient-hostile-audit: no gateway key at $gateway_key; llm-gateway issue pi --models <a,b> --budget <usd> --out \"$gateway_key\"" >&2
  exit 77
fi

mkdir -p "$state/hostile-audit"
status=0
for capability in read write; do
  dir=$(mktemp -d "$state/hostile-audit/$capability-XXXXXX")
  mkdir "$dir/root" "$dir/session-home" "$dir/run"
  echo "quotient-hostile-audit: $capability evidence under $dir"
  # No exposure: the form writes only the call's root and session directory, and
  # its private temp.
  rc=0
  # shellcheck disable=SC2154 # set ahead of this file, in flake.nix
  "$probe" --form "$PWD/.quotient/forms/$capability" \
    --capability "$capability" --model llm-gateway/deepseek-flash \
    "$dir/root" "$dir/session-home" "$dir/run" || rc=$?
  # A breach outranks a skip, in either order.
  if [[ $rc -ne 0 && $status -ne 1 ]]; then status=$rc; fi
done
exit "$status"
