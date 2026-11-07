#!/usr/bin/env -S zsh -f
# Behaviour of the zmx-title prompt hook from ~/.config/zsh/functions.zsh, in a throwaway
# $HOME. zmx prints $tmp/labels, or fails with noise if there are none.
emulate -L zsh
local tmp=$(mktemp -d) fails=0 src=~/.config/zsh/functions.zsh
export HOME=$tmp
mkdir -p $tmp/bin $tmp/dev/zmux
print '#!/bin/sh\n[ -e '$tmp'/labels ] || { echo "no session" >&2; exit 1; }\ncat '$tmp'/labels' > $tmp/bin/zmx
chmod +x $tmp/bin/*
path=($tmp/bin $path)
compdef() {}
source $src
cd $tmp/dev/zmux

check() { # name, expected output, output
  [[ $3 == $2 ]] && print "ok   $1" || { print "FAIL $1\n     want: ${(q)2}\n     got:  ${(q)3}"; (( fails++ )) }
}
labels() { print -- $1 > $tmp/labels }
title() { print -n -- "\e]0;$1\a" }

export ZMX_SESSION=zmux.3

labels "id=3 project=zmux role=test-runner"
check "shows the session, its role and the directory" "$(title 'zmux.3 | test-runner | ~/dev/zmux')" "$(zmx-title)"

labels "id=3 project=zmux"
check "a session with no role omits it" "$(title 'zmux.3 | ~/dev/zmux')" "$(zmx-title)"

labels "id=1 project=www_example"
check "the labels win over the name" "$(title 'www_example.1 | ~/dev/zmux')" "$(zmx-title)"

labels ""
check "an unlabelled session shows its name" "$(title 'zmux.3 | ~/dev/zmux')" "$(zmx-title)"

for state icon in done ● working ◐ blocked 🔔 failed ⊘; do
  labels "id=3 project=zmux state=$state"
  check "$state shows its icon last" "$(title "zmux.3 | ~/dev/zmux | $icon")" "$(zmx-title)"
done

labels "id=3 project=zmux state=other"
check "an unknown state still shows" "$(title 'zmux.3 | ~/dev/zmux | *')" "$(zmx-title)"

rm $tmp/labels
check "a session zmx can't read shows its name, quietly" "$(title 'zmux.3 | ~/dev/zmux')" "$(zmx-title 2>&1)"

unset ZMX_SESSION
labels "id=3 project=zmux"
check "outside a session it writes nothing" "" "$(zmx-title)"

check "runs at every prompt" zmx-title "${precmd_functions[(r)zmx-title]}"

rm -rf $tmp
exit $(( fails > 0 ))
