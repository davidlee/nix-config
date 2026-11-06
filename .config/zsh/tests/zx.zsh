#!/usr/bin/env -S zsh -f
# Behaviour of zx and the harness functions from ~/.config/zsh/functions.zsh, in a
# throwaway $HOME. fzf takes the first project, or none with $tmp/cancel; zmx-new
# reports where it was run and with what. Naming is zmx-new's, tested in zmux.
emulate -L zsh
local tmp=$(mktemp -d) fails=0 src=~/.config/zsh/functions.zsh
export HOME=$tmp
mkdir -p $tmp/bin $tmp/dev/zmux/.git $tmp/dev/www.example/.git
print '#!/bin/sh\ncat '$tmp'/zoxide-list' > $tmp/bin/zoxide
print '#!/bin/sh\n[ -e '$tmp'/cancel ] && exit 130\nhead -n 1' > $tmp/bin/fzf
print '#!/bin/sh\necho "$PWD: $*"' > $tmp/bin/zmx-new
chmod +x $tmp/bin/*
path=($tmp/bin $path)
compdef() {}
source $src

check() { # name, expected output, output
  [[ $3 == $2 ]] && print "ok   $1" || { print "FAIL $1\n     want: ${(q)2}\n     got:  ${(q)3}"; (( fails++ )) }
}
picks() { print -- $1 > $tmp/zoxide-list }

picks $tmp/dev/zmux
check "starts a session in the project" "$tmp/dev/zmux: " "$(zx)"

touch $tmp/cancel
check "cancelling the pick attaches nothing" "" "$(zx)"
zx
check "cancelling is not a failure" 0 $?
rm $tmp/cancel

local here=$PWD
zx > /dev/null
check "the caller stays where it was" $here $PWD

check "claude starts through zmx-new" "$PWD: claude --resume x" "$(claude --resume x)"
check "codex starts through zmx-new" "$PWD: codex" "$(codex)"

rm -rf $tmp
exit $(( fails > 0 ))
