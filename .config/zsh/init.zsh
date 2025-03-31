autoload zmv


path+=~/.local/bin
path+=~/.cargo/bin
path+=$PWD/bin

typeset -U path

# Fix Alt-BSPC & word navigation:

bindkey -e

# WORDCHARS are defined in belak/zsh-utils:editor
autoload -Uz select-word-style
select-word-style normal
# zstyle ':zle:*' word-style unspecified

setopt extended_glob
setopt glob_dots
# setopt no_complete_aliases
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus
setopt HIST_REDUCE_BLANKS 
setopt HIST_VERIFY        

source $HOME/.config/zsh/completions.zsh
source $HOME/.config/zsh/functions.zsh
source $HOME/.config/zsh/zstyle.zsh
source $HOME/.config/zsh/aliases.zsh
