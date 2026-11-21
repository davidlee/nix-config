#!/usr/bin/env -S zsh -f
# Behaviour of the zmx prompt segment from ~/.config/zsh/prompt.zsh, on top of _p10k.zsh.
# A stub p10k records the segment each call would draw.
emulate -L zsh
local fails=0
typeset -a drawn
p10k() { [[ $1 == segment ]] && drawn=("${@:2}") }
source ~/.config/zsh/_p10k.zsh
source ~/.config/zsh/prompt.zsh

check() { # name, expected, actual
  [[ $3 == $2 ]] && print "ok   $1" || { print "FAIL $1\n     want: ${(q)2}\n     got:  ${(q)3}"; (( fails++ )) }
}

export ZMX_SESSION=zmux.3
prompt_zmx
check "a session shows its name, in bold" "-s IN -t %Bzmux.3%b" "$drawn"

ZMX_SESSION='100%.1'
prompt_zmx
check "a name is text, not prompt escapes" "-s IN -t %B100%%.1%b" "$drawn"

unset ZMX_SESSION
prompt_zmx
check "no session says zmx" "-s OUT -t %Bzmx%b" "$drawn"

drawn=()
ZMX_SESSION=zmux.3 instant_prompt_zmx
check "the instant prompt draws it too" "-s IN -t %Bzmux.3%b" "$drawn"
check "it ends the right prompt's first line" "time zmx newline" "${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[-3,-1]}"
check "black on green in a session" "0 #008000" "$POWERLEVEL9K_ZMX_IN_FOREGROUND $POWERLEVEL9K_ZMX_IN_BACKGROUND"
check "black on red outside one" "0 #7A2900" "$POWERLEVEL9K_ZMX_OUT_FOREGROUND $POWERLEVEL9K_ZMX_OUT_BACKGROUND"

exit $(( fails > 0 ))
