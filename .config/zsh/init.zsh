autoload zmv

path+=~/.local/bin
path+=~/.cargo/bin
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

source $HOME/.config/zsh/functions.zsh
source $HOME/.config/zsh/zstyle.zsh
source $HOME/.config/zsh/aliases.zsh

#
# 
# 

WORDCHARS='*?_.[]~&;!#$%^(){}<>'
autoload -Uz select-word-style
select-word-style normal

# ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_STRATEGY=()

if [ -f /opt/homebrew/bin/brew ]; then
  eval $(/opt/homebrew/bin/brew shellenv);
fi
