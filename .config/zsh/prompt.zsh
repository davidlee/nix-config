# Additions to the prompt that _p10k.zsh, which `p10k configure` regenerates, would lose.
# Sourced after it: its first act is to unset every POWERLEVEL9K_* parameter.

# No gap after the right prompt. p10k works around terminals that mishandle 0.
ZLE_RPROMPT_INDENT=0

# zmx: the session this shell runs in, as a pill at the end of the right prompt's first
# line. Bold black on green inside a session, on dark red outside one. This style draws no
# backgrounds or separators of its own, so the pill brings its padding and rounded ends.
() {
  local i=${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[(i)newline]}
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[i,i-1]=(zmx)
}
typeset -g POWERLEVEL9K_ZMX_{IN,OUT}_FOREGROUND=0
typeset -g POWERLEVEL9K_ZMX_IN_BACKGROUND='#008000'
typeset -g POWERLEVEL9K_ZMX_OUT_BACKGROUND='#7A2900'
typeset -g POWERLEVEL9K_ZMX_RIGHT_{LEFT,RIGHT}_WHITESPACE=' '
typeset -g POWERLEVEL9K_ZMX_RIGHT_SEGMENT_SEPARATOR=$' \uE0B6'
typeset -g POWERLEVEL9K_ZMX_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=$'\uE0B6'
typeset -g POWERLEVEL9K_ZMX_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=$'\uE0B4'

# From the environment, so the instant prompt draws it too. The name is text: -t would
# expand a % in it.
prompt_zmx() {
  if [[ -n $ZMX_SESSION ]]; then
    p10k segment -s IN -t "%B${ZMX_SESSION//\%/%%}%b"
  else
    p10k segment -s OUT -t '%Bzmx%b'
  fi
}
instant_prompt_zmx() { prompt_zmx }

(( ! $+functions[p10k] )) || p10k reload
