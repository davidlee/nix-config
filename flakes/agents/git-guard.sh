#!/bin/sh
# git-guard -- installed as `git` in place of the real one. jailed-agents.nix
# packages it as `guardedGit` and puts it on every jail's PATH (`guardGit`).
#
# WHY THIS EXISTS
# A jail home's ~/.gitconfig tried to block `stash` and `checkout` with
# aliases. Git ignores any alias that hides an existing command:
#
#   git-config(1), "alias.*": "To avoid confusion and troubles with script
#   usage, aliases that hide existing Git commands are ignored except for
#   deprecated commands."
#
# Both are builtins, so both guards are dead letters -- `git stash` discards
# the working tree as normal. An agent ran exactly that on 2026-09-30 and
# stashed an uncommitted edit. This is the working replacement.
#
# POLICY -- refuse the commands that discard uncommitted work
#
#   stash     refused, except read-only `list` / `show`
#   checkout  refused in path-restore / forced / --merge form
#   reset     refused with --hard, --merge, --keep
#   clean     refused unless -n / --dry-run
#   restore   refused unless --source= is given
#
# Safe forms pass through: `git checkout <branch>`, `git checkout -b`,
# `git reset --soft`, `git clean -n`, `git restore --source=<ref> -- <paths>`.
# Branch switching is deliberately NOT blocked -- magit and scripts need it.
#
# OVERRIDE
#   GIT_GUARD=off git stash ...
# One invocation, and it prints a notice so the override is visible in any
# transcript. Nothing here is more than a speed bump: the jail is the
# sandbox, this stops muscle memory from costing a day's work.

set -u

REFUSAL_HINT='commit or copy the work first, or re-run with GIT_GUARD=off if it is deliberate'

# Substituted at build time (jailed-agents.nix): the store path of the real
# git. A fixed path, not a PATH search, so the shim cannot find itself.
real=@git@

if [ "${GIT_GUARD:-}" = off ]; then
  printf 'git-guard: override active (GIT_GUARD=off) -- running real git\n' >&2
  exec "$real" "$@"
fi

# --- find the subcommand, stepping over git's value-taking global options ---
sub=
expect_value=
for a in "$@"; do
  if [ -n "$expect_value" ]; then
    expect_value=
    continue
  fi
  case $a in
  -C | -c | --git-dir | --work-tree | --namespace | --config-env | --exec-path | --super-prefix)
    expect_value=1
    ;;
  -*) ;;
  *)
    sub=$a
    break
    ;;
  esac
done

# --- refuse, per subcommand ------------------------------------------------
# NOTE: patterns must appear literally in the `case`, never via expansion.
# `pat='a|b'; case x in $pat)` does not treat `|` as alternation -- POSIX
# never re-parses expansion results as pattern syntax -- so it silently never
# matches, and a guard written that way fails open.

refuse() {
  printf 'git-guard: refused "git %s" -- %s\n' "$1" "$2" >&2
  printf 'git-guard: %s\n' "$REFUSAL_HINT" >&2
  exit 1
}

case $sub in
stash)
  # `list` / `show` are read-only and useful for inspecting an existing stash.
  _act=
  _past=
  for a in "$@"; do
    if [ -n "$_past" ]; then
      _act=$a
      break
    fi
    [ "$a" = "stash" ] && _past=1
  done
  case ${_act:-push} in
  list | show) ;;
  *) refuse "$sub" 'this is the command that has cost you work before' ;;
  esac
  ;;
checkout)
  # `--` ends options and means the rest are paths to overwrite.
  # -f/--force and -m/--merge also throw away local modifications.
  for a in "$@"; do
    case $a in
    -- | -f | --force | -m | --merge)
      refuse "$sub" 'would overwrite local modifications'
      ;;
    esac
  done
  ;;
reset)
  for a in "$@"; do
    case $a in
    --hard | --merge | --keep)
      refuse "$sub" 'would move the working tree, not just the index'
      ;;
    esac
  done
  ;;
clean)
  _dry=
  for a in "$@"; do
    case $a in -n | --dry-run) _dry=1 ;; esac
  done
  [ -n "$_dry" ] || refuse "$sub" 'deletes untracked files; -n previews first'
  ;;
restore)
  _src=
  for a in "$@"; do
    case $a in --source=* | --source) _src=1 ;; esac
  done
  [ -n "$_src" ] || refuse "$sub" 'would discard uncommitted changes; use --source=<ref> to pull from a commit'
  ;;
esac

exec "$real" "$@"
