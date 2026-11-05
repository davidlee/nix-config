#!/usr/bin/env -S zsh -f
# Behaviour of zx from ~/.config/zsh/functions.zsh, in a throwaway $HOME. fzf takes
# the first project, or none with $tmp/cancel; zmx lists $tmp/sessions and reports
# where it was asked to attach.
emulate -L zsh
local tmp=$(mktemp -d) fails=0 src=~/.config/zsh/functions.zsh
export HOME=$tmp
mkdir -p $tmp/bin $tmp/dev/zmux/.git $tmp/dev/www.example/.git
print '#!/bin/sh\ncat '$tmp'/zoxide-list' > $tmp/bin/zoxide
print '#!/bin/sh\n[ -e '$tmp'/cancel ] && exit 130\nhead -n 1' > $tmp/bin/fzf
print '#!/bin/sh\ncase $1 in\n  list) cat '$tmp'/sessions ;;\n  *) echo "$PWD: $*" ;;\nesac' > $tmp/bin/zmx
chmod +x $tmp/bin/*
path=($tmp/bin $path)
compdef() {}
source $src

check() { # name, expected output, output
  [[ $3 == $2 ]] && print "ok   $1" || { print "FAIL $1\n     want: ${(q)2}\n     got:  ${(q)3}"; (( fails++ )) }
}
picks() { print -- $1 > $tmp/zoxide-list }
sessions() { print -l -- $@ > $tmp/sessions }

picks $tmp/dev/zmux
sessions
check "the first session of a project is .1" "$tmp/dev/zmux: attach zmux.1" "$(zx)"

sessions zmux.1 zmux.4 zmux.2
check "attaches one above the highest" "$tmp/dev/zmux: attach zmux.5" "$(zx)"

sessions zmux.tests zmux2.9 other.7
check "only this project's numbers count" "$tmp/dev/zmux: attach zmux.1" "$(zx)"

picks $tmp/dev/www.example
sessions www_example.2
check "dots in the project fold to _" "$tmp/dev/www.example: attach www_example.3" "$(zx)"

touch $tmp/cancel
check "cancelling the pick attaches nothing" "" "$(zx)"
zx
check "cancelling is not a failure" 0 $?
rm $tmp/cancel

local here=$PWD
zx > /dev/null
check "the caller stays where it was" $here $PWD

rm -rf $tmp
exit $(( fails > 0 ))
