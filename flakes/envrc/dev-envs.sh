#!/usr/bin/env bash
# shellcheck shell=bash
# direnv helper for the layered dev environments (SL-022). A project's .envrc:
#
#   source_env_if_exists ~/flakes/envrc/dev-envs.sh
#   use_dev_envs || use flake .
#
# `||`, not `if has …; then …; else …; fi`: a guard that returns 1 inside the
# `then` branch does not run the `else`, which is how every absent case below
# falls back to the project's own devshell.
#
# source_env watches this file, so an edit here reloads every project sourcing it.

# `use_dev_envs [args]`: land in ~/flakes/dev-envs#default with this checkout as the
# project input. Extra args pass through to `use flake`.
use_dev_envs() {
  # bubblewrap is Linux-only. Not a fallback: the caller's `||` is.
  [[ $(uname -s) == Linux ]] || return 1

  # git+file, not path: tracked content only, so a target/ directory never
  # enters the store. The toplevel, not $PWD: running from a subdirectory must
  # still name the project, and the jail binds the launch directory.
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1

  # The agents lib reads JAIL_WORKSPACE_DEPS{,_RW} with getEnv, which pure
  # evaluation answers with "", so either set means --impure.
  local impure=()
  [[ -n ${JAIL_WORKSPACE_DEPS:-}${JAIL_WORKSPACE_DEPS_RW:-} ]] && impure=(--impure)

  # A project edit changes the tools, so reload on its flake; a consumer edit
  # (any of its .nix files, or its lock) changes the jails, and so does an edit
  # to the in-tree agents library. A glob with no match is dropped, not named.
  local watch=("$root/flake.nix" "$root/flake.lock" "$HOME/flakes/dev-envs/flake.lock")
  local f
  for f in "$HOME/flakes/dev-envs"/*.nix "$HOME/flakes/agents"/*.nix; do
    if [[ -f $f ]]; then watch+=("$f"); fi
  done
  watch_file "${watch[@]}"

  # --no-write-lock-file: an override must never land in dev-envs' lock.
  # agents: the in-tree library lands without a push and re-lock; dev-envs'
  # lock keeps the published pin. doctrine is deliberately not overridden.
  use flake "path:$HOME/flakes/dev-envs#default" \
    --override-input project "git+file:$root" \
    --override-input agents "path:$HOME/flakes/agents" \
    --no-write-lock-file "${impure[@]}" "$@"
}
