#!/bin/sh
# Behaviour tests for git-guard.sh, run by jailed-agents-test.nix against the
# guarded git a jail actually gets. The caller puts that git first on PATH:
#
#   PATH=<guarded-git>/bin:$PATH sh git-guard.test.sh
#
# Worth keeping because the guard's failure mode is silent and asymmetric:
# a pattern that stops matching lets the blocked command THROUGH. The
# original implementation used `case $a in $_pat)` with `$_pat` an expanded
# alternation, which never matches (POSIX: expansion results are not
# re-parsed as pattern syntax) — every destructive command was quietly
# allowed while every probe still looked plausible. Hence most probes here
# assert refusals, not just pass-through.

set -u

fails=0
checks=0

expect() {
  want=$1
  shift
  got=allow
  out=$(git "$@" 2>&1)
  rc=$?
  [ $rc -ne 0 ] && case $out in *'git-guard: refused'*) got=block ;; esac
  checks=$((checks + 1))
  if [ "$got" = "$want" ]; then
    printf 'ok   %-6s git %s\n' "$want" "$*"
  else
    fails=$((fails + 1))
    printf 'FAIL want=%s got=%s  git %s\n' "$want" "$got" "$*"
    printf '       %.100s\n' "$(printf '%s' "$out" | head -1)"
  fi
}

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT INT TERM
cd "$scratch" || exit 1
git init -q -b main .
echo one >f.txt
git add .
git -c user.email=t@t -c user.name=t commit -qm init
echo two >>f.txt

# stash: everything except the read-only inspectors
expect block stash
expect block stash push -m wip
expect block stash pop
expect block stash drop
expect allow stash list
expect allow stash show

# checkout: path-restore and force/merge throw away modifications;
# branch switching must stay working (magit and scripts depend on it)
expect block checkout -- f.txt
expect block checkout -f main
expect block checkout --force main
expect block checkout -m main
expect allow checkout -b feature
expect allow checkout main

# reset: only the modes that move the working tree
expect block reset --hard
expect block reset --keep HEAD
expect allow reset --soft HEAD
expect allow reset --mixed HEAD

# clean: destructive unless previewing
expect block clean
expect block clean -fd
expect allow clean -n
expect allow clean --dry-run

# restore: discard unless pulling from a commit
expect block restore f.txt
expect allow restore --source=HEAD -- f.txt

# ordinary use must be untouched
expect allow status --short
expect allow log --oneline -1
expect allow diff --name-only
expect allow add f.txt
expect allow --version

# global options must not hide the subcommand
expect block -C . stash
expect block -c core.pager=cat stash
expect block --no-pager stash
expect block -C "$scratch" checkout -- f.txt

# and the escape hatch must work
if GIT_GUARD=off git stash push -m probe >/dev/null 2>&1; then
  checks=$((checks + 1))
  printf 'ok   allow  GIT_GUARD=off git stash\n'
  GIT_GUARD=off git stash drop >/dev/null 2>&1
else
  checks=$((checks + 1))
  fails=$((fails + 1))
  printf 'FAIL GIT_GUARD=off did not bypass the guard\n'
fi

printf '\n%s/%s passed' "$((checks - fails))" "$checks"
[ "$fails" -eq 0 ] && printf '\n' || printf '  -- %s FAILED\n' "$fails"
exit "$([ "$fails" -eq 0 ] && echo 0 || echo 1)"
