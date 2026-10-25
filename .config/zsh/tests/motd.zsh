#!/usr/bin/env -S zsh -f
# Behaviour of motd() from ~/.config/zsh/functions.zsh, in a throwaway $HOME.
emulate -L zsh
local tmp=$(mktemp -d) fails=0 src=~/.config/zsh/functions.zsh
export HOME=$tmp XDG_STATE_HOME=$tmp/state
mkdir -p $tmp/bin $tmp/satan
print '#!/bin/sh\necho "doctor $*"' > $tmp/bin/sleipnir-doctor; chmod +x $tmp/bin/sleipnir-doctor
path=($tmp/bin $path)
eval "$(sed -n '/^motd()/,/^}/p' $src)"

check() { # name, expected substring (or !substring), output
  local name=$1 want=$2 out=$3
  if [[ $want == !* ]]; then [[ $out != *${want#!}* ]]; else [[ $out == *$want* ]]; fi \
    && print "ok   $name" || { print "FAIL $name\n     got: ${(q)out}"; (( fails++ )) }
}

check "no message: doctor, daily" "--daily" "$(motd)"
print hail > $tmp/satan/motd.txt; touch -d '-1 min' $tmp/satan/motd.txt
check "unseen message prints"      "hail"   "$(motd)"
check "seen message is quiet"      "!hail"  "$(motd)"
check "-v reprints seen message"   "hail"   "$(motd -v)"
check "-v runs doctor"            "doctor warn" "$(motd -v)"
check "-v skips --daily"          "!--daily" "$(motd -v)"
print new > $tmp/satan/motd.txt; touch -d '+1 min' $tmp/satan/motd.txt
check "updated message prints"     "new"    "$(motd)"
check "then quiet again"           "!new"   "$(motd)"
rm -rf $tmp
exit $fails
