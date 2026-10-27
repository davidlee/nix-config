# shellcheck shell=bash
# direnv helpers for projects on ~/flakes/agents (IMP-047). A project's .envrc:
#
#   source_env_if_exists ~/flakes/envrc/agents.sh
#   if has use_agents_dev; then use agents_dev; else use flake .; fi
#
# source_env also watches this file, so an edit here reloads every project
# that sources it. Template: ~/flakes/_templates/agents/_envrc.

# `use flake_local <input>[:<dir>]... [args]`: `use flake .`, but each named
# input is read live from ~/flakes/<dir> (default: the input's name) rather
# than the project's flake.lock, so a bump there reaches every project on its
# next reload. Leading words name inputs; the rest pass to `use flake`. An
# input whose checkout is absent keeps its lock.
use_flake_local() {
  local args=() name dir
  while [[ $# -gt 0 && $1 != -* ]]; do
    name=${1%%:*}
    dir="$HOME/flakes/${1#*:}"
    if [[ -d $dir ]]; then
      args+=(--override-input "$name" "path:$dir")
      watch_file "$dir/flake.lock" "$dir"/*.nix
    else
      log_status "flake_local: no $dir; $name from lock"
    fi
    shift
  done
  use flake . "${args[@]}" "$@"
}

# `use agents_dev [<input>...] [args]`: use_flake_local, inputs defaulting to
# `agents`. The agents lib reads JAIL_WORKSPACE_DEPS and JAIL_WORKSPACE_DEPS_RW
# with getEnv, which pure evaluation answers with "", so either set means
# --impure; unset, evaluation stays pure.
use_agents_dev() {
  local inputs=()
  while [[ $# -gt 0 && $1 != -* ]]; do
    inputs+=("$1")
    shift
  done
  [[ ${#inputs[@]} -gt 0 ]] || inputs=(agents)
  if [[ -n ${JAIL_WORKSPACE_DEPS:-}${JAIL_WORKSPACE_DEPS_RW:-} && " $* " != *" --impure "* ]]; then
    set -- "$@" --impure
  fi
  use_flake_local "${inputs[@]}" "$@"
}
