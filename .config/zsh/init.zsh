autoload zmv

path+=~/.local/bin
path+=~/.cargo/bin
path+=~/.npm-global/bin
path+=~/go/bin
path+=$PWD/bin

typeset -U path

setopt extended_glob
setopt glob_dots
setopt HIST_REDUCE_BLANKS
setopt BEEP

unsetopt FLOW_CONTROL

# OMZ plugins
plugins=(colored-man-pages extract taskwarrior 1password copypath copybuffer copyfile colorize eza fancy-ctrl-z kitty rust systemd globalias podman zsh-syntax-highlighting zsh-autosuggestions)

zle -N menu-search
zle -N recent-paths

antidote load ${ZDOTDIR}/.zsh_plugins.txt
source ${ZDOTDIR}/.zsh_plugins.zsh

if [[ $OSTYPE = 'linux-gnu' ]]; then
  alias open=xdg-open
fi

source $HOME/.config/zsh/functions.zsh
source $HOME/.config/zsh/zstyle.zsh
source $HOME/.config/zsh/aliases.zsh

# override marlonrichert/zsh-autocomplete keybindings:
bindkey              '^I' menu-select
bindkey "$terminfo[kcbt]" menu-select

bindkey -M menuselect              '^I'         menu-complete
bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete


WORDCHARS='*?_.[]~&;!#$%^(){}<>'
autoload -Uz select-word-style
select-word-style normal

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# ZSH_AUTOSUGGEST_STRATEGY=()

if [ -f /opt/homebrew/bin/brew ]; then
  eval $(/opt/homebrew/bin/brew shellenv);
fi

# TODO: figure out how to skip this if launched with e.g. ghostty -e somecommand
# (as with sway-launcher-desktop)

if [[ -z $TMUX ]]; then
  # (tmux list-sessions && sesh-sessions) || echo "No tmux session found."
  (tmux list-sessions | grep -v -E '^_') || echo "No tmux sessions."
fi
