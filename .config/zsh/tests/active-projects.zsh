#!/usr/bin/env -S zsh -f
# Behaviour of active-projects from ~/.config/zsh/functions.zsh, in a throwaway
# $HOME with zoxide stubbed to print $tmp/zoxide-list, in that order.
emulate -L zsh
local tmp=$(mktemp -d) fails=0 src=~/.config/zsh/functions.zsh
export HOME=$tmp
mkdir -p $tmp/bin
print '#!/bin/sh\ncat '$tmp'/zoxide-list' > $tmp/bin/zoxide
chmod +x $tmp/bin/*
path=($tmp/bin $path)
compdef() {}
source $src

check() { # name, expected output, output
  [[ $3 == $2 ]] && print "ok   $1" || { print "FAIL $1\n     want: ${(q)2}\n     got:  ${(q)3}"; (( fails++ )) }
}
listed() { print -l -- $@ > $tmp/zoxide-list }

mkdir -p $tmp/dev/{git,jj,marked,plain,worktree}/.keep $tmp/dev/git/.git $tmp/dev/jj/.jj
touch $tmp/dev/marked/.project
print 'gitdir: ../git/.git/worktrees/w' > $tmp/dev/worktree/.git
touch $tmp/dev/worktree/.project

listed $tmp/dev/marked $tmp/dev/jj $tmp/dev/git
check "keeps zoxide's order, for every marker" \
  "$tmp/dev/marked"$'\n'"$tmp/dev/jj"$'\n'"$tmp/dev/git" "$(active-projects)"

listed $tmp/dev/plain $tmp/dev/git/.keep
check "a directory without a marker is no project" "" "$(active-projects)"

listed $tmp/dev/worktree
check "a linked worktree is left out" "" "$(active-projects)"

listed $tmp/dev/absent
check "an absent directory is skipped" "" "$(active-projects)"

mkdir $tmp/.git
listed $tmp
check "\$HOME is never a project" "" "$(active-projects)"

mkdir -p $tmp/.config/emacs/.git $tmp/.config/emacs/elpa/magit/.git
listed $tmp/.config/emacs $tmp/.config/emacs/elpa/magit
check "elpa packages are left out, Emacs isn't" "$tmp/.config/emacs" "$(active-projects)"

listed $tmp/dev/plain
active-projects > /dev/null
check "exits 0 when the last directory is no project" 0 $?

rm $tmp/bin/zoxide
out=$(active-projects 2>&1)
check "exits 0 without zoxide" 0 $?
check "is silent without zoxide" "" "$out"

print '#!/bin/sh\necho "no database" >&2\nexit 1' > $tmp/bin/zoxide
chmod +x $tmp/bin/zoxide
out=$(active-projects 2>&1)
check "exits 0 when zoxide fails" 0 $?
check "is silent when zoxide fails" "" "$out"

rm -rf $tmp
exit $(( fails > 0 ))
